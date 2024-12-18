-- DDL для витрины dwh.customer_report_datamart и инкрементальной таблицы загрузок

-- Удаление таблицы витрины (если существует)
DROP TABLE IF EXISTS dwh.customer_report_datamart;

-- Создание таблицы витрины
CREATE TABLE IF NOT EXISTS dwh.customer_report_datamart (
id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL, -- Идентификатор записи
customer_id BIGINT NOT NULL, -- Идентификатор заказчика
customer_name VARCHAR NOT NULL, -- Ф. И. О. заказчика
customer_address VARCHAR NOT NULL, -- Адрес заказчика
customer_birthday DATE NOT NULL, -- Дата рождения заказчика
customer_email VARCHAR NOT NULL, -- Электронная почта заказчика
customer_spent NUMERIC(15,2) NOT NULL, -- Сумма, которую потратил заказчик за месяц
platform_earned NUMERIC(15,2) NOT NULL, -- Сумма, которую заработала платформа (10% от customer_spent)
orders_count BIGINT NOT NULL, -- Количество заказов заказчика за месяц
avg_order_price NUMERIC(10,2) NOT NULL, -- Средняя стоимость заказа
median_order_time NUMERIC(10,1), -- Медианное время выполнения заказа
top_product_category VARCHAR NOT NULL, -- Самая популярная категория товаров
top_craftsman_id BIGINT NOT NULL, -- Идентификатор самого популярного мастера
orders_created BIGINT NOT NULL, -- Количество созданных заказов
orders_in_progress BIGINT NOT NULL, -- Количество заказов в процессе изготовления
orders_delivery BIGINT NOT NULL, -- Количество заказов в доставке
orders_completed BIGINT NOT NULL, -- Количество завершённых заказов
orders_not_completed BIGINT NOT NULL, -- Количество незавершённых заказов
report_period VARCHAR NOT NULL, -- Отчётный период (год-месяц)
CONSTRAINT customer_report_datamart_pk PRIMARY KEY (id)
);
