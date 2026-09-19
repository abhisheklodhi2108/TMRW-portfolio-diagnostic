# TMRW House of Brands — Portfolio Profitability Diagnostic

A Business Analyst case study: which brands in Aditya Birla's TMRW House of Brands
portfolio (Bewakoof, Wrogn, The Indian Garage Co, Nobero) are actually worth scaling,
and which are burning cash without a return?

## The problem

TMRW raised ₹437 Cr from ServiceNow Ventures in August 2025. Its Q1 FY26 revenue grew
38% YoY to ₹197 Cr — but its EBITDA loss grew even faster, from ₹46 Cr to ₹63 Cr in the
same quarter. Every brand under the house is chasing growth through ads, discounts, and
new stores, but not all of that spend is converting. This project uses each brand's
FY25 (year ended March 2025) financial filings to figure out which brands deserve more
capital, which need a cost fix, and which should be cut back.

## Key finding

Wrogn's advertising spend rose 63% YoY in FY25 — while its revenue **fell** 9%. The
incremental-spend-to-incremental-revenue ratio comes out **negative (-0.88)**: every
extra rupee spent on ads that year is associated with a revenue *decline*, not a gain.
Meanwhile, The Indian Garage Co doubled revenue (+101%) at the best EBITDA margin in
the portfolio (-6.4%, vs. Wrogn's -27.5% and Bewakoof's -34%).

**Recommendation:** freeze Wrogn's incremental ad spend and redeploy it toward TIGC,
which is closest to profitable scale. Modeled impact: ~₹12 Cr net portfolio EBITDA
improvement (see `analysis/02_analysis.sql`, Q4).

## Repo structure

```
├── data/
│   └── 01_schema_and_seed.sql      # SQLite schema + brand-level FY24/FY25 financials
├── analysis/
│   ├── 02_analysis.sql             # 5 analysis queries (growth, classification,
│   │                                #   ad-spend efficiency, reallocation scenario)
│   └── sample_query_output.txt     # pre-run output of every query, for quick review
├── model/
│   └── TMRW_Portfolio_Diagnostic.xlsx   # same analysis as a live Excel model
└── deck/
    └── TMRW_Portfolio_Diagnostic_Deck.html  # presentation-ready summary deck
```

## How to run it

```bash
sqlite3 tmrw.db < data/01_schema_and_seed.sql
sqlite3 tmrw.db < analysis/02_analysis.sql
```

(Or open `model/TMRW_Portfolio_Diagnostic.xlsx` — every cell is a live formula, not a
hardcoded number, so it recalculates if you change an assumption.)

## Data sources & limitations

All brand-level figures are sourced from RoC (Registrar of Companies) filings, as
reported by Inc42 and Entrackr — full citations are in the `source` column of
`brand_financials` and in the Excel model's **Sources** tab.

- **Nobero** has no publicly filed FY25 statement. The only available figure is a
  third-party e-commerce GMV estimate (~$60M, +75-80% YoY), which is **not** the same
  as audited operating revenue — it's excluded from the ranked comparison and flagged
  in the data as `data_quality = 'estimate'`.
- **TIGC's ad spend** is not separately disclosed, so the reallocation scenario
  (Q4) uses an assumed revenue-per-ad-rupee efficiency, stated explicitly as an
  assumption in the query comments and the Excel model.
- The 2x2 classification is a simple rule-based split (appropriate for 3 comparable
  data points), not a statistical clustering — the rule is stated in the SQL comments.

## Tools used

SQL (SQLite), Excel (formula-driven financial model), and secondary/desk research
(triangulating public financial filings where the company doesn't disclose brand-level
numbers directly).

---
*Built as a portfolio project to demonstrate Business Analyst skills — problem framing,
financial modeling, SQL, and communicating a recommendation from imperfect public data.*
