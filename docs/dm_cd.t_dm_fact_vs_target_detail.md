Таблица dm_cd.t_dm_fact_vs_target_detail.md
======================================================
Базовая таблица фактов - Union таблиц:
fct_primary_sales, target, Open_orders, Orders. Используется для построения отчета CCD dashboard New - RUB DAILY PRIMARY и других агрегированных витрин
---- 
Описать алгоритм формирования в хранилище.

**Список задач, связанных с объектом**:
1) Задача на разработку объекта [#1295](https://kaiten.unilever-rus.ru/1295) 
2) Задача на разработку объекта [#19781](https://kaiten.unilever-rus.ru/space/6/card/19781)

----

ETL
----
Метрика|Значение|
-----------------|-----------------|
**Актуальность данных**|Т-1|
**Глубина обновления**|2 месяца по полю fact_date|
**Способ обновления**|replace|
**Глубина хранения** |c 2022 года|
**Домены**|Customer Data|
**Периодичность обновления**|ежедневно|
**Целевое время построения**|08:00 по Москве|


Описание полей
-----

| ИМЯ ПОЛЯ         |КЛЮЧ|      ТИП ДАННЫХ |NOT NULL | ОПИСАНИЕ |ИСТОЧНИК И ТРАНСФОРМАЦИЯ ДАННЫХ|ПРИМЕР ДАННЫХ|
| -----------------|----|-----------------|---------|----------|-------------------------------|------------|
| fact_date |PK| date | |(PK)Фактическая дата|fct_billing_model.invoice_date union all t_target.date_start union all fct_open_orders.fact_date union all orders.scheduled_good_issue_date | 2024-10-01 |
| period_date | | date | |Период, первое число месяца| fct_billing_model.invoice_date union all t_target.date_start union all fct_open_orders.fact_date union all orders.scheduled_good_issue_date | 2024-10-01 |
| sales_org_code |PK,FK |varchar(5)|| (FK)->[\[bdl_m.t_mix_dim_sales_org.sales_org_code\]](dwh/business-layer/bdl_m.t_mix_dim_sales_org.md)(PK)Код сбытовой организации| fct_billing_model.sales_org_code union all t_target.sales_org_code union all dim_sales_customer.sales_organization_code union all dim_sales_org.sales_org_code | R001
| legal_entity_code|PK,FK| varchar(10)||(FK)->[\[bdl_m.t_mix_dim_legal_entity.legal_entity_code\]](dwh/business-layer/bdl_m.t_mix_dim_legal_entity.md) (PK)Код юр.лица|fct_billing_model.legal_entity_code union all t_target.legal_entity_code union all dim_sales_org.comp_code | 4667 |
| sales_customer_id |PK,FK | varchar(32)| |(FK)->[\[bdl_m.t_sap_dim_sales_customer.sales_customer_id\]](dwh/business-layer/bdl_m.t_sap_dim_sales_customer.md) (PK)Идентификатор клиента| md5(concat_ws('#',coalesce(fct_billing_model.sales_customer_code,''),coalesce(fct_billing_model.sales_org_code,''))) union all t_target.sales_customer_id union all md5(concat_ws('#',coalesce(fct_open_orders.sales_customer_code,''),coalesce(fct_open_orders.sales_org_code,''))) union all md5(concat_ws('#',coalesce(orders.ship_to_code,''),coalesce(orders.sales_org_code,''))) | 412d3f7afbf03c513f6f6faf5e46def7 |
| material_code |PK,FK | varchar(32)| |(FK)->[\[bdl_m.t_sap_dim_material.material_code\]](dwh/business-layer/bdl_m.t_sap_dim_material.md) (PK)Код продукта или составляющей препака|fct_billing_model.material_code union all t_target.material_code union all fct_open_orders.material_code union all orders.material_code | 69983808|
| line_number |PK | varchar(10)| |(PK)Номер строки в Order/Invoice/Delivery|fct_billing_model.line_number union all null as line_number union all fct_open_orders.line_number union all orders.line_number | 40|
| source_code |PK | int2| |(PK) Источник данных (billing/order/target) 1 – первичные продажи за текущий месяц 2 – первичный таргет за текущий месяц 3 – открытые ордера за текущий месяц 4 – ордера за текущий месяц 5 – первичные продажи за предыдущий месяц (для Actual2) 6 – первичный таргет для новинок за текущий месяц (Target2) 7 – открытые ордера за предыдущий месяц (для оценки Actual2)| 1 as source_code union all 2 as source_code union all 3 as source_code  union all 4 as source_code union all 5 as source_code union all 6 as source_code | 1 |
| rate_code | |varchar(80) | |(FK)->[\[bdl_m.t_mix_fct_rate.rate_code\]](dwh/business-layer/bdl_m.t_mix_fct_rate.md)(PK)Код Валютного курса| | 190 |
| rate| |numeric(10,5)| | Валютный курс| | 90.86246 |
| primary_qty| |numeric(34,4)|  |Actual billed quantity (фактическое кол-во), содержит кол-во в коробках
| is_refine | |	int| |Фильтр для отображения первичных продаж с учетом очистки
| standart_sales ||	int| |Фильтр для отображения
| data_source_code||int2| |Источник данных
| order_period ||varchar(256)| |Период заказа - текущий или будущий месяца
| invoice_number |PK|varchar(80)| |(PK)Primary Invoice Number
| so_number |PK |varchar(255)| |(PK)Sales Order number
| order_status |  | varchar(10)| |Order Status
| reject_reason | |	varchar(2)| |Rejection Reason
| so_date | |date| |Created on
| rdc_code |FK|	varchar(10)| |(FK)->[\[bdl_m.t_mix_dim_rdc.rdc_code\]](dwh/business-layer/t_mix_dim_rdc.md)RDC
| delivery_number | |varchar(255)	| |Reference doc.
| delivery_date | |date | |Actual Goods Movement Date
| primary_gsv_open_order | |	numeric(34,4)| |Сумма незакрытых позиций заказа по цене GSV|
| invoice_in_order_gsv | |numeric(34,4)| |Сумма уже состоявшихся первичных продаж по ордеру в GSV
| primary_qty_open_order | |	numeric(34,4)| |Объем незакрытых позиций заказа (коробок)|
| invoice_in_order_qty | |	numeric(34,4)| |Actual billed quantity (фактическое кол-во), содержит кол-во в коробках|
| primary_qty_open_order_conf | |	numeric(34,4)| |Количество Confirmed в открытом ордере (коробок)|
| primary_gsv_open_order_conf | |	numeric(34,4)| |Сумма Confirmed по цене GSV|
| primary_niv_open_order_conf | |	numeric(34,4)| |Сумма Confirmed по цене NIV|
| invoice_in_order_niv | |numeric(34,4)| |Сумма уже состоявшихся первичных продаж по ордеру в NIV
| primary_niv_open_order | |	numeric(34,4)||Сумма незакрытых позиций заказа по цене NIV|
| primary_gsv_act | |	numeric(34,4)| |Сумма первичных продаж в GSV
| primary_niv_act | |	numeric(34,4)| |Net value of the billing item in document currency
| primary_niv_act_eur 	| |numeric(34,4)| |Net value of the billing item in document currency (EUR)
| primary_gsv_act_eur | |	numeric(34,4)| |Сумма первичных продаж  в GSV (EUR)
| primary_zcu_act  | |	numeric(34,4)| | Actual billed quantity (фактическое кол-во), содержит кол-во в штуках
| primary_gsv_tgt | |	numeric(34,4)| |План продаж в национальной валюте (GSV)
| primary_niv_tgt  |  | numeric(34,4)  |  | План продаж в национальной валюте (NIV)|
| order_lce_qty | | numeric(34,4)  |  |Количество, заказанное клиентом в коробках, которое учитывается при расчете DR
| primary_qty_total_order  | | numeric(34,4)  |  |Количество в заказе в коробках
| primary_qty_total_order_conf | | numeric(34,4)  |  |Подтвержденное количество в заказе в коробках
| invoice_in_total_order_qty | | numeric(34,4)  |  |Количество в коробках уже состоявшихся первичных продаж по ордеру
| order_lce_gsv | | numeric(34,4)  |  | Gross Sales Value
| primary_gsv_total_order | | numeric(34,4)  |  | Заказы в GSV
| primary_gsv_total_order_conf | | numeric(34,4)  |  |Заказы в GSV, подтвержденные процедурой Подтверждения стока в заказах к отгрузке
| order_lce_niv | | numeric(34,4)  |  | Сумма заказа LCE по цене NIV
| primary_niv_total_order  | | numeric(34,4)  |  |Заказы в NIV
| primary_niv_total_order_conf | | numeric(34,4)  |  |Заказы в NIV, подтвержденные процедурой Подтверждения стока в заказах к отгрузке
| tts_on_abs | | numeric(34,4)  || Размер скидки по счетфактуре в рублях |
| ppr | | numeric(34,4)  || Subtotal 5 from pricing procedure for condition |
| tpr| |  numeric(34,4) | |Subtotal 4 from pricing procedure for condition|
| primary_weight_net_kg| |  numeric(34,4) ||Объем первичных продаж в кг  | 
| tts_on_abs_eur | |	numeric(34,4)| | Размер скидки по счетфактуре в евро|
| ppr_eur | |	numeric(34,4)| |Subtotal 5 from pricing procedure for condition,EUR |
| tpr_eur | |	numeric(34,4)| |Subtotal 4 from pricing procedure for condition,EUR|
| primary_gsv_tgt_eur | |	numeric(34,4)| |План продаж в национальной валюте (GSV),EUR|
| primary_niv_tgt_eur | |	numeric(34,4)| |План продаж в национальной валюте (NIV),EUR|
| filter_standart_sales_refined_primary | |int| |Filter_Standart Sales - Refined - Primary
| filter_standart_sales_initial | |int| |Filter_Standart Sales - Initial - Primary
| primary_gsv_tgt2 | | numeric(34,4) | | Tаргет Primary (target Fix) на список МРДР, учаcтвующих в запуске Top NPD в GSV|
| primary_gsv_act2 | | numeric(34,4) | | Cумма продаж МРДР, учаcтвующих в запуске Top NPD, за период запуска + 1 месяц ранее в GSV|
| primary_qty_act2 | | numeric(34,4) | | Cумма продаж МРДР, учаcтвующих в запуске Top NPD, за период запуска + 1 месяц ранее в QTY|
| primary_gsv_open_order_conf_act2 | | numeric(34,4) | | Cумма подтвержденных заказов по МРДР, учаcтвующих в запуске Top NPD в GSV|
| primary_gsv_open_order_act2 | | numeric(34,4) | | Cумма открытых заказов по МРДР, учаcтвующих в запуске Top NPD в GSV|
| primary_qty_open_order_conf_act2 | | numeric(34,4) | | Cумма подтвержденных заказов по МРДР, учаcтвующих в запуске Top NPD в QTY|
| primary_qty_open_order_act2 | | numeric(34,4) | | Cумма открытых заказов по МРДР, учаcтвующих в запуске Top NPD в QTY|
| valid_from_dt            |    |   timestamp(0)   |  Y| Дата и время, начиная с которой запись валидна  |
| valid_to_dt           |     | timestamp(0)  |  Y| Дата и время до которого запись валидна  |
| valid_st            |     |  integer   | Y| Вспомогательное. Статус валидности: 1 - валидна, 0 - невалидна, 2 - удалена  |
| inserted_dt   |  |  timestamp(0)    |Y| Дата и время добавления записи |
| updated_dt         |     | timestamp(0) |   | Дата и время обновления записи |
| key_hash             |     | varchar(80)  | Y | MD5-хэш по всем ключевым полям  |
| value_hash            |     | varchar(80)  | Y | MD5-хэш по всем значимым бизнес-полям  |
| inserted_by           |     | varchar(100)  |  Y|   Кем добавлена запись (username)  |
| updated_by       |     | varchar(100)  |  |  Кем обновлена запись (username)|


SQL 
----

<details><summary>DDL</summary>

```sql
create table dm_cd.t_dm_fact_vs_target_detail
(
 fact_date   date  NULL,
 period_date   date  NULL,
 sales_org_code  varchar(5) NULL,
 legal_entity_code  varchar(10) NULL,
 sales_customer_id   varchar(32) NULL,
 material_code   varchar(32) NULL,
 line_number   varchar(10) NULL,
 source_code   int2 NULL,
 rate_code  varchar(80)  NULL,
 rate numeric(10,5) NULL,
 primary_qty numeric(34,4) NULL,
 is_refine   int NULL,
 standart_sales   int NULL,
 data_source_code int2 NULL,
 order_period  varchar(256) NULL,
 invoice_number  varchar(80) NULL,
 so_number  varchar(255) NULL,
 order_status   varchar(10) NULL,
 reject_reason   varchar(2) NULL,
 so_date  date NULL,
 rdc_code   varchar(10) NULL,
 delivery_number  varchar(255)    NULL,
 delivery_date  date  NULL,
 primary_gsv_open_order      numeric(34,4) NULL,
 invoice_in_order_gsv  numeric(34,4) NULL,
 primary_qty_open_order      numeric(34,4) NULL,
 invoice_in_order_qty    numeric(34,4) NULL,
 primary_qty_open_order_conf     numeric(34,4) NULL,
 primary_gsv_open_order_conf     numeric(34,4) NULL,
 primary_niv_open_order_conf     numeric(34,4) NULL,
 invoice_in_order_niv  numeric(34,4) NULL,
 primary_niv_open_order      numeric(34,4) NULL,
 primary_gsv_act     numeric(34,4) NULL,
 primary_niv_act     numeric(34,4) NULL,
 primary_niv_act_eur    numeric(34,4) NULL,
 primary_gsv_act_eur     numeric(34,4) NULL,
 primary_zcu_act     numeric(34,4) NULL,
 primary_gsv_tgt     numeric(34,4) NULL,
 primary_niv_tgt    numeric(34,4)   NULL,
 order_lce_qty   numeric(34,4)   NULL,
 primary_qty_total_order    numeric(34,4)   NULL,
 primary_qty_total_order_conf   numeric(34,4)   NULL,
 invoice_in_total_order_qty   numeric(34,4)   NULL,
 order_lce_gsv   numeric(34,4)   NULL,
 primary_gsv_total_order   numeric(34,4)   NULL,
 primary_gsv_total_order_conf   numeric(34,4)   NULL,
 order_lce_niv   numeric(34,4)   NULL,
 primary_niv_total_order    numeric(34,4)   NULL,
 primary_niv_total_order_conf   numeric(34,4)   NULL,
 tts_on_abs   numeric(34,4)   NULL,
 ppr   numeric(34,4)   NULL,
 tpr   numeric(34,4)  NULL,
 primary_weight_net_kg   numeric(34,4)  NULL,
 tts_on_abs_eur      numeric(34,4) NULL,
 ppr_eur     numeric(34,4) NULL,
 tpr_eur     numeric(34,4) NULL,
 primary_gsv_tgt_eur     numeric(34,4) NULL,
 primary_niv_tgt_eur     numeric(34,4) NULL,
 filter_standart_sales_refined_primary  int NULL,
 filter_standart_sales_initial  int NULL,
 primary_gsv_tgt2   numeric(34,4)  NULL,
 primary_gsv_act2   numeric(34,4)  NULL,
 primary_qty_act2   numeric(34,4)  NULL,
 primary_gsv_open_order_conf_act2   numeric(34,4)  NULL,
 primary_gsv_open_order_act2   numeric(34,4)  NULL,
 primary_qty_open_order_conf_act2   numeric(34,4)  NULL,
 primary_qty_open_order_act2   numeric(34,4)  NULL,
 key_hash varchar(80) NULL
)
WITH (
    appendonly=true,
    compresstype=zstd,
    compresslevel=3,
    orientation=column
);

```
</details>

<details><summary>историческая загрузка</summary>

```sql
insert into dm_cd.t_dm_fact_vs_target_detail (
    fact_date,
    period_date, 
    sales_org_code,
    legal_entity_code,
    sales_customer_id,
    material_code,
    line_number,
    rate_code,
    rate,
    is_refine, --is_refine_flag,
    standart_sales, --standart_sales_flag,
    data_source_code,
	filter_standart_sales_refined_primary, -- filter_standart_sales_refined_primary_flag, 
	filter_standart_sales_initial, -- filter_standart_sales_initial_flag, 
    order_period,
    invoice_number, 
    so_number,
    order_status,
    reject_reason,
    so_date,
	delivery_number, 
	delivery_date,
	primary_qty, --primary_invoice_qty,
 --   primary_gsv_amount,
 --   primary_niv_amount,
 --   primary_qty,
    primary_gsv_open_order, --   open_order_gsv_amount,
    invoice_in_order_gsv,   --  invoice_gsv_amount,
    primary_qty_open_order, -- open_order_qty,
    invoice_in_order_qty,   --invoice_qty,
    primary_qty_open_order_conf, --order_conf_qty,
    primary_gsv_open_order_conf, --order_conf_gsv_amount,
    primary_niv_open_order_conf, --order_conf_niv_amount,
    invoice_in_order_niv, --invoice_niv_amount,
    primary_niv_open_order, --open_order_niv_amount,
    primary_gsv_act, --primary_actual_gsv_amount,
    primary_niv_act, --primary_actual_niv_amount,
    primary_niv_act_eur, --primary_actual_niv_amount_eur,
    primary_gsv_act_eur, --primary_actual_gsv_amount_eur,
    primary_zcu_act, --primary_actual_zcu,
    primary_gsv_tgt, --primary_target_gsv,
    primary_niv_tgt, --primary_target_niv,
    order_lce_qty,
    primary_qty_total_order, --prim_qty_total_order, --prim_total_order_qty,
    primary_qty_total_order_conf, --prim_qty_total_order_conf, --primary_total_order_conf_qty,
    invoice_in_total_order_qty, --primary_invoice_in_total_orders_qty,
    order_lce_gsv, --order_lce_gsv_amount,
    primary_gsv_total_order, --primary_total_order_gsv_amount,
    primary_gsv_total_order_conf, --primary_total_order_conf_gsv_amount,
    order_lce_niv, --order_lce_niv_amount,
    primary_niv_total_order, --primary_total_order_niv_amount,
    primary_niv_total_order_conf, --primary_total_order_conf_niv_amount,
	tts_on_abs, --tts_on_abs_amount,
	ppr, --ppr_amount, 
	tpr, --tpr_amount, 
	primary_weight_net_kg, 
    tts_on_abs_eur, --tts_on_abs_amount_eur,
	ppr_eur, --ppr_amount_eur,
	tpr_eur, --tpr_amount_eur,
	primary_gsv_tgt_eur, --primary_target_gsv_amount_eur,
	primary_niv_tgt_eur, --primary_target_niv_amount_eur,
	primary_gsv_tgt2, --primary_target_gsv2_amount,
	primary_gsv_act2, --primary_actual_gsv2_amount,
	primary_qty_act2, --primary_actual_qty2_amount,
	primary_gsv_open_order_conf_act2, --primary_open_order_conf_actual_gsv2_amount,
	primary_gsv_open_order_act2, --primary_open_order_actual_gsv2_amount,
	primary_qty_open_order_conf_act2, --primary_open_order_conf_actual_qty2,
	primary_qty_open_order_act2, --primary_open_order_actual_qty2,
    source_code,                        --new
    rdc_code
)
WITH pre AS (
         SELECT fct_billing_model.invoice_date AS fact_date,
            date_trunc('month', fct_billing_model.invoice_date)::date AS period_date,
            fct_billing_model.sales_org_code,
            fct_billing_model.legal_entity_code AS legal_entity_code,
            md5(concat_ws('#',coalesce(fct_billing_model.sales_customer_code,''),coalesce(fct_billing_model.sales_org_code,''))) AS sales_customer_id,
            fct_billing_model.material_code,
            fct_billing_model.line_number,
			COALESCE( 
				CASE 
					WHEN fct_billing_model.uom::text = 'PC' 
                    THEN (fct_billing_model.invoice_mix_qty  / COALESCE(mu.numerator/mu.denomintr, 1))
					ELSE  fct_billing_model.invoice_mix_qty
			        END, 0) AS billing_invoice_qty,
           COALESCE(fct_billing_model.refine_flag, 0) AS is_refine,
           COALESCE(fct_billing_model.standart_sales_flag , 0) AS standart_sales,
           COALESCE(fct_billing_model.data_source_code , 0) AS data_source_code, --data_source,
		    CASE
                WHEN COALESCE(fct_billing_model.refine_flag, 0) = 1 
                AND COALESCE(fct_billing_model.standart_sales_flag, 0)  = 1 THEN 1 
                ELSE 0 
                END as  filter_standart_sales_refined_primary,  
			CASE 
                WHEN COALESCE(fct_billing_model.data_source_code, 0) != 3 
                AND COALESCE(fct_billing_model.standart_sales_flag, 0) = 1 THEN 1 
                ELSE 0 
                END as filter_standart_sales_initial,  			
            COALESCE(CASE
                        WHEN fct_billing_model.uom= 'CS' 
                        THEN fct_billing_model.invoice_mix_qty * COALESCE(mu.numerator/mu.denomintr, 1)              
                        ELSE fct_billing_model.invoice_mix_qty
                        END, 0) AS primary_zcu_act,
            COALESCE(fct_billing_model.primary_gsv_amount, 0) AS primary_gsv_act,  --COALESCE(fct_billing_model.sal_gsv_amount, 0) AS primary_gsv_act,
            COALESCE(fct_billing_model.primary_niv_amount, 0) AS primary_niv_act,  --COALESCE(fct_billing_model.net_value_amount, 0) AS primary_niv_act,
            0 AS primary_gsv_tgt,
            0 AS primary_niv_tgt,
            0 AS gsv_prim,
            0 AS niv_prim,
            0 AS qty_prim,
            0 AS open_order_gsv,
            0 AS invoice_gsv,
            0 AS open_order_qty,
            0 AS invoice_qty, 
            0 AS order_conf_qty,
            0 AS order_conf_gsv,
            0 AS order_conf_niv,
            0 AS invoice_niv,
            0 AS open_order_niv,
            NULL AS order_period,
            0 AS primary_gsv_open_order,
            fct_billing_model.invoice_number,
            fct_billing_model.so_number,
            NULL AS order_status,
            NULL AS reject_reason, --reason_for_reject,
            o.so_date AS so_date, 
            0 AS cs_lce_qty,
            0 AS cs_order_qty,
            0 AS cs_confirmed_qty,
            0 AS order_invoice_qty,
            0 AS gsv_value,
            0 AS cs_order_gsv,
            0 AS cs_order_conf_gsv,
            0 AS net_price,
            0 AS cs_order_niv,
            0 AS cs_order_conf_niv,
			fct_billing_model.delivery_number, 
			fct_billing_model.delivery_date,
			(COALESCE(fct_billing_model.primary_gsv_amount, 0) - COALESCE(fct_billing_model.primary_niv_amount, 0)) AS tts_on_abs, --(COALESCE(fct_billing_model.sal_gsv_amount, 0) - COALESCE(fct_billing_model.net_value_amount, 0)) AS tts_on_abs, 
			fct_billing_model.ppr_amount as ppr, 
			fct_billing_model.tpr_amount as tpr,
            ((CASE 
                WHEN fct_billing_model.uom = 'PC'  
			    THEN (COALESCE(fct_billing_model.invoice_mix_qty,0)/COALESCE(mu.numerator/mu.denomintr,1)) 
			    ELSE COALESCE(fct_billing_model.invoice_mix_qty,0) end ) * COALESCE(CASE 
                    WHEN dim_material.weight_measure_unit = 'G' 
					THEN dim_material.net_weight*(mu.numerator/mu.denomintr)/1000 --COALESCE(dim_material.net_weight,0))
       				ELSE dim_material.net_weight*(mu.numerator/mu.denomintr)/*/1000*/ END,0))
         as primary_weight_net_kg,
--			((CASE 
--					WHEN fct_billing_model.uom = 'PC' THEN 
--						 (COALESCE(fct_billing_model.invoice_mix_qty,0)/COALESCE(mu.numerator/mu.denomintr,1)) 
--							ELSE COALESCE(fct_billing_model.invoice_mix_qty,0) end ) * COALESCE(dim_material.net_weight,0))
--									as primary_weight_net_kg,
			1 as source_code,
			dim_plant.rdc_code AS rdc_code
           FROM bdl_m.vv_sap_fct_primary_sales fct_billing_model
           LEFT JOIN bdl_m.vv_sap_fct_orders_full o
        		ON fct_billing_model.so_number = o.so_number
        		AND fct_billing_model.line_number = o.line_number
                AND fct_billing_model.sales_org_code  = o.sales_org_code
			LEFT JOIN dm_common.t_dim_material_full dim_material 
				ON fct_billing_model.material_code = dim_material.material_code
			left join dm_common.v_dim_mat_unit mu
				on mu.material = dim_material.material_code
				and mu.mat_unit = 'CS'
			LEFT JOIN bdl_m.vv_mix_dim_plant dim_plant 
			ON fct_billing_model.plant_code = dim_plant.plant_code
          WHERE --fct_billing_model.invoice_date >= (date_trunc('month',current_date) - interval '1 month')::date and
           fct_billing_model.doc_type in ('ZF1', 'ZF3', 'S1', 'S2', 'ZREF', 'ZRE', 'ZC1', 'ZD1') 
		  AND fct_billing_model.line_category in ('ZTAN', 'ZTNN', 'ZSAM', 'L2N', 'G2N', 'ZREN')   
UNION ALL
         SELECT t_target.date_start AS fact_date,
            t_target.date_start AS period_date,
            t_target.sales_org_code,
            t_target.legal_entity_code,
            t_target.sales_customer_id,
            t_target.material_code,
            null as line_number, --invoice_line,
            NULL AS billing_invoice_qty,
            0 AS is_refine,
            0 AS standart_sales,
            0 AS data_source_code, --data_source,
			 1 AS filter_standart_sales_refined_primary, 
			 1 AS filter_standart_sales_initial, 
            0 AS primary_zcu_act,
            0 AS primary_gsv_act,
            0 AS primary_niv_act,
                CASE
                    WHEN sum(coalesce(t_target.qty_prim,0)) + sum(coalesce(t_target.niv_prim,0)) + sum(coalesce(t_target.gsv_prim,0))  <> 0 THEN coalesce(sum(t_target.gsv_prim), 0)
                    ELSE 0
                END AS primary_gsv_tgt,
                CASE
                    WHEN sum(coalesce(t_target.qty_prim,0)) + sum(coalesce(t_target.niv_prim,0)) + sum(coalesce(t_target.gsv_prim,0)) <> 0 THEN COALESCE(sum(t_target.niv_prim), 0)
                    ELSE 0
                END AS primary_niv_tgt,
            sum(COALESCE(t_target.gsv_prim, 0)) AS gsv_prim,
            sum(COALESCE(t_target.niv_prim, 0)) AS niv_prim,
            sum(COALESCE(t_target.qty_prim, 0)) AS qty_prim,
            0 AS open_order_gsv,
            0 AS invoice_gsv,
            0 AS open_order_qty,
            0 AS invoice_qty,  
            0 AS order_conf_qty,
            0 AS order_conf_gsv,
            0 AS order_conf_niv,
            0 AS invoice_niv,
            0 AS open_order_niv,
            NULL AS order_period,
            0 AS primary_gsv_open_order,
            null AS invoice_number,
            NULL AS so_number,
            NULL AS order_status,
            NULL AS reject_reason, --reason_for_reject,
            NULL AS so_date,
            0 AS cs_lce_qty,
            0 AS cs_order_qty,
            0 AS cs_confirmed_qty,
            0 AS order_invoice_qty,
            0 AS gsv_value,
            0 AS cs_order_gsv,
            0 AS cs_order_conf_gsv,
            0 AS net_price,
            0 AS cs_order_niv,
            0 AS cs_order_conf_niv,
			NULL AS delivery_number, 
			null AS delivery_date,
			0 AS tts_on_abs, 
			0 AS ppr,
			0 AS tpr,  
			0 AS primary_weight_net_kg,
			2 as source_code,
			NULL AS rdc_code
           FROM bdl_m.vv_mix_dim_target_fix t_target
           --WHERE t_target.date_start >= (date_trunc('month',current_date) - interval '1 month')::date
           group by 
            t_target.date_start,
            t_target.sales_org_code,
            t_target.legal_entity_code,
            t_target.sales_customer_id,
            t_target.material_code
UNION ALL
         SELECT fct_open_orders.fact_date, --fct_open_orders.CALENDAR_DATE  AS fact_date,  
            date_trunc('month', fct_open_orders.fact_date)::date AS period_date,
            --date_trunc('month', fct_open_orders.CALENDAR_DATE)::date AS period_date,  
            dim_sales_customer.sales_organization_code as sales_org_code,
            dim_sales_org.comp_code as legal_entity_code,
            md5(concat_ws('#',coalesce(fct_open_orders.sales_customer_code,''),coalesce(fct_open_orders.sales_org_code,'')))  AS sales_customer_id, --md5(concat_ws('#',coalesce(fct_open_orders.sold_to_sc_code,''),coalesce(fct_open_orders.sales_org_code,'')))  AS sales_customer_id,
            fct_open_orders.material_code,
            fct_open_orders.line_number, 
            NULL AS billing_invoice_qty,
            0 AS is_refine,
            0 AS standart_sales,
            0 AS data_source_code, --data_source,
			1 AS filter_standart_sales_refined_primary, 
			1 AS filter_standart_sales_initial, 
            0 AS primary_zcu_act,
            0 AS primary_gsv_act,
            0 AS primary_niv_act,
            0 AS primary_gsv_tgt,
            0 AS primary_niv_tgt,
            0 AS gsv_prim,
            0 AS niv_prim,
            0 AS qty_prim,
            COALESCE(fct_open_orders.open_order_gsv_amount , 0) AS open_order_gsv,
            COALESCE(fct_open_orders.invoice_in_order_gsv_amount, 0) AS invoice_gsv, -- COALESCE(fct_open_orders.invoice_gsv_amount, 0) AS invoice_gsv,
            COALESCE(fct_open_orders.open_order_qty, 0) AS open_order_qty,
            COALESCE(fct_open_orders.invoice_in_order_qty, 0) AS invoice_qty,    --COALESCE(fct_open_orders.invoice_qty, 0) AS invoice_qty,  
            COALESCE(fct_open_orders.order_conf_qty, 0) AS order_conf_qty,
			CASE
                WHEN (COALESCE(fct_open_orders.order_conf_qty, 0) - COALESCE(fct_open_orders.invoice_in_order_qty, 0)) = 0 THEN 0 --WHEN (COALESCE(fct_open_orders.order_conf_qty, 0) - COALESCE(fct_open_orders.invoice_qty, 0)) = 0 THEN 0
                ELSE COALESCE(fct_open_orders.order_conf_gsv_amount, 0) - COALESCE(fct_open_orders.invoice_in_order_gsv_amount, 0)
            END AS order_conf_gsv,
			COALESCE(fct_open_orders.order_conf_niv_amount, 0) - COALESCE(fct_open_orders.invoice_in_order_niv_amount, 0) AS order_conf_niv,  --COALESCE(fct_open_orders.order_conf_niv_amount, 0) - COALESCE(fct_open_orders.invoice_niv_amount, 0) AS order_conf_niv,
            COALESCE(fct_open_orders.invoice_in_order_niv_amount, 0) AS invoice_niv,  -- COALESCE(fct_open_orders.invoice_niv_amount, 0) AS invoice_niv,
            COALESCE(fct_open_orders.open_order_niv_amount, 0) AS open_order_niv,
            fct_open_orders.order_period,
			0 AS primary_gsv_open_order,
            NULL AS invoice_number,
            fct_open_orders.so_number::text AS so_number,
            'Open' AS order_status, 
            fct_open_orders.reject_reason, 
            fct_open_orders.so_date AS so_date, 
            0 AS cs_lce_qty,
            0 AS cs_order_qty,
            0 AS cs_confirmed_qty,
            0 AS order_invoice_qty,
            0 AS gsv_value,
            0 AS cs_order_gsv,
            0 AS cs_order_conf_gsv,
            0 AS net_price,
            0 AS cs_order_niv,
            0 AS cs_order_conf_niv,
			NULL AS delivery_number, 
			NULL AS delivery_date,
			0 AS tts_on_abs, 
			0 AS ppr, 
			0 AS tpr,  
			0 AS primary_weight_net_kg,
			3 as source_code,
			dim_plant.rdc_code AS rdc_code
           FROM dm_common.t_fct_open_orders fct_open_orders
           JOIN dm_common.t_dim_cust_sales_full dim_sales_customer 
             	ON dim_sales_customer.cust_sales_code= fct_open_orders.sales_customer_code  --ON dim_sales_customer.cust_sales_code= fct_open_orders.sold_to_sc_code
             	and dim_sales_customer.sales_organization_code = fct_open_orders.sales_org_code
             JOIN bdl_m.vv_sap_dim_sales_org dim_sales_org 
             	ON dim_sales_org.sales_org_code = dim_sales_customer.sales_organization_code
             LEFT JOIN bdl_m.vv_mix_dim_plant dim_plant 
             	ON fct_open_orders.plant_code = dim_plant.plant_code
--        WHERE  fct_open_orders.fact_date >= (date_trunc('month',current_date) - interval '1 month')::date         --fct_open_orders.CALENDAR_DATE >= (date_trunc('month',current_date) - interval '1 month')::date
UNION ALL
         select 
         	orders.scheduled_good_issue_date AS fact_date,
            date_trunc('month', orders.scheduled_good_issue_date)::date AS period_date,
            dim_sales_org.sales_org_code,
            dim_sales_org.comp_code as legal_entity_code, 
            md5(concat_ws('#',coalesce(orders.ship_to_code,''),coalesce(orders.sales_org_code,''))) as sales_customer_id, --sold_to_sc_id,
            orders.material_code,
            orders.line_number as line_number, --invoice_line,
            null AS billing_invoice_qty,
            0 AS is_refine,
            0 AS standart_sales,
            0 AS data_source_code, -- data_source,
			1 AS filter_standart_sales_refined_primary, 
			1 AS filter_standart_sales_initial, 
            0 AS primary_zcu_act,
            0 AS primary_gsv_act,
            0 AS primary_niv_act,
            0 AS primary_gsv_tgt,
            0 AS primary_niv_tgt,
            0 AS gsv_prim,
            0 AS niv_prim,
            0 AS qty_prim,
            0 AS open_order_gsv,
            0 AS invoice_gsv,
            0 AS open_order_qty,
            0 AS invoice_qty,   
            0 AS order_conf_qty,
            0 AS order_conf_gsv,
            0 AS order_conf_niv,
            0 AS invoice_niv,
            0 AS open_order_niv,
            NULL AS order_period,
            0 AS primary_gsv_open_order,
            null AS invoice_number,
            orders.so_number,
			case 
				when orders.order_status_flag  = 0 then 'Open'
				when orders.order_status_flag  = 1 then 'Closed'
				when orders.order_status_flag  = 2 then 'Reject'
					else 'NA' end  as order_status, --order_status_flag,
            orders.reject_reason,
            orders.so_date,
            orders.cs_lce_qty,
            orders.cs_order_qty,
            orders.cs_confirmed_qty,
            orders.invoice_in_order_qty as order_invoice_qty, --orders.invoice_qty as order_invoice_qty,
            orders.gsv_value_amount as gsv_value,
            orders.cs_order_gsv_amount as cs_order_gsv ,
            orders.cs_order_conf_gsv_amount as cs_order_conf_gsv,
            orders.net_price,
            orders.cs_order_niv_amount as cs_order_niv,
            orders.cs_order_conf_niv_amount as cs_order_conf_niv,
			NULL AS delivery_number, 
			NULL AS delivery_date,
			0 AS tts_on_abs, 
			0 AS ppr, 
			0 AS tpr,  
			0 AS primary_weight_net_kg,
			4 as source_code,
			dim_plant.rdc_code
           FROM bdl_m.vv_sap_fct_orders_full orders
             join dm_common.t_dim_cust_sales_full dim_sales_customer 
             	ON dim_sales_customer.cust_sales_code= orders.sales_customer_code --ON dim_sales_customer.cust_sales_code= orders.sold_to_sc_code
             	and dim_sales_customer.sales_organization_code = orders.sales_org_code
             JOIN  bdl_m.vv_sap_dim_sales_org dim_sales_org 
             	ON dim_sales_org.sales_org_code = dim_sales_customer.sales_organization_code
             JOIN bdl_m.vv_mix_dim_plant dim_plant 
             	ON orders.plant_code = dim_plant.plant_code
		   WHERE orders.is_standart_orders_flag = 1
--		   and  orders.scheduled_good_issue_date >= (date_trunc('month',current_date) - interval '1 month')::date
        )       
, _SoM  as ( -- сумма за прошлый месяц на первое число текущего месяца 
select 
            (date_trunc('month',fct_billing_model.invoice_date) ::date + interval '1  month')::date as first_month_date,
            fct_billing_model.sales_org_code,
            fct_billing_model.legal_entity_code AS legal_entity_code,
            md5(concat_ws('#',coalesce(fct_billing_model.sales_customer_code,''),coalesce(fct_billing_model.sales_org_code,''))) AS sales_customer_id,
            fct_billing_model.material_code,
            fct_billing_model.line_number,
			CASE
			  WHEN COALESCE(fct_billing_model.refine_flag, 0) = 1 AND COALESCE(fct_billing_model.standart_sales_flag, 0)  = 1 THEN 1 ELSE 0 END as  filter_standart_sales_refined_primary,  
			CASE 
			  WHEN COALESCE(fct_billing_model.data_source_code, 0) != 3 AND COALESCE(fct_billing_model.standart_sales_flag, 0) = 1 THEN 1 ELSE 0 END as filter_standart_sales_initial, 
			COALESCE(fct_billing_model.refine_flag, 0) AS is_refine,
            COALESCE(fct_billing_model.standart_sales_flag, 0) AS standart_sales,
            COALESCE(fct_billing_model.data_source_code, 0) AS data_source_code, --data_source,
            fct_billing_model.invoice_number,
            fct_billing_model.so_number,
            o.so_date,
			fct_billing_model.delivery_number, 
			fct_billing_model.delivery_date,
			sum(COALESCE(fct_billing_model.primary_gsv_amount, 0)) AS primary_gsv_act,   --sum(COALESCE(fct_billing_model.sal_gsv_amount, 0)) AS primary_gsv_act, 
	 		sum(COALESCE( 
				CASE 
					WHEN fct_billing_model.uom::text = 'PC' THEN (fct_billing_model.invoice_mix_qty  / COALESCE(mu.numerator/mu.denomintr, 1))
					ELSE  fct_billing_model.invoice_mix_qty
				END, 0)) AS primary_qty_act,
			fct_billing_model.plant_code
from  bdl_m.vv_sap_fct_primary_sales fct_billing_model
	LEFT JOIN bdl_m.vv_sap_fct_orders_full o
        ON fct_billing_model.so_number = o.so_number
        AND fct_billing_model.line_number = o.line_number
        AND fct_billing_model.sales_org_code  = o.sales_org_code
	LEFT JOIN dm_common.v_dim_mat_unit mu 
		ON fct_billing_model.material_code = mu.material
		and mu.mat_unit = 'CS'
	WHERE --fct_billing_model.invoice_date >= (date_trunc('month',current_date) - interval '1 month')::date and
	 fct_billing_model.doc_type in ('ZF1', 'ZF3', 'S1', 'S2', 'ZREF', 'ZRE', 'ZC1', 'ZD1') 
	AND fct_billing_model.line_category in ('ZTAN', 'ZTNN', 'ZSAM', 'L2N', 'G2N', 'ZREN')   
		  group by 
			date_trunc('month',fct_billing_model.invoice_date)::date + interval '1  month' ,
            fct_billing_model.sales_org_code,
            fct_billing_model.legal_entity_code,
            fct_billing_model.sales_customer_code,
            fct_billing_model.material_code,
            fct_billing_model.line_number,
		    fct_billing_model.refine_flag,
            fct_billing_model.standart_sales_flag,
            fct_billing_model.data_source_code,
            fct_billing_model.invoice_number,
            fct_billing_model.so_number,
            o.so_date,
			fct_billing_model.delivery_number, 
			fct_billing_model.delivery_date,
			fct_billing_model.plant_code
) 
, full_bill as ( 
			Select 
			cal.date as fact_date, 
			date_trunc('month',cal.date) ::date  as period_date,
			s.sales_org_code,
			s.legal_entity_code,
			s.sales_customer_id,
			s.material_code,
			s.line_number,
			s.filter_standart_sales_refined_primary,
			s.filter_standart_sales_initial,
			0 as primary_gsv_act,
			0 as primary_qty_act, 
			s.is_refine,
			s.standart_sales,
			s.data_source_code, --s.data_source,
			s.invoice_number,
			s.so_number,
			s.so_date,
			s.delivery_number, 
			s.delivery_date,
			CASE 
				WHEN date_part ('day', cal.date) = 1 THEN s.primary_gsv_act ELSE 0 end as primary_gsv_act_SoM, 
			CASE 
				WHEN date_part ('day', cal.date) = 1 THEN s.primary_qty_act ELSE 0 end as primary_qty_act_SoM,
				0 as primary_gsv_target2,
				0 as Primary_GSV_Open_Order_Conf,
				0 as primary_gsv_open_order,
				0 as Primary_QTY_Open_Order_Conf,
				0 as Primary_QTY_Open_Order,
				s.plant_code
			from  bdl_m.vv_mix_dim_calendar cal 
			left join _SoM  s 
			ON cal.date = s.first_month_date
			where cal.date between (date_trunc('year', current_date) - interval '2 year') :: date 
			and (date_trunc('month', current_date) + interval '1 month'):: date 
union all
SELECT      fct_billing_model.invoice_date AS fact_date,
            date_trunc('month', fct_billing_model.invoice_date)::date AS period_date,
            fct_billing_model.sales_org_code,
            fct_billing_model.legal_entity_code AS legal_entity_code,
            md5(concat_ws('#',coalesce(fct_billing_model.sales_customer_code,''),coalesce(fct_billing_model.sales_org_code,''))) AS sales_customer_id,
            fct_billing_model.material_code,
            fct_billing_model.line_number,
            CASE
			  WHEN COALESCE(fct_billing_model.refine_flag, 0) = 1 AND COALESCE(fct_billing_model.standart_sales_flag, 0)  = 1 THEN 1 ELSE 0 END as  filter_standart_sales_refined_primary,  
			CASE 
			  WHEN COALESCE(fct_billing_model.DATA_SOURCE_CODE, 0) != 3 AND COALESCE(fct_billing_model.standart_sales_flag, 0) = 1 THEN 1 ELSE 0 END as filter_standart_sales_initial,
			COALESCE(fct_billing_model.primary_gsv_amount, 0) AS primary_gsv_act,  --COALESCE(fct_billing_model.sal_gsv_amount, 0) AS primary_gsv_act, 
			COALESCE( 
				CASE 
					WHEN fct_billing_model.uom::text = 'PC' THEN (fct_billing_model.invoice_mix_qty  / COALESCE(mu.numerator/mu.denomintr, 1))
					ELSE  fct_billing_model.invoice_mix_qty
				END, 0) AS primary_qty_act,
			COALESCE(fct_billing_model.refine_flag, 0) AS is_refine,
            COALESCE(fct_billing_model.standart_sales_flag, 0) AS standart_sales,
            COALESCE(fct_billing_model.DATA_SOURCE_CODE, 0) AS data_source_code, --data_source,
            fct_billing_model.invoice_number,
            fct_billing_model.so_number,
            o.so_date,
			fct_billing_model.delivery_number, 
			fct_billing_model.delivery_date,
				0 as primary_gsv_act_SoM,
			    0 as primary_qty_act_SoM,
				0 as primary_gsv_target2,
				0 as Primary_GSV_Open_Order_Conf,
				0 as primary_gsv_open_order,
				0 as Primary_QTY_Open_Order_Conf,
				0 as Primary_QTY_Open_Order,
				fct_billing_model.plant_code
from  bdl_m.vv_sap_fct_primary_sales fct_billing_model
	LEFT JOIN dm_common.t_dim_cust_sales_full SC
		ON SC.cust_sales_code = fct_billing_model.sales_customer_code
		and sc.sales_organization_code = fct_billing_model.sales_org_code 
	left join bdl_m.vv_sap_fct_orders_full o
		ON fct_billing_model.so_number = o.so_number
		AND fct_billing_model.line_number = o.line_number
        AND fct_billing_model.sales_org_code  = o.sales_org_code
	left join dm_common.v_dim_mat_unit  mu
		ON fct_billing_model.material_code = mu.material
		and mu.mat_unit = 'CS'
	WHERE --fct_billing_model.invoice_date >= (date_trunc('month',current_date) - interval '1 month')::date and
	 fct_billing_model.doc_type in ('ZF1', 'ZF3', 'S1', 'S2', 'ZREF', 'ZRE', 'ZC1', 'ZD1') 
	AND fct_billing_model.line_category in ('ZTAN', 'ZTNN', 'ZSAM', 'L2N', 'G2N', 'ZREN')   
) 
, part_f as (
		Select 
		fb.fact_date, 
		fb.period_date,
		fb.sales_org_code,
		fb.legal_entity_code,
		fb.sales_customer_id,
		fb.material_code,
		fb.line_number,
		fb.filter_standart_sales_refined_primary,
		fb.filter_standart_sales_initial,
		fb.is_refine,
		fb.standart_sales,
		fb.data_source_code, --fb.data_source,
		fb.invoice_number,
		fb.so_number,
		fb.so_date,
		fb.delivery_number, 
		fb.delivery_date,
		NULL AS order_status,
		NULL AS order_period,
		NULL AS reject_reason, --reason_for_reject, 
		fb.primary_gsv_act_SoM as primary_gsv_act_SoM, 
		fb.primary_qty_act_SoM as primary_qty_act_SoM,
		(fb.primary_gsv_act + fb.primary_gsv_act_SoM) as GSV_act_SoM,
		(fb.primary_qty_act + fb.primary_qty_act_SoM) as QTY_act_SoM,
		0 as primary_gsv_target2,
		0 as Primary_GSV_Open_Order_Conf,
			0 as primary_gsv_open_order,
			0 as Primary_QTY_Open_Order_Conf,
			0 as Primary_QTY_Open_Order,
			5 as source_code,
			fb.plant_code
		from full_bill  fb
			join dm_common.t_dim_cust_sales_full sc
				on fb.sales_customer_id = md5(concat_ws('#',coalesce(sc.cust_sales_code,''),coalesce(sc.sales_organization_code,'')))
			left join (select  date_start ,sc.cust_hier_local_lvl2_code as customer_code, material_code, sum(GSV_PRIM) as GSV_PRIM 
						from bdl_m.vv_mix_dim_target_fix f
					join bdl_m.vv_sap_dim_cust_sales_full sc  
						on sc.cust_sales_code = f.soldto_code
						and sc.sales_organization_code = f.sales_org_code 
						and sc.cust_hier_local_lvl2_code <> 'NA'
					Where GSV_PRIM is not null and launch_indicator = 1
					--and date_start >= (date_trunc('month',current_date) - interval '1 month')::date
				group by date_start ,sc.cust_hier_local_lvl2_code, material_code) t
			on  fb.period_date = t.date_start    
			and sc.cust_hier_local_lvl2_code = t.customer_code
			and fb.material_code = t.material_code
		where t.GSV_PRIM is not null 
union all
		Select 
			t_target.date_start AS fact_date,
            t_target.date_start AS period_date,
            t_target.sales_org_code,
            t_target.legal_entity_code,
            t_target.sales_customer_id,
            t_target.material_code, 
            null as line_number, -- invoice_line,
			1 AS filter_standart_sales_refined_primary, 
			1 AS filter_standart_sales_initial, 
			0 AS is_refine,
            0 AS standart_sales,
            0 AS data_source_code, --data_source,
			NULL AS invoice_number,
            NULL AS so_number,
			NULL AS so_date,
			NULL AS delivery_number, 
			NULL AS delivery_date,
			NULL AS order_status,
			NULL AS order_period,
			NULL AS reject_reason, --reason_for_reject,  
			0 as primary_gsv_act_SoM,
			0 as primary_qty_act_SoM,
			0 as GSV_act_SoM,
			0 as QTY_act_SoM,
			sum(t_target.gsv_prim) as primary_gsv_target2,
			0 as Primary_GSV_Open_Order_Conf,
			0 as primary_gsv_open_order,
			0 as Primary_QTY_Open_Order_Conf,
			0 as Primary_QTY_Open_Order,
			6 as source_code,
			NULL AS plant_code
	 FROM bdl_m.vv_mix_dim_target_fix t_target 
		Where launch_indicator = 1 
		-- and  t_target.date_start >= (date_trunc('month',current_date) - interval '1 month')::date
	group by 
			t_target.date_start,
            t_target.date_start,
            t_target.sales_org_code,
            t_target.legal_entity_code,
            t_target.sales_customer_id,
            t_target.material_code
union all 
		Select 
			fct_open_orders.fact_date, --fct_open_orders.CALENDAR_DATE  AS fact_date,  
            date_trunc('month', fct_open_orders.fact_date)::date  AS period_date,  --date_trunc('month', fct_open_orders.CALENDAR_DATE)::date  AS period_date,  
            dim_sales_customer.sales_organization_code,
            dim_sales_org.comp_code as legal_entity_code,
            md5(concat_ws('#',coalesce(fct_open_orders.sales_customer_code,''),coalesce(fct_open_orders.sales_org_code,''))) AS sold_to_id, --md5(concat_ws('#',coalesce(fct_open_orders.sold_to_sc_code,''),coalesce(fct_open_orders.sales_org_code,''))) AS sold_to_id,
            fct_open_orders.material_code,
            fct_open_orders.line_number as line_number,
			1 AS filter_standart_sales_refined_primary, 
			1 AS filter_standart_sales_initial, 
			0 AS is_refine,
            0 AS standart_sales,
            0 AS data_source_code, --data_source,
			NULL AS invoice_number,
            fct_open_orders.so_number AS so_number,
			fct_open_orders.so_date AS so_date,
			NULL AS delivery_number, 
			NULL AS delivery_date,
			'Open' AS order_status,
			fct_open_orders.order_period,
			fct_open_orders.reject_reason, -- AS reason_for_reject,  
			0 as primary_gsv_act_SoM,
			0 as primary_qty_act_SoM,
			0 as GSV_act_SoM,
			0 as QTY_act_SoM,
			0 as primary_gsv_target2,
			CASE
                WHEN (COALESCE(fct_open_orders.order_conf_qty, 0) - COALESCE(fct_open_orders.invoice_in_order_qty, 0)) = 0 THEN 0 --WHEN (COALESCE(fct_open_orders.order_conf_qty, 0) - COALESCE(fct_open_orders.invoice_qty, 0)) = 0 THEN 0
                ELSE COALESCE(fct_open_orders.order_conf_gsv_amount, 0) - COALESCE(fct_open_orders.invoice_in_order_gsv_amount, 0)
            END AS Primary_GSV_Open_Order_Conf,
			COALESCE(fct_open_orders.order_conf_gsv_amount, 0) AS primary_gsv_open_order,
			COALESCE(fct_open_orders.order_conf_qty, 0) - COALESCE(fct_open_orders.invoice_in_order_qty, 0) as Primary_QTY_Open_Order_Conf, --COALESCE(fct_open_orders.order_conf_qty, 0) - COALESCE(fct_open_orders.invoice_qty, 0) as Primary_QTY_Open_Order_Conf,
			COALESCE(fct_open_orders.open_order_qty, 0) - COALESCE(fct_open_orders.invoice_in_order_qty, 0) as Primary_QTY_Open_Order,  --COALESCE(fct_open_orders.open_order_qty, 0) - COALESCE(fct_open_orders.invoice_qty, 0) as Primary_QTY_Open_Order,
			 7 as source_code,
			 fct_open_orders.plant_code
	From dm_common.t_fct_open_orders fct_open_orders
		JOIN dm_common.t_dim_cust_sales_full dim_sales_customer 
			ON dim_sales_customer.cust_sales_code = fct_open_orders.sales_customer_code --ON dim_sales_customer.cust_sales_code = fct_open_orders.sold_to_sc_code
			and dim_sales_customer.sales_organization_code = fct_open_orders.sales_org_code
		JOIN bdl_m.vv_sap_dim_sales_org dim_sales_org ON dim_sales_org.sales_org_code = dim_sales_customer.sales_organization_code 
		Left join (select  date_start ,sc.cust_hier_local_lvl2_code as customer_code, material_code, sum(GSV_PRIM) as GSV_PRIM 
					from bdl_m.vv_mix_dim_target_fix f
						join dm_common.t_dim_cust_sales_full sc
							on sc.cust_sales_code = f.soldto_code
							and sc.sales_organization_code = f.sales_org_code 
						   and sc.cust_hier_local_lvl2_code <> 'NA'
					Where GSV_PRIM is not null and launch_indicator = 1
					-- and date_start >= (date_trunc('month',current_date) - interval '1 month')::date
					group by date_start ,sc.cust_hier_local_lvl2_code, material_code) t
		On fct_open_orders.material_code = t.material_code
		and dim_sales_customer.cust_hier_local_lvl2_code  = t.customer_code 
		and date_trunc('month',fct_open_orders.scheduled_good_issue_date )::date = t.date_start
	where t.GSV_PRIM is not null 
	-- and  fct_open_orders.fact_date >= (date_trunc('month',current_date) - interval '1 month')::date --  fct_open_orders.CALENDAR_DATE >= (date_trunc('month',current_date) - interval '1 month')::date
)
SELECT 
    pre.fact_date as fact_date,
    pre.period_date as period_date, 
    coalesce(pre.sales_org_code, 'NA') as sales_org_code,
    coalesce(pre.legal_entity_code, 'NA') as legal_entity_code,
    coalesce(pre.sales_customer_id, 'NA') as sales_customer_id,
    coalesce(pre.material_code, 'NA') AS material_code,
    COALESCE(pre.line_number, 'NA') as line_number,
    coalesce(rt.rate_code, 'NA') AS rate_code,
    COALESCE(rt.rate, 0) AS rate,
    pre.is_refine,
    pre.standart_sales,
    pre.data_source_code,  --pre.data_source as data_source_code,
	pre.filter_standart_sales_refined_primary, -- as filter_standart_sales_refined_primary_flag, 
	pre.filter_standart_sales_initial, -- as filter_standart_sales_initial_flag, 
    pre.order_period,
    COALESCE(pre.invoice_number, 'NA') AS invoice_number, 
    COALESCE(pre.so_number, 'NA') AS so_number,
    COALESCE(pre.order_status, 'NA') AS order_status,
    COALESCE(pre.reject_reason, 'NA') AS reject_reason, --COALESCE(pre.reason_for_reject, 'NA') AS reject_reason,
    pre.so_date,
	COALESCE(pre.delivery_number, 'NA') as delivery_number, 
	pre.delivery_date,
	pre.billing_invoice_qty AS primary_qty, --primary_invoice_qty,
 --   pre.gsv_prim AS primary_gsv_amount,
 --   pre.niv_prim AS primary_niv_amount,
 --   pre.qty_prim AS primary_qty,
    pre.open_order_gsv as primary_gsv_open_order, -- open_order_gsv_amount,
    pre.invoice_gsv  AS invoice_in_order_gsv, --invoice_gsv_amount,
    pre.open_order_qty  AS primary_qty_open_order, -- open_order_qty,
    pre.invoice_qty AS invoice_in_order_qty, --invoice_qty,
    pre.order_conf_qty  AS primary_qty_open_order_conf, --order_conf_qty,
    pre.order_conf_gsv AS primary_gsv_open_order_conf, --order_conf_gsv_amount,
    pre.order_conf_niv AS primary_niv_open_order_conf, --order_conf_niv_amount,
    pre.invoice_niv AS invoice_in_order_niv, --invoice_niv_amount,
    pre.open_order_niv AS primary_niv_open_order, --open_order_niv_amount,
    pre.primary_gsv_act, -- AS primary_actual_gsv_amount,
    pre.primary_niv_act, -- AS primary_actual_niv_amount,
    COALESCE(pre.primary_niv_act / rt.rate, 0) AS primary_niv_act_eur, -- primary_actual_niv_amount_eur,
    COALESCE(pre.primary_gsv_act / rt.rate, 0) AS primary_gsv_act_eur, -- primary_actual_gsv_amount_eur,
    pre.primary_zcu_act, -- AS primary_actual_zcu,
    pre.primary_gsv_tgt, -- AS primary_target_gsv,
    pre.primary_niv_tgt, -- AS primary_target_niv,
    pre.cs_lce_qty as order_lce_qty,
    pre.cs_order_qty AS primary_qty_total_order, --prim_qty_total_order, --prim_total_order_qty,
    pre.cs_confirmed_qty AS primary_qty_total_order_conf, --prim_qty_total_order_conf, --primary_total_order_conf_qty,
    pre.order_invoice_qty AS invoice_in_total_order_qty, --primary_invoice_in_total_orders_qty,
    pre.gsv_value AS order_lce_gsv, -- order_lce_gsv_amount,
    pre.cs_order_gsv AS primary_gsv_total_order, -- primary_total_order_gsv_amount,
    pre.cs_order_conf_gsv AS primary_gsv_total_order_conf, --primary_total_order_conf_gsv_amount,
    pre.cs_lce_qty * pre.net_price AS order_lce_niv, --order_lce_niv_amount,
    pre.cs_order_niv AS primary_niv_total_order, --primary_total_order_niv_amount,
    pre.cs_order_conf_niv AS primary_niv_total_order_conf, --primary_total_order_conf_niv_amount,
	pre.tts_on_abs, -- AS tts_on_abs_amount,
	pre.ppr, --pre.ppr_amount AS ppr_amount, 
	pre.tpr, -- pre.tpr_amount AS tpr_amount, 
	pre.primary_weight_net_kg AS primary_weight_net_kg, 
    COALESCE(pre.tts_on_abs/ rt.rate, 0) AS tts_on_abs_eur, --tts_on_abs_amount_eur,
	COALESCE(pre.ppr/ rt.rate, 0) AS ppr_eur, --COALESCE(pre.ppr_amount/ rt.rate, 0) AS ppr_amount_eur,
	COALESCE(pre.tpr/ rt.rate, 0) AS tpr_eur, --COALESCE(pre.tpr_amount/ rt.rate, 0) AS tpr_amount_eur,
	COALESCE(pre.primary_gsv_tgt/ rt.rate, 0) AS primary_gsv_tgt_eur, --primary_target_gsv_amount_eur,
	COALESCE(pre.primary_niv_tgt/ rt.rate, 0) AS primary_niv_tgt_eur, --primary_target_niv_amount_eur,
	0 AS primary_gsv_tgt2, --primary_target_gsv2_amount,
	0 AS primary_gsv_act2, --primary_actual_gsv2_amount,
	0 AS primary_qty_act2, --primary_actual_qty2_amount,
	0 AS primary_gsv_open_order_conf_act2, --primary_open_order_conf_actual_gsv2_amount,
	0 AS primary_gsv_open_order_act2, --primary_open_order_actual_gsv2_amount,
	0 AS primary_qty_open_order_conf_act2, --primary_open_order_conf_actual_qty2,
	0 AS primary_qty_open_order_act2, --primary_open_order_actual_qty2,
	pre.source_code,
	COALESCE(pre.rdc_code, 'NA') AS rdc_code
   FROM pre
     LEFT JOIN bdl_m.vv_mix_fct_rate rt ON
        CASE
            WHEN pre.legal_entity_code = '4667' THEN 'RUB'
            WHEN pre.legal_entity_code = '4673' THEN 'UAH'
            ELSE pre.legal_entity_code
        END = rt.to_currency AND rt.rate_date = date_trunc('year', current_date)::date
WHERE pre.sales_org_code NOT IN   ('U001','U002','U003','U004')
UNION ALL  
Select 
	 f.fact_date, 
	 f.period_date as period_date,
	 COALESCE(f.sales_org_code, 'NA') as sales_org_code,
	 COALESCE(f.legal_entity_code, 'NA') as legal_entity_code,
	 COALESCE(f.sales_customer_id, 'NA') as sales_customer_id, --sold_to_sc_id,
	 COALESCE(f.material_code , 'NA') AS material_code,
	 COALESCE(f.line_number, 'NA') as line_number,
	 COALESCE(rt.rate_code, 'NA') AS rate_code, 
	 COALESCE(rt.rate, 0) AS rate,
	 f.is_refine,
	 f.standart_sales,
	 f.data_source_code, --f.data_source as data_source,
	 f.filter_standart_sales_refined_primary, -- as filter_standart_sales_refined_primary, 
	 f.filter_standart_sales_initial as filter_standart_sales_initial,
	 f.order_period, 
	 COALESCE(f.invoice_number, 'NA') AS invoice_number ,
	 COALESCE(f.so_number, 'NA') AS so_number,  
	 COALESCE(f.order_status, 'NA') AS order_status,  
	 COALESCE(f.reject_reason, 'NA') as reject_reason,  -- COALESCE(f.reason_for_reject, 'NA') as reject_reason, 
	 f.so_date,
	COALESCE(f.delivery_number, 'NA') as delivery_number,
	f.delivery_date,
	0 AS primary_qty, --primary_invoice_qty,
 --    0 AS gsv_prim,
 --    0 AS niv_prim,
 --    0 AS qty_prim,
    0 AS primary_gsv_open_order, --open_order_gsv,
    0 AS invoice_in_order_gsv, --invoice_gsv,
    0 AS primary_qty_open_order, --open_order_qty,
    0 AS invoice_in_order_qty, --invoice_qty,
    0 AS primary_qty_open_order_conf, --order_conf_qty,
    0 AS primary_gsv_open_order_conf, --order_conf_gsv ,
    0 AS primary_niv_open_order_conf, --order_conf_niv,
    0 AS invoice_in_order_niv, --invoice_niv,
    0 AS primary_niv_open_order, --open_order_niv,
    0 AS primary_gsv_act,
    0 AS primary_niv_act,
    0 AS primary_niv_act_eur,
    0 AS primary_gsv_act_eur,
    0 AS primary_zcu_act,
    0 AS primary_gsv_tgt,
    0 AS primary_niv_tgt,
    0 AS order_lce_qty,
    0 AS primary_qty_total_order, --prim_qty_total_order,
    0 AS primary_qty_total_order_conf, --prim_qty_total_order_conf,
    0 AS invoice_in_total_order_qty, --prim_qty_invoice_in_total_orders,
    0 AS order_lce_gsv,
    0 AS primary_gsv_total_order,      --prim_gsv_total_order,
    0 AS primary_gsv_total_order_conf, --prim_gsv_total_order_conf,
    0 AS order_lce_niv,
    0 AS primary_niv_total_order, --prim_niv_total_order,
    0 AS primary_niv_total_order_conf, --prim_niv_total_order_conf,
	0 AS tts_on_abs, 
	0 AS ppr, 
	0 AS tpr,  
	0 AS primary_weight_net_kg, 
    0 AS tts_on_abs_eur,
	0 AS ppr_eur,
	0 AS tpr_eur,
	0 AS primary_gsv_tgt_eur,
	0 AS primary_niv_tgt_eur,
	coalesce(f.primary_gsv_target2, 0) as primary_gsv_tgt2, --primary_gsv_target2, 
	coalesce(f.GSV_act_SoM,0) as primary_gsv_act2, --primary_gsv_actual2, 
	coalesce(f.QTY_act_SoM,0) as primary_qty_act2, --primary_qty_actual2, 
	coalesce(f.Primary_GSV_Open_Order_Conf,0) as primary_gsv_open_order_conf_act2, --primary_gsv_actual2_open_order_conf,
	coalesce(f.primary_gsv_open_order,0) as primary_gsv_open_order_act2, --primary_gsv_actual2_open_order,
	coalesce(f.Primary_QTY_Open_Order_Conf,0) as primary_qty_open_order_conf_act2, --primary_qty_actual2_open_order_conf,
	coalesce(f.Primary_QTY_Open_Order,0) as primary_qty_open_order_act2, --primary_qty_actual2_open_order,
	f.source_code,
	COALESCE(dim_plant.rdc_code , 'NA') AS rdc_code
From part_f f
	LEFT JOIN bdl_m.vv_mix_fct_rate rt ON
        CASE
            WHEN f.legal_entity_code = '4667' THEN 'RUB'
            WHEN f.legal_entity_code = '4673' THEN 'UAH'
            ELSE f.legal_entity_code
        END = rt.to_currency AND rt.rate_date = date_trunc('year', current_date)::date
     left join  bdl_m.vv_mix_dim_plant dim_plant 
     	ON f.plant_code = dim_plant.plant_code
Where f.sales_org_code NOT IN  ('U001','U002','U003','U004')
```
</details>



<details><summary>регламентная загрузка</summary>

```sql
WITH pre AS (
         SELECT fct_billing_model.invoice_date AS fact_date,
            date_trunc('month', fct_billing_model.invoice_date)::date AS period_date,
            fct_billing_model.sales_org_code,
            fct_billing_model.legal_entity_code AS legal_entity_code,
            md5(concat_ws('#',coalesce(fct_billing_model.sales_customer_code,''),coalesce(fct_billing_model.sales_org_code,''))) AS sales_customer_id,
            fct_billing_model.material_code,
            fct_billing_model.line_number,
			COALESCE( 
				CASE 
					WHEN fct_billing_model.uom::text = 'PC' THEN (fct_billing_model.invoice_mix_qty  / COALESCE(mu.numerator/mu.denomintr, 1))
					ELSE  fct_billing_model.invoice_mix_qty
			END, 0) AS billing_invoice_qty,
           COALESCE(fct_billing_model.refine_flag, 0) AS is_refine,
           COALESCE(fct_billing_model.standart_sales_flag , 0) AS standart_sales,
           COALESCE(fct_billing_model.data_source_code , 0) AS data_source_code, --data_source,
			CASE
			  WHEN COALESCE(fct_billing_model.refine_flag, 0) = 1 
			  	AND COALESCE(fct_billing_model.standart_sales_flag, 0)  = 1 THEN 1 
			  ELSE 0 
			 END as  filter_standart_sales_refined_primary,  
			CASE 
			  WHEN COALESCE(fct_billing_model.data_source_code, 0) != 3 
			  	AND COALESCE(fct_billing_model.standart_sales_flag, 0) = 1 THEN 1 
			  ELSE 0 
			 END as filter_standart_sales_initial,  			
            COALESCE(
                CASE
                    WHEN fct_billing_model.uom= 'CS' THEN fct_billing_model.invoice_mix_qty * COALESCE(mu.numerator/mu.denomintr, 1)              
                    ELSE fct_billing_model.invoice_mix_qty
                END, 0) AS primary_zcu_act,
            COALESCE(fct_billing_model.primary_gsv_amount, 0) AS primary_gsv_act,  --COALESCE(fct_billing_model.sal_gsv_amount, 0) AS primary_gsv_act,
            COALESCE(fct_billing_model.primary_niv_amount, 0) AS primary_niv_act,  --COALESCE(fct_billing_model.net_value_amount, 0) AS primary_niv_act,
            0 AS primary_gsv_tgt,
            0 AS primary_niv_tgt,
            0 AS gsv_prim,
            0 AS niv_prim,
            0 AS qty_prim,
            0 AS open_order_gsv,
            0 AS invoice_gsv,
            0 AS open_order_qty,
            0 AS invoice_qty, 
            0 AS order_conf_qty,
            0 AS order_conf_gsv,
            0 AS order_conf_niv,
            0 AS invoice_niv,
            0 AS open_order_niv,
            NULL AS order_period,
            0 AS primary_gsv_open_order,
            fct_billing_model.invoice_number,
            fct_billing_model.so_number,
            NULL AS order_status,
            NULL AS reject_reason, --reason_for_reject,
            o.so_date AS so_date, 
            0 AS cs_lce_qty,
            0 AS cs_order_qty,
            0 AS cs_confirmed_qty,
            0 AS order_invoice_qty,
            0 AS gsv_value,
            0 AS cs_order_gsv,
            0 AS cs_order_conf_gsv,
            0 AS net_price,
            0 AS cs_order_niv,
            0 AS cs_order_conf_niv,
			fct_billing_model.delivery_number, 
			fct_billing_model.delivery_date,
			(COALESCE(fct_billing_model.primary_gsv_amount, 0) - COALESCE(fct_billing_model.primary_niv_amount, 0)) AS tts_on_abs, --(COALESCE(fct_billing_model.sal_gsv_amount, 0) - COALESCE(fct_billing_model.net_value_amount, 0)) AS tts_on_abs, 
			fct_billing_model.ppr_amount as ppr, 
			fct_billing_model.tpr_amount as tpr,
--			((CASE 
--					WHEN fct_billing_model.uom = 'PC' THEN 
--						 (COALESCE(fct_billing_model.invoice_mix_qty,0)/COALESCE(mu.numerator/mu.denomintr,1)) 
--							ELSE COALESCE(fct_billing_model.invoice_mix_qty,0) end ) * COALESCE(dim_material.net_weight,0))
--									as primary_weight_net_kg,
            ((CASE 
                WHEN fct_billing_model.uom = 'PC'  
			    THEN (COALESCE(fct_billing_model.invoice_mix_qty,0)/COALESCE(mu.numerator/mu.denomintr,1)) 
			    ELSE COALESCE(fct_billing_model.invoice_mix_qty,0) end ) * COALESCE(CASE 
                    WHEN dim_material.weight_measure_unit = 'G' 
					THEN dim_material.net_weight*(mu.numerator/mu.denomintr)/1000 --COALESCE(dim_material.net_weight,0))
       				ELSE dim_material.net_weight*(mu.numerator/mu.denomintr)/*/1000*/ END,0))
         as primary_weight_net_kg,
			1 as source_code,
			dim_plant.rdc_code AS rdc_code
           FROM bdl_m.vv_sap_fct_primary_sales fct_billing_model
           LEFT JOIN bdl_m.vv_sap_fct_orders_full o
        		ON fct_billing_model.so_number = o.so_number
        		AND fct_billing_model.line_number = o.line_number
                AND fct_billing_model.sales_org_code  = o.sales_org_code
			LEFT JOIN dm_common.t_dim_material_full dim_material 
				ON fct_billing_model.material_code = dim_material.material_code
			left join dm_common.v_dim_mat_unit mu
				on mu.material = dim_material.material_code
				and mu.mat_unit = 'CS'
			LEFT JOIN bdl_m.vv_mix_dim_plant dim_plant 
			ON fct_billing_model.plant_code = dim_plant.plant_code
          WHERE fct_billing_model.invoice_date >= (date_trunc('month',current_date) - interval '2 month')::date
          and fct_billing_model.doc_type in ('ZF1', 'ZF3', 'S1', 'S2', 'ZREF', 'ZRE', 'ZC1', 'ZD1') 
		  AND fct_billing_model.line_category in ('ZTAN', 'ZTNN', 'ZSAM', 'L2N', 'G2N', 'ZREN')   
UNION ALL
         SELECT t_target.date_start AS fact_date,
            t_target.date_start AS period_date,
            t_target.sales_org_code,
            t_target.legal_entity_code,
            t_target.sales_customer_id,
            t_target.material_code,
            null as line_number, --invoice_line,
            NULL AS billing_invoice_qty,
            0 AS is_refine,
            0 AS standart_sales,
            0 AS data_source_code, --data_source,
			 1 AS filter_standart_sales_refined_primary, 
			 1 AS filter_standart_sales_initial, 
            0 AS primary_zcu_act,
            0 AS primary_gsv_act,
            0 AS primary_niv_act,
                CASE
                    WHEN sum(coalesce(t_target.qty_prim,0)) + sum(coalesce(t_target.niv_prim,0)) + sum(coalesce(t_target.gsv_prim,0))  <> 0 THEN coalesce(sum(t_target.gsv_prim), 0)
                    ELSE 0
                END AS primary_gsv_tgt,
                CASE
                    WHEN sum(coalesce(t_target.qty_prim,0)) + sum(coalesce(t_target.niv_prim,0)) + sum(coalesce(t_target.gsv_prim,0)) <> 0 THEN COALESCE(sum(t_target.niv_prim), 0)
                    ELSE 0
                END AS primary_niv_tgt,
            sum(COALESCE(t_target.gsv_prim, 0)) AS gsv_prim,
            sum(COALESCE(t_target.niv_prim, 0)) AS niv_prim,
            sum(COALESCE(t_target.qty_prim, 0)) AS qty_prim,
            0 AS open_order_gsv,
            0 AS invoice_gsv,
            0 AS open_order_qty,
            0 AS invoice_qty,  
            0 AS order_conf_qty,
            0 AS order_conf_gsv,
            0 AS order_conf_niv,
            0 AS invoice_niv,
            0 AS open_order_niv,
            NULL AS order_period,
            0 AS primary_gsv_open_order,
            null AS invoice_number,
            NULL AS so_number,
            NULL AS order_status,
            NULL AS reject_reason, --reason_for_reject,
            NULL AS so_date,
            0 AS cs_lce_qty,
            0 AS cs_order_qty,
            0 AS cs_confirmed_qty,
            0 AS order_invoice_qty,
            0 AS gsv_value,
            0 AS cs_order_gsv,
            0 AS cs_order_conf_gsv,
            0 AS net_price,
            0 AS cs_order_niv,
            0 AS cs_order_conf_niv,
			NULL AS delivery_number, 
			null AS delivery_date,
			0 AS tts_on_abs, 
			0 AS ppr,
			0 AS tpr,  
			0 AS primary_weight_net_kg,
			2 as source_code,
			NULL AS rdc_code
           FROM bdl_m.vv_mix_dim_target_fix t_target
           WHERE t_target.date_start >= (date_trunc('month',current_date) - interval '2 month')::date
           group by 
            t_target.date_start,
            t_target.sales_org_code,
            t_target.legal_entity_code,
            t_target.sales_customer_id,
            t_target.material_code
UNION ALL
         SELECT fct_open_orders.fact_date, --fct_open_orders.CALENDAR_DATE  AS fact_date,  
            date_trunc('month', fct_open_orders.fact_date)::date AS period_date,
            --date_trunc('month', fct_open_orders.CALENDAR_DATE)::date AS period_date,  
            dim_sales_customer.sales_organization_code as sales_org_code,
            dim_sales_org.comp_code as legal_entity_code,
            md5(concat_ws('#',coalesce(fct_open_orders.sales_customer_code,''),coalesce(fct_open_orders.sales_org_code,'')))  AS sales_customer_id, --md5(concat_ws('#',coalesce(fct_open_orders.sold_to_sc_code,''),coalesce(fct_open_orders.sales_org_code,'')))  AS sales_customer_id,
            fct_open_orders.material_code,
            fct_open_orders.line_number, 
            NULL AS billing_invoice_qty,
            0 AS is_refine,
            0 AS standart_sales,
            0 AS data_source_code, --data_source,
			1 AS filter_standart_sales_refined_primary, 
			1 AS filter_standart_sales_initial, 
            0 AS primary_zcu_act,
            0 AS primary_gsv_act,
            0 AS primary_niv_act,
            0 AS primary_gsv_tgt,
            0 AS primary_niv_tgt,
            0 AS gsv_prim,
            0 AS niv_prim,
            0 AS qty_prim,
            COALESCE(fct_open_orders.open_order_gsv_amount , 0) AS open_order_gsv,
            COALESCE(fct_open_orders.invoice_in_order_gsv_amount, 0) AS invoice_gsv, -- COALESCE(fct_open_orders.invoice_gsv_amount, 0) AS invoice_gsv,
            COALESCE(fct_open_orders.open_order_qty, 0) AS open_order_qty,
            COALESCE(fct_open_orders.invoice_in_order_qty, 0) AS invoice_qty,    --COALESCE(fct_open_orders.invoice_qty, 0) AS invoice_qty,  
            COALESCE(fct_open_orders.order_conf_qty, 0) AS order_conf_qty,
			CASE
                WHEN (COALESCE(fct_open_orders.order_conf_qty, 0) - COALESCE(fct_open_orders.invoice_in_order_qty, 0)) = 0 THEN 0 --WHEN (COALESCE(fct_open_orders.order_conf_qty, 0) - COALESCE(fct_open_orders.invoice_qty, 0)) = 0 THEN 0
                ELSE COALESCE(fct_open_orders.order_conf_gsv_amount, 0) - COALESCE(fct_open_orders.invoice_in_order_gsv_amount, 0)
            END AS order_conf_gsv,
			COALESCE(fct_open_orders.order_conf_niv_amount, 0) - COALESCE(fct_open_orders.invoice_in_order_niv_amount, 0) AS order_conf_niv,  --COALESCE(fct_open_orders.order_conf_niv_amount, 0) - COALESCE(fct_open_orders.invoice_niv_amount, 0) AS order_conf_niv,
            COALESCE(fct_open_orders.invoice_in_order_niv_amount, 0) AS invoice_niv,  -- COALESCE(fct_open_orders.invoice_niv_amount, 0) AS invoice_niv,
            COALESCE(fct_open_orders.open_order_niv_amount, 0) AS open_order_niv,
            fct_open_orders.order_period,
			0 AS primary_gsv_open_order,
            NULL AS invoice_number,
            fct_open_orders.so_number::text AS so_number,
            'Open' AS order_status, 
            fct_open_orders.reject_reason, 
            fct_open_orders.so_date AS so_date, 
            0 AS cs_lce_qty,
            0 AS cs_order_qty,
            0 AS cs_confirmed_qty,
            0 AS order_invoice_qty,
            0 AS gsv_value,
            0 AS cs_order_gsv,
            0 AS cs_order_conf_gsv,
            0 AS net_price,
            0 AS cs_order_niv,
            0 AS cs_order_conf_niv,
			NULL AS delivery_number, 
			NULL AS delivery_date,
			0 AS tts_on_abs, 
			0 AS ppr, 
			0 AS tpr,  
			0 AS primary_weight_net_kg,
			3 as source_code,
			dim_plant.rdc_code AS rdc_code
           FROM dm_common.t_fct_open_orders fct_open_orders
           JOIN dm_common.t_dim_cust_sales_full dim_sales_customer 
             	ON dim_sales_customer.cust_sales_code= fct_open_orders.sales_customer_code  --ON dim_sales_customer.cust_sales_code= fct_open_orders.sold_to_sc_code
             	and dim_sales_customer.sales_organization_code = fct_open_orders.sales_org_code
             JOIN bdl_m.vv_sap_dim_sales_org dim_sales_org 
             	ON dim_sales_org.sales_org_code = dim_sales_customer.sales_organization_code
             LEFT JOIN bdl_m.vv_mix_dim_plant dim_plant 
             	ON fct_open_orders.plant_code = dim_plant.plant_code
        WHERE  fct_open_orders.fact_date >= (date_trunc('month',current_date) - interval '2 month')::date --fct_open_orders.CALENDAR_DATE >= (date_trunc('month',current_date) - interval '1 month')::date
UNION ALL
         select 
         	orders.scheduled_good_issue_date AS fact_date,
            date_trunc('month', orders.scheduled_good_issue_date)::date AS period_date,
            dim_sales_org.sales_org_code,
            dim_sales_org.comp_code as legal_entity_code, 
            md5(concat_ws('#',coalesce(orders.ship_to_code,''),coalesce(orders.sales_org_code,''))) as sales_customer_id, --sold_to_sc_id,
            orders.material_code,
            orders.line_number as line_number, --invoice_line,
            null AS billing_invoice_qty,
            0 AS is_refine,
            0 AS standart_sales,
            0 AS data_source_code, -- data_source,
			1 AS filter_standart_sales_refined_primary, 
			1 AS filter_standart_sales_initial, 
            0 AS primary_zcu_act,
            0 AS primary_gsv_act,
            0 AS primary_niv_act,
            0 AS primary_gsv_tgt,
            0 AS primary_niv_tgt,
            0 AS gsv_prim,
            0 AS niv_prim,
            0 AS qty_prim,
            0 AS open_order_gsv,
            0 AS invoice_gsv,
            0 AS open_order_qty,
            0 AS invoice_qty,   
            0 AS order_conf_qty,
            0 AS order_conf_gsv,
            0 AS order_conf_niv,
            0 AS invoice_niv,
            0 AS open_order_niv,
            NULL AS order_period,
            0 AS primary_gsv_open_order,
            null AS invoice_number,
            orders.so_number,
			case 
				when orders.order_status_flag  = 0 then 'Open'
				when orders.order_status_flag  = 1 then 'Closed'
				when orders.order_status_flag  = 2 then 'Reject'
					else 'NA' end  as order_status, --order_status_flag,
            orders.reject_reason,
            orders.so_date,
            orders.cs_lce_qty,
            orders.cs_order_qty,
            orders.cs_confirmed_qty,
            orders.invoice_in_order_qty as order_invoice_qty, --orders.invoice_qty as order_invoice_qty,
            orders.gsv_value_amount as gsv_value,
            orders.cs_order_gsv_amount as cs_order_gsv ,
            orders.cs_order_conf_gsv_amount as cs_order_conf_gsv,
            orders.net_price,
            orders.cs_order_niv_amount as cs_order_niv,
            orders.cs_order_conf_niv_amount as cs_order_conf_niv,
			NULL AS delivery_number, 
			NULL AS delivery_date,
			0 AS tts_on_abs, 
			0 AS ppr, 
			0 AS tpr,  
			0 AS primary_weight_net_kg,
			4 as source_code,
			dim_plant.rdc_code
           FROM bdl_m.vv_sap_fct_orders_full orders
             join dm_common.t_dim_cust_sales_full dim_sales_customer 
             	ON dim_sales_customer.cust_sales_code= orders.sales_customer_code --ON dim_sales_customer.cust_sales_code= orders.sold_to_sc_code
             	and dim_sales_customer.sales_organization_code = orders.sales_org_code
             JOIN  bdl_m.vv_sap_dim_sales_org dim_sales_org 
             	ON dim_sales_org.sales_org_code = dim_sales_customer.sales_organization_code
             JOIN bdl_m.vv_mix_dim_plant dim_plant 
             	ON orders.plant_code = dim_plant.plant_code
		   WHERE orders.is_standart_orders_flag = 1
		   and  orders.scheduled_good_issue_date >= (date_trunc('month',current_date) - interval '2 month')::date
        )       
, _SoM  as ( -- сумма за прошлый месяц на первое число текущего месяца 
select 
            (date_trunc('month',fct_billing_model.invoice_date) ::date + interval '1  month')::date as first_month_date,
            fct_billing_model.sales_org_code,
            fct_billing_model.legal_entity_code AS legal_entity_code,
            md5(concat_ws('#',coalesce(fct_billing_model.sales_customer_code,''),coalesce(fct_billing_model.sales_org_code,''))) AS sales_customer_id,
            fct_billing_model.material_code,
            fct_billing_model.line_number,
			CASE
			  WHEN COALESCE(fct_billing_model.refine_flag, 0) = 1 AND COALESCE(fct_billing_model.standart_sales_flag, 0)  = 1 THEN 1 ELSE 0 END as  filter_standart_sales_refined_primary,  
			CASE 
			  WHEN COALESCE(fct_billing_model.data_source_code, 0) != 3 AND COALESCE(fct_billing_model.standart_sales_flag, 0) = 1 THEN 1 ELSE 0 END as filter_standart_sales_initial, 
			COALESCE(fct_billing_model.refine_flag, 0) AS is_refine,
            COALESCE(fct_billing_model.standart_sales_flag, 0) AS standart_sales,
            COALESCE(fct_billing_model.data_source_code, 0) AS data_source_code, --data_source,
            fct_billing_model.invoice_number,
            fct_billing_model.so_number,
            o.so_date,
			fct_billing_model.delivery_number, 
			fct_billing_model.delivery_date,
			sum(COALESCE(fct_billing_model.primary_gsv_amount, 0)) AS primary_gsv_act,   --sum(COALESCE(fct_billing_model.sal_gsv_amount, 0)) AS primary_gsv_act, 
	 		sum(COALESCE( 
				CASE 
					WHEN fct_billing_model.uom::text = 'PC' THEN (fct_billing_model.invoice_mix_qty  / COALESCE(mu.numerator/mu.denomintr, 1))
					ELSE  fct_billing_model.invoice_mix_qty
				END, 0)) AS primary_qty_act,
			fct_billing_model.plant_code
from  bdl_m.vv_sap_fct_primary_sales fct_billing_model
	LEFT JOIN bdl_m.vv_sap_fct_orders_full o
        ON fct_billing_model.so_number = o.so_number
        AND fct_billing_model.line_number = o.line_number
        AND fct_billing_model.sales_org_code  = o.sales_org_code
	LEFT JOIN dm_common.v_dim_mat_unit mu 
		ON fct_billing_model.material_code = mu.material
		and mu.mat_unit = 'CS'
	WHERE fct_billing_model.invoice_date >= (date_trunc('month',current_date) - interval '3 month')::date --new
	and fct_billing_model.doc_type in ('ZF1', 'ZF3', 'S1', 'S2', 'ZREF', 'ZRE', 'ZC1', 'ZD1') 
	AND fct_billing_model.line_category in ('ZTAN', 'ZTNN', 'ZSAM', 'L2N', 'G2N', 'ZREN')   
		  group by 
			date_trunc('month',fct_billing_model.invoice_date)::date + interval '1  month' ,
            fct_billing_model.sales_org_code,
            fct_billing_model.legal_entity_code,
            fct_billing_model.sales_customer_code,
            fct_billing_model.material_code,
            fct_billing_model.line_number,
		    fct_billing_model.refine_flag,
            fct_billing_model.standart_sales_flag,
            fct_billing_model.data_source_code,
            fct_billing_model.invoice_number,
            fct_billing_model.so_number,
            o.so_date,
			fct_billing_model.delivery_number, 
			fct_billing_model.delivery_date,
			fct_billing_model.plant_code
) 
, full_bill as ( 
			Select 
			cal.date as fact_date, 
			date_trunc('month',cal.date) ::date  as period_date,
			s.sales_org_code,
			s.legal_entity_code,
			s.sales_customer_id,
			s.material_code,
			s.line_number,
			s.filter_standart_sales_refined_primary,
			s.filter_standart_sales_initial,
			0 as primary_gsv_act,
			0 as primary_qty_act, 
			s.is_refine,
			s.standart_sales,
			s.data_source_code, --s.data_source,
			s.invoice_number,
			s.so_number,
			s.so_date,
			s.delivery_number, 
			s.delivery_date,
			CASE 
				WHEN date_part ('day', cal.date) = 1 THEN s.primary_gsv_act ELSE 0 end as primary_gsv_act_SoM, 
			CASE 
				WHEN date_part ('day', cal.date) = 1 THEN s.primary_qty_act ELSE 0 end as primary_qty_act_SoM,
				0 as primary_gsv_target2,
				0 as Primary_GSV_Open_Order_Conf,
				0 as primary_gsv_open_order,
				0 as Primary_QTY_Open_Order_Conf,
				0 as Primary_QTY_Open_Order,
				s.plant_code
			from  bdl_m.vv_mix_dim_calendar cal 
			left join _SoM  s 
			ON cal.date = s.first_month_date
			where cal.date between (date_trunc('year', current_date) - interval '2 year') :: date 
			and (date_trunc('month', current_date) + interval '1 month'):: date 
union all
SELECT      fct_billing_model.invoice_date AS fact_date,
            date_trunc('month', fct_billing_model.invoice_date)::date AS period_date,
            fct_billing_model.sales_org_code,
            fct_billing_model.legal_entity_code AS legal_entity_code,
            md5(concat_ws('#',coalesce(fct_billing_model.sales_customer_code,''),coalesce(fct_billing_model.sales_org_code,''))) AS sales_customer_id,
            fct_billing_model.material_code,
            fct_billing_model.line_number,
            CASE
			  WHEN COALESCE(fct_billing_model.refine_flag, 0) = 1 AND COALESCE(fct_billing_model.standart_sales_flag, 0)  = 1 THEN 1 ELSE 0 END as  filter_standart_sales_refined_primary,  
			CASE 
			  WHEN COALESCE(fct_billing_model.DATA_SOURCE_CODE, 0) != 3 AND COALESCE(fct_billing_model.standart_sales_flag, 0) = 1 THEN 1 ELSE 0 END as filter_standart_sales_initial,
			COALESCE(fct_billing_model.primary_gsv_amount, 0) AS primary_gsv_act,  --COALESCE(fct_billing_model.sal_gsv_amount, 0) AS primary_gsv_act, 
			COALESCE( 
				CASE 
					WHEN fct_billing_model.uom::text = 'PC' THEN (fct_billing_model.invoice_mix_qty  / COALESCE(mu.numerator/mu.denomintr, 1))
					ELSE  fct_billing_model.invoice_mix_qty
				END, 0) AS primary_qty_act,
			COALESCE(fct_billing_model.refine_flag, 0) AS is_refine,
            COALESCE(fct_billing_model.standart_sales_flag, 0) AS standart_sales,
            COALESCE(fct_billing_model.DATA_SOURCE_CODE, 0) AS data_source_code, --data_source,
            fct_billing_model.invoice_number,
            fct_billing_model.so_number,
            o.so_date,
			fct_billing_model.delivery_number, 
			fct_billing_model.delivery_date,
				0 as primary_gsv_act_SoM,
			    0 as primary_qty_act_SoM,
				0 as primary_gsv_target2,
				0 as Primary_GSV_Open_Order_Conf,
				0 as primary_gsv_open_order,
				0 as Primary_QTY_Open_Order_Conf,
				0 as Primary_QTY_Open_Order,
				fct_billing_model.plant_code
from  bdl_m.vv_sap_fct_primary_sales fct_billing_model
	LEFT JOIN dm_common.t_dim_cust_sales_full SC
		ON SC.cust_sales_code = fct_billing_model.sales_customer_code
		and sc.sales_organization_code = fct_billing_model.sales_org_code 
	left join bdl_m.vv_sap_fct_orders_full o
		ON fct_billing_model.so_number = o.so_number
		AND fct_billing_model.line_number = o.line_number
        AND fct_billing_model.sales_org_code  = o.sales_org_code
	left join dm_common.v_dim_mat_unit  mu
		ON fct_billing_model.material_code = mu.material
		and mu.mat_unit = 'CS'
	WHERE fct_billing_model.invoice_date >= (date_trunc('month',current_date) - interval '2 month')::date
	and fct_billing_model.doc_type in ('ZF1', 'ZF3', 'S1', 'S2', 'ZREF', 'ZRE', 'ZC1', 'ZD1') 
	AND fct_billing_model.line_category in ('ZTAN', 'ZTNN', 'ZSAM', 'L2N', 'G2N', 'ZREN')   
) 
, part_f as (
		Select 
		fb.fact_date, 
		fb.period_date,
		fb.sales_org_code,
		fb.legal_entity_code,
		fb.sales_customer_id,
		fb.material_code,
		fb.line_number,
		fb.filter_standart_sales_refined_primary,
		fb.filter_standart_sales_initial,
		fb.is_refine,
		fb.standart_sales,
		fb.data_source_code, --fb.data_source,
		fb.invoice_number,
		fb.so_number,
		fb.so_date,
		fb.delivery_number, 
		fb.delivery_date,
		NULL AS order_status,
		NULL AS order_period,
		NULL AS reject_reason, --reason_for_reject, 
		fb.primary_gsv_act_SoM as primary_gsv_act_SoM, 
		fb.primary_qty_act_SoM as primary_qty_act_SoM,
		(fb.primary_gsv_act + fb.primary_gsv_act_SoM) as GSV_act_SoM,
		(fb.primary_qty_act + fb.primary_qty_act_SoM) as QTY_act_SoM,
		0 as primary_gsv_target2,
		0 as Primary_GSV_Open_Order_Conf,
			0 as primary_gsv_open_order,
			0 as Primary_QTY_Open_Order_Conf,
			0 as Primary_QTY_Open_Order,
			5 as source_code,
			fb.plant_code
		from full_bill  fb
			join dm_common.t_dim_cust_sales_full sc
				on fb.sales_customer_id = md5(concat_ws('#',coalesce(sc.cust_sales_code,''),coalesce(sc.sales_organization_code,'')))
			left join (select  date_start ,sc.cust_hier_local_lvl2_code as customer_code, material_code, sum(GSV_PRIM) as GSV_PRIM 
						from bdl_m.vv_mix_dim_target_fix f
					join bdl_m.vv_sap_dim_cust_sales_full sc  
						on sc.cust_sales_code = f.soldto_code
						and sc.sales_organization_code = f.sales_org_code 
						and sc.cust_hier_local_lvl2_code <> 'NA'
					Where GSV_PRIM is not null and launch_indicator = 1
					and date_start >= (date_trunc('month',current_date) - interval '2 month')::date
				group by date_start ,sc.cust_hier_local_lvl2_code, material_code) t
			on  fb.period_date = t.date_start    
			and sc.cust_hier_local_lvl2_code = t.customer_code
			and fb.material_code = t.material_code
		where t.GSV_PRIM is not null 
union all
		Select 
			t_target.date_start AS fact_date,
            t_target.date_start AS period_date,
            t_target.sales_org_code,
            t_target.legal_entity_code,
            t_target.sales_customer_id,
            t_target.material_code, 
            null as line_number, -- invoice_line,
			1 AS filter_standart_sales_refined_primary, 
			1 AS filter_standart_sales_initial, 
			0 AS is_refine,
            0 AS standart_sales,
            0 AS data_source_code, --data_source,
			NULL AS invoice_number,
            NULL AS so_number,
			NULL AS so_date,
			NULL AS delivery_number, 
			NULL AS delivery_date,
			NULL AS order_status,
			NULL AS order_period,
			NULL AS reject_reason, --reason_for_reject,  
			0 as primary_gsv_act_SoM,
			0 as primary_qty_act_SoM,
			0 as GSV_act_SoM,
			0 as QTY_act_SoM,
			sum(t_target.gsv_prim) as primary_gsv_target2,
			0 as Primary_GSV_Open_Order_Conf,
			0 as primary_gsv_open_order,
			0 as Primary_QTY_Open_Order_Conf,
			0 as Primary_QTY_Open_Order,
			6 as source_code,
			NULL AS plant_code
	 FROM bdl_m.vv_mix_dim_target_fix t_target 
		Where launch_indicator = 1 
		and  t_target.date_start >= (date_trunc('month',current_date) - interval '2 month')::date
	group by 
			t_target.date_start,
            t_target.date_start,
            t_target.sales_org_code,
            t_target.legal_entity_code,
            t_target.sales_customer_id,
            t_target.material_code
union all 
		Select 
			fct_open_orders.fact_date, --fct_open_orders.CALENDAR_DATE  AS fact_date,  
            date_trunc('month', fct_open_orders.fact_date)::date  AS period_date,  --date_trunc('month', fct_open_orders.CALENDAR_DATE)::date  AS period_date,  
            dim_sales_customer.sales_organization_code,
            dim_sales_org.comp_code as legal_entity_code,
            md5(concat_ws('#',coalesce(fct_open_orders.sales_customer_code,''),coalesce(fct_open_orders.sales_org_code,''))) AS sold_to_id, --md5(concat_ws('#',coalesce(fct_open_orders.sold_to_sc_code,''),coalesce(fct_open_orders.sales_org_code,''))) AS sold_to_id,
            fct_open_orders.material_code,
            fct_open_orders.line_number as line_number,
			1 AS filter_standart_sales_refined_primary, 
			1 AS filter_standart_sales_initial, 
			0 AS is_refine,
            0 AS standart_sales,
            0 AS data_source_code, --data_source,
			NULL AS invoice_number,
            fct_open_orders.so_number AS so_number,
			fct_open_orders.so_date AS so_date,
			NULL AS delivery_number, 
			NULL AS delivery_date,
			'Open' AS order_status,
			fct_open_orders.order_period,
			fct_open_orders.reject_reason, -- AS reason_for_reject,  
			0 as primary_gsv_act_SoM,
			0 as primary_qty_act_SoM,
			0 as GSV_act_SoM,
			0 as QTY_act_SoM,
			0 as primary_gsv_target2,
			CASE
                WHEN (COALESCE(fct_open_orders.order_conf_qty, 0) - COALESCE(fct_open_orders.invoice_in_order_qty, 0)) = 0 THEN 0 --WHEN (COALESCE(fct_open_orders.order_conf_qty, 0) - COALESCE(fct_open_orders.invoice_qty, 0)) = 0 THEN 0
                ELSE COALESCE(fct_open_orders.order_conf_gsv_amount, 0) - COALESCE(fct_open_orders.invoice_in_order_gsv_amount, 0)
            END AS Primary_GSV_Open_Order_Conf,
			COALESCE(fct_open_orders.order_conf_gsv_amount, 0) AS primary_gsv_open_order,
			COALESCE(fct_open_orders.order_conf_qty, 0) - COALESCE(fct_open_orders.invoice_in_order_qty, 0) as Primary_QTY_Open_Order_Conf, --COALESCE(fct_open_orders.order_conf_qty, 0) - COALESCE(fct_open_orders.invoice_qty, 0) as Primary_QTY_Open_Order_Conf,
			COALESCE(fct_open_orders.open_order_qty, 0) - COALESCE(fct_open_orders.invoice_in_order_qty, 0) as Primary_QTY_Open_Order,  --COALESCE(fct_open_orders.open_order_qty, 0) - COALESCE(fct_open_orders.invoice_qty, 0) as Primary_QTY_Open_Order,
			 7 as source_code,
			 fct_open_orders.plant_code
	From dm_common.t_fct_open_orders fct_open_orders
		JOIN dm_common.t_dim_cust_sales_full dim_sales_customer 
			ON dim_sales_customer.cust_sales_code = fct_open_orders.sales_customer_code --ON dim_sales_customer.cust_sales_code = fct_open_orders.sold_to_sc_code
			and dim_sales_customer.sales_organization_code = fct_open_orders.sales_org_code
		JOIN bdl_m.vv_sap_dim_sales_org dim_sales_org ON dim_sales_org.sales_org_code = dim_sales_customer.sales_organization_code 
		Left join (select  date_start ,sc.cust_hier_local_lvl2_code as customer_code, material_code, sum(GSV_PRIM) as GSV_PRIM 
					from bdl_m.vv_mix_dim_target_fix f
						join dm_common.t_dim_cust_sales_full sc
							on sc.cust_sales_code = f.soldto_code
							and sc.sales_organization_code = f.sales_org_code 
						   and sc.cust_hier_local_lvl2_code <> 'NA'
					Where GSV_PRIM is not null and launch_indicator = 1
					and date_start >= (date_trunc('month',current_date) - interval '2 month')::date
					group by date_start ,sc.cust_hier_local_lvl2_code, material_code) t
		On fct_open_orders.material_code = t.material_code
		and dim_sales_customer.cust_hier_local_lvl2_code  = t.customer_code 
		and date_trunc('month',fct_open_orders.scheduled_good_issue_date )::date = t.date_start
	where t.GSV_PRIM is not null 
	and  fct_open_orders.fact_date >= (date_trunc('month',current_date) - interval '2 month')::date --  fct_open_orders.CALENDAR_DATE >= (date_trunc('month',current_date) - interval '1 month')::date
)
SELECT 
    pre.fact_date as fact_date,
    pre.period_date as period_date, 
    coalesce(pre.sales_org_code, 'NA') as sales_org_code,
    coalesce(pre.legal_entity_code, 'NA') as legal_entity_code,
    coalesce(pre.sales_customer_id, 'NA') as sales_customer_id,
    coalesce(pre.material_code, 'NA') AS material_code,
    COALESCE(pre.line_number, 'NA') as line_number,
    coalesce(rt.rate_code, 'NA') AS rate_code,
    COALESCE(rt.rate, 0) AS rate,
    pre.is_refine,
    pre.standart_sales,
    pre.data_source_code,  --pre.data_source as data_source_code,
	pre.filter_standart_sales_refined_primary, -- as filter_standart_sales_refined_primary_flag, 
	pre.filter_standart_sales_initial, -- as filter_standart_sales_initial_flag, 
    pre.order_period,
    COALESCE(pre.invoice_number, 'NA') AS invoice_number, 
    COALESCE(pre.so_number, 'NA') AS so_number,
    COALESCE(pre.order_status, 'NA') AS order_status,
    COALESCE(pre.reject_reason, 'NA') AS reject_reason, --COALESCE(pre.reason_for_reject, 'NA') AS reject_reason,
    pre.so_date,
	COALESCE(pre.delivery_number, 'NA') as delivery_number, 
	pre.delivery_date,
	pre.billing_invoice_qty AS primary_qty, --primary_invoice_qty,
 --   pre.gsv_prim AS primary_gsv_amount,
 --   pre.niv_prim AS primary_niv_amount,
 --   pre.qty_prim AS primary_qty,
    pre.open_order_gsv as primary_gsv_open_order, -- open_order_gsv_amount,
    pre.invoice_gsv  AS invoice_in_order_gsv, --invoice_gsv_amount,
    pre.open_order_qty  AS primary_qty_open_order, -- open_order_qty,
    pre.invoice_qty AS invoice_in_order_qty, --invoice_qty,
    pre.order_conf_qty  AS primary_qty_open_order_conf, --order_conf_qty,
    pre.order_conf_gsv AS primary_gsv_open_order_conf, --order_conf_gsv_amount,
    pre.order_conf_niv AS primary_niv_open_order_conf, --order_conf_niv_amount,
    pre.invoice_niv AS invoice_in_order_niv, --invoice_niv_amount,
    pre.open_order_niv AS primary_niv_open_order, --open_order_niv_amount,
    pre.primary_gsv_act, -- AS primary_actual_gsv_amount,
    pre.primary_niv_act, -- AS primary_actual_niv_amount,
    COALESCE(pre.primary_niv_act / rt.rate, 0) AS primary_niv_act_eur, -- primary_actual_niv_amount_eur,
    COALESCE(pre.primary_gsv_act / rt.rate, 0) AS primary_gsv_act_eur, -- primary_actual_gsv_amount_eur,
    pre.primary_zcu_act, -- AS primary_actual_zcu,
    pre.primary_gsv_tgt, -- AS primary_target_gsv,
    pre.primary_niv_tgt, -- AS primary_target_niv,
    pre.cs_lce_qty as order_lce_qty,
    pre.cs_order_qty AS primary_qty_total_order, --prim_qty_total_order, --prim_total_order_qty,
    pre.cs_confirmed_qty AS primary_qty_total_order_conf, --prim_qty_total_order_conf, --primary_total_order_conf_qty,
    pre.order_invoice_qty AS invoice_in_total_order_qty, --primary_invoice_in_total_orders_qty,
    pre.gsv_value AS order_lce_gsv, -- order_lce_gsv_amount,
    pre.cs_order_gsv AS primary_gsv_total_order, -- primary_total_order_gsv_amount,
    pre.cs_order_conf_gsv AS primary_gsv_total_order_conf, --primary_total_order_conf_gsv_amount,
    pre.cs_lce_qty * pre.net_price AS order_lce_niv, --order_lce_niv_amount,
    pre.cs_order_niv AS primary_niv_total_order, --primary_total_order_niv_amount,
    pre.cs_order_conf_niv AS primary_niv_total_order_conf, --primary_total_order_conf_niv_amount,
	pre.tts_on_abs, -- AS tts_on_abs_amount,
	pre.ppr, --pre.ppr_amount AS ppr_amount, 
	pre.tpr, -- pre.tpr_amount AS tpr_amount, 
	pre.primary_weight_net_kg AS primary_weight_net_kg, 
    COALESCE(pre.tts_on_abs/ rt.rate, 0) AS tts_on_abs_eur, --tts_on_abs_amount_eur,
	COALESCE(pre.ppr/ rt.rate, 0) AS ppr_eur, --COALESCE(pre.ppr_amount/ rt.rate, 0) AS ppr_amount_eur,
	COALESCE(pre.tpr/ rt.rate, 0) AS tpr_eur, --COALESCE(pre.tpr_amount/ rt.rate, 0) AS tpr_amount_eur,
	COALESCE(pre.primary_gsv_tgt/ rt.rate, 0) AS primary_gsv_tgt_eur, --primary_target_gsv_amount_eur,
	COALESCE(pre.primary_niv_tgt/ rt.rate, 0) AS primary_niv_tgt_eur, --primary_target_niv_amount_eur,
	0 AS primary_gsv_tgt2, --primary_target_gsv2_amount,
	0 AS primary_gsv_act2, --primary_actual_gsv2_amount,
	0 AS primary_qty_act2, --primary_actual_qty2_amount,
	0 AS primary_gsv_open_order_conf_act2, --primary_open_order_conf_actual_gsv2_amount,
	0 AS primary_gsv_open_order_act2, --primary_open_order_actual_gsv2_amount,
	0 AS primary_qty_open_order_conf_act2, --primary_open_order_conf_actual_qty2,
	0 AS primary_qty_open_order_act2, --primary_open_order_actual_qty2,
	pre.source_code,
	COALESCE(pre.rdc_code, 'NA') AS rdc_code
   FROM pre
     LEFT JOIN bdl_m.vv_mix_fct_rate rt ON
        CASE
            WHEN pre.legal_entity_code = '4667' THEN 'RUB'
            WHEN pre.legal_entity_code = '4673' THEN 'UAH'
            ELSE pre.legal_entity_code
        END = rt.to_currency AND rt.rate_date = date_trunc('year', current_date)::date
WHERE pre.sales_org_code NOT IN   ('U001','U002','U003','U004')
UNION ALL  
Select 
	 f.fact_date, 
	 f.period_date as period_date,
	 COALESCE(f.sales_org_code, 'NA') as sales_org_code,
	 COALESCE(f.legal_entity_code, 'NA') as legal_entity_code,
	 COALESCE(f.sales_customer_id, 'NA') as sales_customer_id, --sold_to_sc_id,
	 COALESCE(f.material_code , 'NA') AS material_code,
	 COALESCE(f.line_number, 'NA') as line_number,
	 COALESCE(rt.rate_code, 'NA') AS rate_code, 
	 COALESCE(rt.rate, 0) AS rate,
	 f.is_refine,
	 f.standart_sales,
	 f.data_source_code, --f.data_source as data_source,
	 f.filter_standart_sales_refined_primary, -- as filter_standart_sales_refined_primary, 
	 f.filter_standart_sales_initial as filter_standart_sales_initial,
	 f.order_period, 
	 COALESCE(f.invoice_number, 'NA') AS invoice_number ,
	 COALESCE(f.so_number, 'NA') AS so_number,  
	 COALESCE(f.order_status, 'NA') AS order_status,  
	 COALESCE(f.reject_reason, 'NA') as reject_reason,  -- COALESCE(f.reason_for_reject, 'NA') as reject_reason, 
	 f.so_date,
	COALESCE(f.delivery_number, 'NA') as delivery_number,
	f.delivery_date,
	0 AS primary_qty, --primary_invoice_qty,
 --    0 AS gsv_prim,
 --    0 AS niv_prim,
 --    0 AS qty_prim,
    0 AS primary_gsv_open_order, --open_order_gsv,
    0 AS invoice_in_order_gsv, --invoice_gsv,
    0 AS primary_qty_open_order, --open_order_qty,
    0 AS invoice_in_order_qty, --invoice_qty,
    0 AS primary_qty_open_order_conf, --order_conf_qty,
    0 AS primary_gsv_open_order_conf, --order_conf_gsv ,
    0 AS primary_niv_open_order_conf, --order_conf_niv,
    0 AS invoice_in_order_niv, --invoice_niv,
    0 AS primary_niv_open_order, --open_order_niv,
    0 AS primary_gsv_act,
    0 AS primary_niv_act,
    0 AS primary_niv_act_eur,
    0 AS primary_gsv_act_eur,
    0 AS primary_zcu_act,
    0 AS primary_gsv_tgt,
    0 AS primary_niv_tgt,
    0 AS order_lce_qty,
    0 AS primary_qty_total_order, --prim_qty_total_order,
    0 AS primary_qty_total_order_conf, --prim_qty_total_order_conf,
    0 AS invoice_in_total_order_qty, --prim_qty_invoice_in_total_orders,
    0 AS order_lce_gsv,
    0 AS primary_gsv_total_order,      --prim_gsv_total_order,
    0 AS primary_gsv_total_order_conf, --prim_gsv_total_order_conf,
    0 AS order_lce_niv,
    0 AS primary_niv_total_order, --prim_niv_total_order,
    0 AS primary_niv_total_order_conf, --prim_niv_total_order_conf,
	0 AS tts_on_abs, 
	0 AS ppr, 
	0 AS tpr,  
	0 AS primary_weight_net_kg, 
    0 AS tts_on_abs_eur,
	0 AS ppr_eur,
	0 AS tpr_eur,
	0 AS primary_gsv_tgt_eur,
	0 AS primary_niv_tgt_eur,
	coalesce(f.primary_gsv_target2, 0) as primary_gsv_tgt2, --primary_gsv_target2, 
	coalesce(f.GSV_act_SoM,0) as primary_gsv_act2, --primary_gsv_actual2, 
	coalesce(f.QTY_act_SoM,0) as primary_qty_act2, --primary_qty_actual2, 
	coalesce(f.Primary_GSV_Open_Order_Conf,0) as primary_gsv_open_order_conf_act2, --primary_gsv_actual2_open_order_conf,
	coalesce(f.primary_gsv_open_order,0) as primary_gsv_open_order_act2, --primary_gsv_actual2_open_order,
	coalesce(f.Primary_QTY_Open_Order_Conf,0) as primary_qty_open_order_conf_act2, --primary_qty_actual2_open_order_conf,
	coalesce(f.Primary_QTY_Open_Order,0) as primary_qty_open_order_act2, --primary_qty_actual2_open_order,
	f.source_code,
	COALESCE(dim_plant.rdc_code , 'NA') AS rdc_code
From part_f f
	LEFT JOIN bdl_m.vv_mix_fct_rate rt ON
        CASE
            WHEN f.legal_entity_code = '4667' THEN 'RUB'
            WHEN f.legal_entity_code = '4673' THEN 'UAH'
            ELSE f.legal_entity_code
        END = rt.to_currency AND rt.rate_date = date_trunc('year', current_date)::date
     left join  bdl_m.vv_mix_dim_plant dim_plant 
     	ON f.plant_code = dim_plant.plant_code
Where f.sales_org_code NOT IN  ('U001','U002','U003','U004')

```
</details>


ER-диаграмма
----
```mermaid
erDiagram

  t_dm_fact_vs_target_detail }o--|| dim_legal_entity : "legal_entity_code"
  t_dm_fact_vs_target_detail }o--|| dim_sales_org : "sales_org_code"
  t_dm_fact_vs_target_detail }o--|| t_dim_cust_sales_full : "sales_customer_id"
  t_dm_fact_vs_target_detail }o--|| t_dim_material_full : "material_code"
  t_dm_fact_vs_target_detail }o--|| t_mix_fct_rate : "rate_code"
  t_dm_fact_vs_target_detail }o--|| t_mix_dim_rdc : "rdc_code"
  dim_legal_entity{
    legal_entity_code varchar PK "Код юр.лица"
  }
  dim_sales_org{
    sales_org_code varchar PK "Код сбытовой организации"
  }
  t_dim_cust_sales_full{
    sales_customer_id varchar PK "ID кастомера"
  }
  t_dim_material_full{
    material_code  varchar PK "Код материала "
  }
  t_mix_fct_rate{
    rate_code varchar PK "Код Валютного курса"
  }
  t_mix_dim_rdc{
    rdc_code varchar PK "Код распределительного центра"
  }  
  t_dm_fact_vs_target_detail{
	fact_date PK date Фактическая дата
	sales_org_code FK varchar Код сбытовой организации
	legal_entity_code FK varchar Код юр.лица
	sales_customer_id FK varchar Идентификатор клиента
	material_code FK varchar Код продукта или составляющей препака
	material_code_init FK varchar Код продукта
	line_number PK varchar Номер строки в Order/Invoice/Delivery
  }
```



Таблицы-источники:
-----------------
- [bdl_m.t_sap_fct_primary_sales](dwh/business-layer/bdl_m.t_sap_fct_primary_sales.md)
- [bdl_m.t_sap_fct_orders_full](dwh/business-layer/bdl_m.t_sap_fct_orders_full.md)
- [dm_common.t_dim_material_full](dwh/datamarts/common/dm_common.t_dim_material_full.md)
- [dm_common.t_dim_cust_sales_full](dwh/datamarts/common/dm_common.t_dim_cust_sales_full.md)
- [dm_common.v_dim_mat_unit](dwh/datamarts/common/dm_common.v_dim_mat_unit.md)
- [bdl_m.t_mix_dim_target_fix](dwh/business-layer/bdl_m.t_mix_dim_target_fix.md)
- [dm_common.t_fct_open_orders](dwh/datamarts/common/dm_common.t_fct_open_orders.md)
- [bdl_m.t_mix_fct_rate](dwh/business-layer/bdl_m.t_mix_fct_rate.md)
- [bdl_m.t_mix_dim_plant](dwh/business-layer/bdl_m.t_mix_dim_plant.md)
- [bdl_m.t_sap_dim_sales_org](dwh/business-layer/bdl_m.t_sap_dim_sales_org.md)
