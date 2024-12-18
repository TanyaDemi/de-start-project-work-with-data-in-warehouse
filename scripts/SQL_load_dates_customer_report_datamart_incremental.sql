WITH
-- определяем, какие данные были изменены в витрине или добавлены в DWH. Формируем дельту изменений
dwh_delta AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.customer_address,
        c.customer_birthday,
        c.customer_email,
        o.order_id,
        p.product_id,
        p.product_price,
        p.product_type,
        o.craftsman_id,
        o.order_status,
        o.order_created_date,
        o.order_completion_date,
        TO_CHAR(o.order_created_date, 'YYYY-MM') AS report_period
    FROM dwh.f_order o
    JOIN dwh.d_customer c ON o.customer_id = c.customer_id
    JOIN dwh.d_product p ON o.product_id = p.product_id
    WHERE o.load_dttm > (SELECT COALESCE(MAX(load_dttm), '1900-01-01') FROM dwh.load_dates_customer_report_datamart)
       OR c.load_dttm > (SELECT COALESCE(MAX(load_dttm), '1900-01-01') FROM dwh.load_dates_customer_report_datamart)
       OR p.load_dttm > (SELECT COALESCE(MAX(load_dttm), '1900-01-01') FROM dwh.load_dates_customer_report_datamart)
),
-- Подготовка данных для вставки
aggregated_data AS (
    SELECT
        d.customer_id,
        d.customer_name,
        d.customer_address,
        d.customer_birthday,
        d.customer_email,
        SUM(d.product_price) AS customer_spent,
        SUM(d.product_price) * 0.1 AS platform_earned,
        COUNT(DISTINCT d.order_id) AS orders_count,
        AVG(d.product_price) AS avg_order_price,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY d.order_completion_date - d.order_created_date) AS median_order_time,
        MAX(d.product_type) AS top_product_category,
        (SELECT craftsman_id
         FROM dwh.f_order
         WHERE customer_id = d.customer_id
         GROUP BY craftsman_id
         ORDER BY COUNT(order_id) DESC
         LIMIT 1) AS top_craftsman_id,
        SUM(CASE WHEN d.order_status = 'created' THEN 1 ELSE 0 END) AS orders_created,
        SUM(CASE WHEN d.order_status = 'in progress' THEN 1 ELSE 0 END) AS orders_in_progress,
        SUM(CASE WHEN d.order_status = 'delivery' THEN 1 ELSE 0 END) AS orders_delivery,
        SUM(CASE WHEN d.order_status = 'done' THEN 1 ELSE 0 END) AS orders_completed,
        SUM(CASE WHEN d.order_status != 'done' THEN 1 ELSE 0 END) AS orders_not_completed,
        d.report_period
    FROM dwh_delta d
    GROUP BY d.customer_id, d.customer_name, d.customer_address, d.customer_birthday, d.customer_email, d.report_period
),
-- Удаление старых данных для пересчёта
deleted_data AS (
    DELETE FROM dwh.customer_report_datamart
    WHERE report_period IN (SELECT DISTINCT report_period FROM dwh_delta)
    RETURNING *
),
-- Вставка новых данных
inserted_data AS (
    INSERT INTO dwh.customer_report_datamart (
        customer_id, customer_name, customer_address, customer_birthday, customer_email,
        customer_spent, platform_earned, orders_count, avg_order_price, median_order_time,
        top_product_category, top_craftsman_id, orders_created, orders_in_progress,
        orders_delivery, orders_completed, orders_not_completed, report_period
    )
    SELECT
        customer_id, customer_name, customer_address, customer_birthday, customer_email,
        customer_spent, platform_earned, orders_count, avg_order_price, median_order_time,
        top_product_category, top_craftsman_id, orders_created, orders_in_progress,
        orders_delivery, orders_completed, orders_not_completed, report_period
    FROM aggregated_data
)
-- Логирование загрузки
INSERT INTO dwh.load_dates_customer_report_datamart (load_dttm)
VALUES (CURRENT_TIMESTAMP);
