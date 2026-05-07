DROP TABLE IF EXISTS ods_lenta.t_margin_plan;

CREATE TABLE ods_lenta.t_margin_plan (
    plant_code varchar(40) NOT NULL,
    plant_name varchar(200) NULL,
    product_group_code varchar(20) NOT NULL,
    product_group_name varchar(200) NULL,
    fiscal_year integer NOT NULL,
    fiscal_period integer NOT NULL,
    planned_margin_percent numeric(10,4) NULL,
    planned_margin_amount numeric(25,2) NULL,
    planned_gmv numeric(25,2) NULL,
    planned_discount_budget numeric(25,2) NULL,
    approval_status varchar(20) NULL,
    approved_by varchar(100) NULL,
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
DISTRIBUTED BY (plant_code, product_group_code);

comment on table ods_lenta.t_margin_plan is 'Плановая маржинальность по РЦ и товарным группам Лента';
comment on column ods_lenta.t_margin_plan.plant_code is '(PK) Код распределительного центра Лента';
comment on column ods_lenta.t_margin_plan.plant_name is 'Наименование распределительного центра';
comment on column ods_lenta.t_margin_plan.product_group_code is '(PK) Код товарной группы (уровень категории)';
comment on column ods_lenta.t_margin_plan.product_group_name is 'Наименование товарной группы';
comment on column ods_lenta.t_margin_plan.fiscal_year is '(PK) Фискальный год';
comment on column ods_lenta.t_margin_plan.fiscal_period is '(PK) Фискальный период/месяц (1-12)';
comment on column ods_lenta.t_margin_plan.planned_margin_percent is 'Плановая маржинальность в процентах';
comment on column ods_lenta.t_margin_plan.planned_margin_amount is 'Плановая маржинальность в рублях';
comment on column ods_lenta.t_margin_plan.planned_gmv is 'Плановый GMV (Gross Merchandise Value) в рублях';
comment on column ods_lenta.t_margin_plan.planned_discount_budget is 'Плановый бюджет на скидки и промо в рублях';
comment on column ods_lenta.t_margin_plan.approval_status is 'Статус утверждения плана: DRAFT, APPROVED, REJECTED, ARCHIVED';
comment on column ods_lenta.t_margin_plan.approved_by is 'Кто утвердил план (username)';
comment on column ods_lenta.t_margin_plan.approved_dt is 'Дата и время утверждения плана';
comment on column ods_lenta.t_margin_plan.valid_from_dt is 'Дата и время, начиная с которой запись валидна';
comment on column ods_lenta.t_margin_plan.valid_to_dt is 'Дата и время до которого запись валидна';
comment on column ods_lenta.t_margin_plan.valid_st is 'Вспомогательное. Статус валидности: 1 - валидна, 0 - невалидна, 2 - удалена';
comment on column ods_lenta.t_margin_plan.inserted_dt is 'Дата и время добавления записи';
comment on column ods_lenta.t_margin_plan.updated_dt is 'Дата и время обновления записи';
comment on column ods_lenta.t_margin_plan.key_hash is 'MD5-хэш по всем ключевым полям (plant_code, product_group_code, fiscal_year, fiscal_period)';
comment on column ods_lenta.t_margin_plan.value_hash is 'MD5-хэш по всем значимым бизнес-полям (плановые показатели)';
comment on column ods_lenta.t_margin_plan.inserted_by is 'Кем добавлена запись (username)';
comment on column ods_lenta.t_margin_plan.updated_by is 'Кем обновлена запись (username)';