-- =========================================================
-- TMRW Portfolio Diagnostic — Analysis Queries (v2)
-- Run after 01_schema_and_seed.sql
-- =========================================================

-- -----------------------------------------------------------------
-- Q1. YoY revenue growth and net-loss change, per brand (FY24 -> FY25)
--     Limited to the 3 brands with audited FY24+FY25 margin data
-- -----------------------------------------------------------------
SELECT
    curr.brand,
    prev.revenue                                   AS revenue_fy24,
    curr.revenue                                   AS revenue_fy25,
    ROUND((curr.revenue - prev.revenue) / prev.revenue, 4)      AS revenue_growth_yoy,
    prev.net_loss                                  AS net_loss_fy24,
    curr.net_loss                                  AS net_loss_fy25,
    curr.ebitda_margin                             AS ebitda_margin_fy25
FROM brand_financials curr
JOIN brand_financials prev
    ON curr.brand = prev.brand
   AND curr.fiscal_year = 'FY25'
   AND prev.fiscal_year = 'FY24'
WHERE curr.data_quality = 'audited' AND curr.ebitda_margin IS NOT NULL
ORDER BY revenue_growth_yoy DESC;


-- -----------------------------------------------------------------
-- Q2. 2x2 portfolio classification
--     Axis 1: revenue growth YoY   Axis 2: EBITDA margin (FY25)
-- -----------------------------------------------------------------
WITH growth AS (
    SELECT
        curr.brand,
        (curr.revenue - prev.revenue) / prev.revenue AS revenue_growth_yoy,
        curr.ebitda_margin,
        curr.net_loss AS net_loss_fy25,
        prev.net_loss AS net_loss_fy24
    FROM brand_financials curr
    JOIN brand_financials prev
        ON curr.brand = prev.brand
       AND curr.fiscal_year = 'FY25'
       AND prev.fiscal_year = 'FY24'
    WHERE curr.data_quality = 'audited' AND curr.ebitda_margin IS NOT NULL
)
SELECT
    brand,
    ROUND(revenue_growth_yoy, 4)  AS revenue_growth_yoy,
    ROUND(ebitda_margin, 4)       AS ebitda_margin_fy25,
    CASE
        WHEN revenue_growth_yoy > 0.30 AND ebitda_margin = (SELECT MAX(ebitda_margin) FROM growth) THEN 'Scale'
        WHEN revenue_growth_yoy < 0 AND net_loss_fy25 < net_loss_fy24 THEN 'Cut / Harvest'
        WHEN revenue_growth_yoy BETWEEN 0 AND 0.30 THEN 'Fix'
        ELSE 'Review'
    END AS quadrant
FROM growth
ORDER BY revenue_growth_yoy DESC;

-- Note: rule-based, not statistical clustering — appropriate for 3 comparable data
-- points. Nobero and Urbano are excluded here because no EBITDA margin has been
-- disclosed for either — see Q6 for what we CAN say about them (revenue trend only).


-- -----------------------------------------------------------------
-- Q3. Which brand's marketing spend actually converted to revenue?
-- -----------------------------------------------------------------
SELECT
    curr.brand,
    curr.ad_spend - prev.ad_spend                                   AS incremental_ad_spend,
    curr.revenue - prev.revenue                                     AS incremental_revenue,
    ROUND((curr.revenue - prev.revenue) / NULLIF(curr.ad_spend - prev.ad_spend, 0), 2)
                                                                     AS revenue_per_incremental_ad_rupee
FROM brand_financials curr
JOIN brand_financials prev
    ON curr.brand = prev.brand
   AND curr.fiscal_year = 'FY25'
   AND prev.fiscal_year = 'FY24'
WHERE curr.ad_spend IS NOT NULL AND prev.ad_spend IS NOT NULL;

-- Wrogn: incremental ad spend positive, incremental revenue NEGATIVE -> ratio negative.
-- This remains the evidence base for flagging Wrogn's FY25 spend as unconverted —
-- note this is FY25 data; TMRW's group-level trajectory has since improved (see Q5).


-- -----------------------------------------------------------------
-- Q4. Reallocation scenario: freeze Wrogn's incremental ad spend,
--     redeploy into TIGC at TIGC's FY25 EBITDA margin
-- -----------------------------------------------------------------
WITH assumptions (tigc_rev_per_ad_rupee, tigc_ebitda_margin) AS (
    SELECT 8.0, -0.0637
),
wrogn_spend AS (
    SELECT
        curr.ad_spend - prev.ad_spend AS reallocatable_spend
    FROM brand_financials curr
    JOIN brand_financials prev
        ON curr.brand = prev.brand AND curr.brand = 'Wrogn'
       AND curr.fiscal_year = 'FY25' AND prev.fiscal_year = 'FY24'
)
SELECT
    reallocatable_spend                                                AS wrogn_reallocatable_spend_rs_cr,
    ROUND(reallocatable_spend * tigc_rev_per_ad_rupee, 1)               AS incremental_tigc_revenue_rs_cr,
    ROUND(reallocatable_spend * tigc_rev_per_ad_rupee * tigc_ebitda_margin, 1)
                                                                        AS incremental_tigc_ebitda_rs_cr,
    reallocatable_spend                                                AS wrogn_loss_avoided_rs_cr,
    ROUND(reallocatable_spend + (reallocatable_spend * tigc_rev_per_ad_rupee * tigc_ebitda_margin), 1)
                                                                        AS net_portfolio_ebitda_improvement_rs_cr
FROM wrogn_spend, assumptions;


-- -----------------------------------------------------------------
-- Q5. TMRW group trajectory — is the loss actually peaking?
--     (Official segment-reported quarterly figures, ex-Wrogn where noted)
-- -----------------------------------------------------------------
SELECT
    period,
    revenue,
    ebitda,
    ROUND(ebitda_margin, 4) AS ebitda_margin,
    yoy_note
FROM tmrw_consolidated
WHERE revenue IS NOT NULL
ORDER BY
    CASE period
        WHEN 'Q3 FY25' THEN 1
        WHEN 'Q3 FY26' THEN 2
        WHEN '9M FY25' THEN 3
        WHEN '9M FY26' THEN 4
    END;
-- Q3 FY25 -> Q3 FY26: margin improved from -33.0% to -23.7%, ~900bps YoY —
-- consistent with management's "TMRW losses now peaked" statement (Q3 FY26 IP).


-- -----------------------------------------------------------------
-- Q6. Brands without disclosed EBITDA margin — what we CAN say
--     (revenue trend only; Urbano has 3 years, Nobero has 1)
-- -----------------------------------------------------------------
SELECT
    brand,
    fiscal_year,
    revenue,
    data_quality,
    LAG(revenue) OVER (PARTITION BY brand ORDER BY fiscal_year) AS prior_year_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (PARTITION BY brand ORDER BY fiscal_year))
        / LAG(revenue) OVER (PARTITION BY brand ORDER BY fiscal_year), 4
    ) AS revenue_growth_yoy
FROM brand_financials
WHERE brand IN ('Urbano', 'Nobero')
ORDER BY brand, fiscal_year;

-- Urbano: FY24->FY25 +16.7%, FY25->FY26 +53.2% — growth accelerating, and ABDFVL
-- moved to 100% ownership the same day this stake-increase filing was made (17 Sep
-- 2026). No EBITDA margin disclosed, so it cannot yet be placed on the 2x2 — flagged
-- as a brand to watch once profitability data is available.
