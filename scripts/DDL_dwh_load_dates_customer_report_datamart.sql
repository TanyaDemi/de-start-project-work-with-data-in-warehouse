-- Удаление таблицы инкрементальных загрузок (если существует)
DROP TABLE IF EXISTS dwh.load_dates_customer_report_datamart;

-- Создание таблицы инкрементальных загрузок
CREATE TABLE IF NOT EXISTS dwh.load_dates_customer_report_datamart (
id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL, -- Идентификатор записи
load_dttm TIMESTAMP NOT NULL, -- Дата и время загрузки
CONSTRAINT load_dates_customer_report_datamart_pk PRIMARY KEY (id)
);
