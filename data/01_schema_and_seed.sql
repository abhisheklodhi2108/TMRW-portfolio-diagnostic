-- =========================================================
-- TMRW House of Brands — Portfolio Profitability Diagnostic (v2)
-- Schema + seed data — REBUILT on primary-source documents:
--   - ABFRL/ABLBL Q4 FY25 Results Press Release (23 May 2025)
--   - Motilal Oswal Institutional Equities report (23 Sep 2025)
--   - ABFRL SE intimation re: Imperial/Urbano stake (17 Sep 2026)
--   - ABFRL AGM Chairman's Speech (FY26)
--   - ABFRL Q3 FY26 Investor Presentation (board meeting 5 Feb 2026)
-- Figures in Rs Crore unless noted. NULL = not disclosed.
-- =========================================================

DROP TABLE IF EXISTS brand_financials;

CREATE TABLE brand_financials (
    brand           TEXT    NOT NULL,
    fiscal_year     TEXT    NOT NULL,          -- 'FY24' = year ended Mar 2024, etc.
    revenue         REAL,                       -- operating revenue, Rs Cr
    net_loss        REAL,                       -- negative = loss, positive = profit, Rs Cr
    ebitda_margin   REAL,                       -- stored as fraction, e.g. -0.34 = -34%
    ad_spend        REAL,                       -- advertising/promotion expense, Rs Cr (approx where noted)
    data_quality    TEXT    NOT NULL DEFAULT 'audited',  -- 'audited' (RoC filing), 'reported' (co./broker-sourced), or 'estimate'
    source          TEXT,
    PRIMARY KEY (brand, fiscal_year)
);

INSERT INTO brand_financials (brand, fiscal_year, revenue, net_loss, ebitda_margin, ad_spend, data_quality, source) VALUES
('TIGC',      'FY24', 101.5,  5.0,   NULL,   NULL, 'audited', 'Entrackr, 15 Jan 2026 (RoC filing)'),
('TIGC',      'FY25', 204.2,  -23.0, -0.0637, NULL, 'audited', 'Entrackr, 15 Jan 2026 (RoC filing); revenue cross-checked against Motilal Oswal 23 Sep 2025 (INR 2042m)'),

('Bewakoof',  'FY24', 160.9,  -103.1, -0.59,  46.9, 'audited', 'Inc42, 31 Oct 2025 (RoC filing)'),
('Bewakoof',  'FY25', 173.0,  -73.2,  -0.34,  48.6, 'audited', 'Inc42, 31 Oct 2025 (RoC filing); revenue cross-checked against Motilal Oswal 23 Sep 2025 (INR 1730m)'),

('Wrogn',     'FY24', 245.3,  -56.8,  NULL,   40.0, 'audited', 'Inc42 / Entrackr, 25 Sep 2025 (RoC filing) — FY24 ad spend implied from reported 63% YoY increase'),
('Wrogn',     'FY25', 223.2,  -75.5,  -0.275, 65.0, 'audited', 'Inc42 / Entrackr, 25 Sep 2025 (RoC filing); total income incl. other income was Rs 232.3cr per Motilal Oswal 23 Sep 2025 (INR 2323m)'),

('Nobero',    'FY25', 133.5,  NULL,   NULL,   NULL, 'reported', 'Motilal Oswal 23 Sep 2025 (INR 1335m), Company data — supersedes an earlier GMV-tracker estimate; no margin/net-loss disclosed'),

('Urbano',    'FY24', 66.78,  NULL,   NULL,   NULL, 'audited', 'ABFRL SE intimation, 17 Sep 2026, Annexure A (RoC-sourced 3-yr revenue history)'),
('Urbano',    'FY25', 77.93,  NULL,   NULL,   NULL, 'audited', 'ABFRL SE intimation, 17 Sep 2026, Annexure A'),
('Urbano',    'FY26', 119.38, NULL,   NULL,   NULL, 'audited', 'ABFRL SE intimation, 17 Sep 2026, Annexure A — ABDFVL raised stake from 84.38% to 100% same day');

-- TMRW consolidated (all brands), by quarter — official segment-reported figures
DROP TABLE IF EXISTS tmrw_consolidated;
CREATE TABLE tmrw_consolidated (
    period          TEXT NOT NULL PRIMARY KEY,
    revenue         REAL,
    ebitda          REAL,        -- negative = loss, Rs Cr
    ebitda_margin   REAL,        -- fraction
    yoy_note        TEXT,
    source          TEXT
);

INSERT INTO tmrw_consolidated (period, revenue, ebitda, ebitda_margin, yoy_note, source) VALUES
('Q4 FY25', NULL, NULL, NULL, 'TMRW portfolio grew 27% YoY in Q4 FY25; exited quarter with 16 stores', 'ABFRL/ABLBL Q4 FY25 Results PR, 23 May 2025'),
('Q3 FY25', 187, -62, -0.330, 'Base quarter', 'ABFRL Q3 FY26 Investor Presentation, segmental table'),
('Q3 FY26', 242, -57, -0.237, '+29% YoY revenue (ex-Wrogn); margin up ~900bps YoY; management: "TMRW losses now peaked"', 'ABFRL Q3 FY26 Investor Presentation, segmental table'),
('9M FY25', 506, -146, -0.289, 'Base period', 'ABFRL Q3 FY26 Investor Presentation, segmental table'),
('9M FY26', 662, -182, -0.275, '+31% YoY revenue (ex-Wrogn)', 'ABFRL Q3 FY26 Investor Presentation, segmental table');

-- ABFRL consolidated (parent-level context)
DROP TABLE IF EXISTS abfrl_consolidated;
CREATE TABLE abfrl_consolidated (
    period          TEXT NOT NULL PRIMARY KEY,
    revenue         REAL,
    ebitda          REAL,
    ebitda_margin   REAL,
    pat             REAL,
    note            TEXT,
    source          TEXT
);

INSERT INTO abfrl_consolidated (period, revenue, ebitda, ebitda_margin, pat, note, source) VALUES
('Q4 FY25 (demerged)', 1719, 295, 0.172, -161, 'EBITDA +202% YoY, driven by Pantaloons & ethnic margin expansion', 'ABFRL/ABLBL Q4 FY25 Results PR, 23 May 2025'),
('FY25 (demerged, full year)', 7355, 854, NULL, -624, 'Revenue +14%, EBITDA +64% YoY', 'ABFRL/ABLBL Q4 FY25 Results PR, 23 May 2025'),
('Q3 FY26', 2374, 370, 0.156, -137, 'Revenue +8%, EBITDA +13% YoY, margin +70bps', 'ABFRL Q3 FY26 Investor Presentation'),
('9M FY26', 6187, 655, 0.106, -666, 'Revenue +10%, EBITDA +17% YoY, margin +70bps', 'ABFRL Q3 FY26 Investor Presentation'),
('FY26 (AGM, full year)', 8177, NULL, NULL, NULL, 'Revenue +11% YoY; TMRW grew 34%, added 60+ stores (120 total); Ethnic revenue Rs 2227cr +14%, margin +560bps to 10.8%', 'ABFRL AGM Chairman Speech, FY26');
