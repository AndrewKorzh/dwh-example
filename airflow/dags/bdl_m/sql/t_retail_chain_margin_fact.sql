WITH union_stats AS (
    -- X5
    SELECT 
        'X5' AS retail_chain,
        'X5 Group' AS retail_chain_name,
        plant_code,
        plant_name,
        product_group_code,
        product_group_name,
        fiscal_year,
        fiscal_period,
        DATE_TRUNC('month', TO_DATE(fiscal_year || '-' || LPAD(fiscal_period::text, 2, '0') || '-01', 'YYYY-MM-DD')) AS fiscal_date,
        planned_margin_percent,
        planned_margin_amount,
        planned_gmv,
        planned_discount_budget,
        approval_status,
        CASE WHEN approval_status = 'APPROVED' THEN TRUE ELSE FALSE END AS is_approved,
        approved_dt,
        valid_from_dt,
        valid_to_dt,
        valid_st,
        inserted_dt,
        updated_dt
    FROM ods_x5.t_margin_plan
    WHERE valid_st = 1 
      AND approval_status = 'APPROVED'
      AND fiscal_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 1
    
    UNION ALL
    
    -- Magnit
    SELECT 
        'MAGNIT' AS retail_chain,
        'Магнит' AS retail_chain_name,
        plant_code,
        plant_name,
        product_group_code,
        product_group_name,
        fiscal_year,
        fiscal_period,
        DATE_TRUNC('month', TO_DATE(fiscal_year || '-' || LPAD(fiscal_period::text, 2, '0') || '-01', 'YYYY-MM-DD')) AS fiscal_date,
        planned_margin_percent,
        planned_margin_amount,
        planned_gmv,
        planned_discount_budget,
        approval_status,
        CASE WHEN approval_status = 'APPROVED' THEN TRUE ELSE FALSE END AS is_approved,
        approved_dt,
        valid_from_dt,
        valid_to_dt,
        valid_st,
        inserted_dt,
        updated_dt
    FROM ods_magnit.t_margin_plan
    WHERE valid_st = 1 
      AND approval_status = 'APPROVED'
      AND fiscal_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 1
    
    UNION ALL
    
    -- Lenta
    SELECT 
        'LENTA' AS retail_chain,
        'Лента' AS retail_chain_name,
        plant_code,
        plant_name,
        product_group_code,
        product_group_name,
        fiscal_year,
        fiscal_period,
        DATE_TRUNC('month', TO_DATE(fiscal_year || '-' || LPAD(fiscal_period::text, 2, '0') || '-01', 'YYYY-MM-DD')) AS fiscal_date,
        planned_margin_percent,
        planned_margin_amount,
        planned_gmv,
        planned_discount_budget,
        approval_status,
        CASE WHEN approval_status = 'APPROVED' THEN TRUE ELSE FALSE END AS is_approved,
        approved_dt,
        valid_from_dt,
        valid_to_dt,
        valid_st,
        inserted_dt,
        updated_dt
    FROM ods_lenta.t_margin_plan
    WHERE valid_st = 1 
      AND approval_status = 'APPROVED'
      AND fiscal_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 1
    
    UNION ALL
    
    -- Auchan
    SELECT 
        'AUCHAN' AS retail_chain,
        'Ашан' AS retail_chain_name,
        plant_code,
        plant_name,
        product_group_code,
        product_group_name,
        fiscal_year,
        fiscal_period,
        DATE_TRUNC('month', TO_DATE(fiscal_year || '-' || LPAD(fiscal_period::text, 2, '0') || '-01', 'YYYY-MM-DD')) AS fiscal_date,
        planned_margin_percent,
        planned_margin_amount,
        planned_gmv,
        planned_discount_budget,
        approval_status,
        CASE WHEN approval_status = 'APPROVED' THEN TRUE ELSE FALSE END AS is_approved,
        approved_dt,
        valid_from_dt,
        valid_to_dt,
        valid_st,
        inserted_dt,
        updated_dt
    FROM ods_auchan.t_margin_plan
    WHERE valid_st = 1 
      AND approval_status = 'APPROVED'
      AND fiscal_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 1
)

-- Основной вывод с аналитическими агрегатами
SELECT 
    retail_chain,
    retail_chain_name,
    fiscal_year,
    fiscal_period,
    fiscal_date,
    COUNT(DISTINCT plant_code) AS plants_count,
    COUNT(DISTINCT product_group_code) AS product_groups_count,
    SUM(planned_gmv) AS total_planned_gmv_rub,
    SUM(planned_margin_amount) AS total_planned_margin_rub,
    AVG(planned_margin_percent) AS avg_planned_margin_percent,
    SUM(planned_discount_budget) AS total_planned_discount_budget_rub,
    SUM(planned_discount_budget) / NULLIF(SUM(planned_gmv), 0) * 100 AS discount_share_percent,
    SUM(planned_margin_amount) / NULLIF(SUM(planned_gmv), 0) * 100 AS weighted_avg_margin_percent,
    COUNT(*) AS records_count,
    MIN(approved_dt) AS earliest_approval_dt,
    MAX(approved_dt) AS latest_approval_dt
FROM union_stats
GROUP BY 
    retail_chain,
    retail_chain_name,
    fiscal_year,
    fiscal_period,
    fiscal_date
ORDER BY 
    retail_chain,
    fiscal_year DESC,
    fiscal_period DESC