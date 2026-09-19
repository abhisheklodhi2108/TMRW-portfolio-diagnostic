-- =========================================================
-- TMRW Portfolio Diagnostic — Analysis Queries
-- Run after 01_schema_and_seed.sql
-- =========================================================

-- -----------------------------------------------------------------
-- Q1. YoY revenue growth and net-loss change, per brand (FY24 -> FY25)
-- -----------------------------------------------------------------
SELECT
    curr.brand,
    prev.revenue                                   AS revenue_fy24,
    curr.revenue                                   AS revenue_fy25,
    ROUND((curr.revenue - prev.revenue) / prev.revenue, 4)      AS revenue_growth_yoy,
    prev.net_loss                                  AS net_loss_fy24,
    curr.net_loss                                  AS net_loss_fy25,
    curr.ebitda_margin                             AS ebitda_margin_fy25,
    CASE
        WHEN prev.net_loss > 0 AND curr.net_loss < 0 THEN 'Flipped profit -> loss'
        WHEN prev.net_loss < 0 AND curr.net_loss < 0
             THEN ROUND((curr.net_loss - prev.net_loss) / ABS(prev.net_loss), 4) || ' (loss widened if positive)'
        ELSE 'n/a'
    END                                             AS net_loss_change_yoy
FROM brand_financials curr
JOIN brand_financials prev
    ON curr.brand = prev.brand
   AND curr.fiscal_year = 'FY25'
   AND prev.fiscal_year = 'FY24'
WHERE curr.data_quality = 'audited'
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
    WHERE curr.data_quality = 'audited'
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

-- Note: the classification above is deliberately simple (rule-based, not a statistical
-- clustering) — appropriate for 3 data points. State the rule when presenting: "Scale" =
-- highest growth + best portfolio margin; "Cut/Harvest" = revenue declining while losses
-- still grow; "Fix" = modest growth, watch margin trend.


-- -----------------------------------------------------------------
-- Q3. Which brand's marketing spend actually converted to revenue?
--     (ad spend efficiency = incremental revenue per incremental ad Rs)
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

-- Result for Wrogn: incremental ad spend was positive, incremental revenue was NEGATIVE ->
-- ratio is negative, i.e. every extra rupee of ad spend in FY25 was associated with a
-- revenue DECLINE, not a gain. This is the evidence base for the "Cut/Harvest" call.


-- -----------------------------------------------------------------
-- Q4. Reallocation scenario: freeze Wrogn's incremental ad spend,
--     redeploy into TIGC at TIGC's FY25 EBITDA margin
-- -----------------------------------------------------------------
WITH assumptions (tigc_rev_per_ad_rupee, tigc_ebitda_margin) AS (
    SELECT 8.0, -0.0637   -- tigc_rev_per_ad_rupee is an ASSUMPTION (TIGC ad spend not disclosed) —
                          -- state this explicitly when presenting the result
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
-- Q5. TMRW consolidated trend — is the whole portfolio getting
--     more or less efficient at converting growth into EBITDA?
-- -----------------------------------------------------------------
SELECT
    period,
    revenue,
    ebitda_loss,
    ROUND(ebitda_loss / revenue, 4) AS ebitda_loss_pct_of_revenue
FROM tmrw_consolidated
ORDER BY period;
-- Q1 FY26 vs Q1 FY25: revenue +132%, but ebitda_loss also grew ~62% —
-- losses are growing more slowly than revenue, but not shrinking in absolute terms yet.
