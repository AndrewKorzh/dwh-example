DROP TABLE IF EXISTS bdl_m.t_retail_chain_margin_fact;

CREATE TABLE bdl_m.t_retail_chain_margin_fact (
    retail_chain varchar(20) NOT NULL,
    retail_chain_name varchar(100) NOT NULL,
    plant_code varchar(40) NOT NULL,
    plant_name varchar(200) NULL,
    product_group_code varchar(20) NOT NULL,
    product_group_name varchar(200) NULL,
    fiscal_year integer NOT NULL,
    fiscal_period integer NOT NULL,
    fiscal_date date NULL,
    planned_margin_percent numeric(10,4) NULL,
    planned_margin_amount numeric(25,2) NULL,
    planned_gmv numeric(25,2) NULL,
    planned_discount_budget numeric(25,2) NULL,
    approval_status varchar(20) NULL,
    is_approved boolean NULL,
    approved_dt timestamp(0) NULL,
    valid_from_dt timestamp(0) NULL,
    valid_to_dt timestamp(0) NULL,
    valid_st integer NULL,
    inserted_dt timestamp(0) NULL,
    updated_dt timestamp(0) NULL,
    key_hash varchar(80) NULL,
    value_hash varchar(80) NULL,
    inserted_by varchar(100) NULL,
    updated_by varchar(100) NULL
)
WITH (
    appendonly=true,
    orientation=column,
    compresstype=zstd,
    compresslevel=3
)
DISTRIBUTED BY (retail_chain, fiscal_year, fiscal_period);

comment on table bdl_m.t_retail_chain_margin_fact is 'Витрина: объединенная фактовая статистика по плановой маржинальности всех розничных сетей';
comment on column bdl_m.t_retail_chain_margin_fact.retail_chain is '(PK) Код розничной сети: X5, MAGNIT, LENTA, AUCHAN';
comment on column bdl_m.t_retail_chain_margin_fact.retail_chain_name is 'Наименование розничной сети';
comment on column bdl_m.t_retail_chain_margin_fact.plant_code is '(PK) Код распределительного центра';
comment on column bdl_m.t_retail_chain_margin_fact.plant_name is 'Наименование распределительного центра';
comment on column bdl_m.t_retail_chain_margin_fact.product_group_code is '(PK) Код товарной группы';
comment on column bdl_m.t_retail_chain_margin_fact.product_group_name is 'Наименование товарной группы';
comment on column bdl_m.t_retail_chain_margin_fact.fiscal_year is '(PK) Фискальный год';
comment on column bdl_m.t_retail_chain_margin_fact.fiscal_period is '(PK) Фискальный период (1-12)';
comment on column bdl_m.t_retail_chain_margin_fact.fiscal_date is 'Первое число фискального периода для удобства аналитики';
comment on column bdl_m.t_retail_chain_margin_fact.planned_margin_percent is 'Плановая маржинальность в процентах';
comment on column bdl_m.t_retail_chain_margin_fact.planned_margin_amount is 'Плановая маржинальность в рублях';
comment on column bdl_m.t_retail_chain_margin_fact.planned_gmv is 'Плановый оборот (GMV) в рублях';
comment on column bdl_m.t_retail_chain_margin_fact.planned_discount_budget is 'Плановый бюджет на скидки в рублях';
comment on column bdl_m.t_retail_chain_margin_fact.approval_status is 'Статус утверждения плана';
comment on column bdl_m.t_retail_chain_margin_fact.is_approved is 'Флаг утверждения: TRUE если статус APPROVED';
comment on column bdl_m.t_retail_chain_margin_fact.approved_dt is 'Дата утверждения плана';
comment on column bdl_m.t_retail_chain_margin_fact.valid_from_dt is 'Начало действия записи';
comment on column bdl_m.t_retail_chain_margin_fact.valid_to_dt is 'Окончание действия записи';
comment on column bdl_m.t_retail_chain_margin_fact.valid_st is 'Статус валидности: 1-валидна, 0-невалидна, 2-удалена';
comment on column bdl_m.t_retail_chain_margin_fact.inserted_dt is 'Дата вставки записи';
comment on column bdl_m.t_retail_chain_margin_fact.updated_dt is 'Дата обновления записи';
comment on column bdl_m.t_retail_chain_margin_fact.key_hash is 'MD5-хэш ключевых полей';
comment on column bdl_m.t_retail_chain_margin_fact.value_hash is 'MD5-хэш бизнес-полей';
comment on column bdl_m.t_retail_chain_margin_fact.inserted_by is 'Кто добавил запись';
comment on column bdl_m.t_retail_chain_margin_fact.updated_by is 'Кто обновил запись';