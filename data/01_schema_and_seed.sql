-- =========================================================
-- TMRW House of Brands — Portfolio Profitability Diagnostic
-- Schema + seed data
-- Source: RoC filings as reported by Inc42 / Entrackr (2025-2026),
--         Mint/VentureIntelligence (TMRW consolidated, Aug 2025)
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
    data_quality    TEXT    NOT NULL DEFAULT 'audited',  -- 'audited' (RoC filing) or 'estimate' (3rd-party tracker)
    source          TEXT,
    PRIMARY KEY (brand, fiscal_year)
);

INSERT INTO brand_financials (brand, fiscal_year, revenue, net_loss, ebitda_margin, ad_spend, data_quality, source) VALUES
('TIGC',      'FY24', 101.5,  5.0,   NULL,   NULL, 'audited', 'Entrackr, 15 Jan 2026 (RoC filing)'),
('TIGC',      'FY25', 204.0,  -23.0, -0.0637, NULL, 'audited', 'Entrackr, 15 Jan 2026 (RoC filing)'),

('Bewakoof',  'FY24', 160.9,  -103.1, -0.59,  46.9, 'audited', 'Inc42, 31 Oct 2025 (RoC filing)'),
('Bewakoof',  'FY25', 173.0,  -73.2,  -0.34,  48.6, 'audited', 'Inc42, 31 Oct 2025 (RoC filing)'),

('Wrogn',     'FY24', 245.3,  -56.8,  NULL,   40.0, 'audited', 'Inc42 / Entrackr, 25 Sep 2025 (RoC filing) — FY24 ad spend implied from reported 63% YoY increase'),
('Wrogn',     'FY25', 223.2,  -75.5,  -0.275, 65.0, 'audited', 'Inc42 / Entrackr, 25 Sep 2025 (RoC filing) — ad spend +63% YoY, revenue declined'),

('Nobero',    'FY25', 500.0,  NULL,   NULL,   NULL, 'estimate', 'ECDB e-commerce GMV tracker — ~$60M GMV, +75-80% YoY. GMV is NOT audited operating revenue; treat as directional only.');

-- TMRW consolidated (all brands), quarterly — kept separate since it is not brand-level
DROP TABLE IF EXISTS tmrw_consolidated;
CREATE TABLE tmrw_consolidated (
    period          TEXT NOT NULL PRIMARY KEY,
    revenue         REAL,
    ebitda_loss     REAL,
    source          TEXT
);

INSERT INTO tmrw_consolidated (period, revenue, ebitda_loss, source) VALUES
('Q1 FY25', 85.0,  39.0, 'Inc42, 8 Nov 2024'),
('Q2 FY25', 175.0, 38.0, 'Inc42, 8 Nov 2024'),
('Q1 FY26', 197.0, 63.0, 'Mint / VentureIntelligence, Aug 2025 — ServiceNow Ventures funding announcement');
