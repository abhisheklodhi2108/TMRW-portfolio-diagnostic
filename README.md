# TMRW House of Brands — Portfolio Profitability Diagnostic (v2)

TMRW's Wrogn brand loses revenue for every extra ad rupee spent (FY25) — but TMRW's group margin has since improved ~900bps. SQL + Excel + deck diagnosing which Aditya Birla D2C brands deserve capital, using company filings.

A Business Analyst case study: which brands in Aditya Birla's TMRW House of Brands
portfolio are worth scaling, and does TMRW's recent group-level recovery change
the call on any of them?

## The problem

TMRW raised ₹437 Cr from ServiceNow Ventures in August 2025. FY25 brand-level
filings (year ended March 2025) show a genuine spread in performance — The Indian
Garage Co scaling profitably, Bewakoof improving margin through cost discipline,
and Wrogn losing revenue while ad spend rose 63%. But TMRW's more recent Q3 FY26
investor presentation (Oct–Dec 2025) tells a different story at the group level:
EBITDA margin improved ~900 bps YoY, and management says "TMRW losses now peaked."

This project reconciles both: the FY25 brand-level classification (still the
finest-grain data available per brand) alongside the group's more recent trajectory.

## Key finding

Wrogn's FY25 ad spend rose 63% YoY while revenue **fell** 9% — every extra rupee of
ad spend that year is associated with a revenue *decline* (-0.88 ratio). That
evidence still stands. But it can no longer be read in isolation: TMRW's group
margin has since improved from -33.0% to -23.7% (Q3 FY25 → Q3 FY26), and Wrogn's
own FY26 figures aren't separately disclosed. **The recommendation is framed as a
scenario to revisit with fresher data, not a directive to execute on FY25 evidence
alone.**

## What's new in v2

Rebuilt on **primary sources** (company press releases, an SE intimation, an AGM
speech, and a sell-side investor presentation) instead of secondary press coverage
alone:
- Corrected Nobero's FY25 revenue to a company-sourced ₹133.5 Cr, replacing an
  earlier unreliable GMV-tracker estimate of ~₹500 Cr
- Added **Urbano**, a 5th brand (via Imperial Online Services) with a 3-year
  revenue trend showing accelerating growth (+16.7% then +53.2% YoY) — ABFRL took
  it to 100% ownership on 17-Sep-2026
- Added a **TMRW group trajectory** analysis (quarterly EBITDA margin, Q3 FY25
  through Q3 FY26) showing the recent turnaround
- Softened the Wrogn recommendation with an explicit caveat once the group-level
  recovery data was available

## Repo structure

```
├── data/
│   └── 01_schema_and_seed.sql      # SQLite schema + brand financials + TMRW/ABFRL
│                                    #   quarterly trajectory tables
├── analysis/
│   └── 02_analysis.sql             # 6 analysis queries: growth, classification,
│                                    #   ad-spend efficiency, reallocation scenario,
│                                    #   TMRW trajectory, Urbano/Nobero trend
├── model/
│   └── TMRW_Portfolio_Diagnostic.xlsx   # 7-tab Excel model incl. TMRW Trajectory
│                                          #   and Urbano Trend tabs
└── deck/
    └── TMRW_Diagnostic_Deck.pptx    # 12-slide PowerPoint presentation
```

## How to run it

```bash
sqlite3 tmrw.db < data/01_schema_and_seed.sql
sqlite3 tmrw.db < analysis/02_analysis.sql
```

(Or open `model/TMRW_Portfolio_Diagnostic.xlsx` — every cell is a live formula, not
a hardcoded number, so it recalculates if you change an assumption.)

## Data sources & limitations

- **ABFRL/ABLBL Q4 FY25 Results Press Release**, 23 May 2025
- **Motilal Oswal Institutional Equities report**, 23 Sep 2025 (brand-level revenue
  table, sourced from company data)
- **ABFRL SE intimation**, 17 Sep 2026 (Imperial/Urbano stake increase to 100%)
- **ABFRL AGM Chairman's Speech**, FY26
- **ABFRL Q3 FY26 Investor Presentation**, board meeting 5 Feb 2026
- **Inc42 / Entrackr** (RoC filings) — TIGC, Bewakoof, Wrogn brand-level FY24/FY25 P&L

Nobero and Urbano have real, company-sourced revenue but no disclosed EBITDA
margin — both are flagged "Watch," not force-fit into the 2x2 classification.
The 2x2 itself is a simple rule-based split (appropriate for 3 comparable data
points), not a statistical clustering — the rule is stated in the SQL comments.

## Tools used

SQL (SQLite), Excel (formula-driven financial model), PowerPoint (pptxgenjs), and
primary-source research (reconciling company filings, investor presentations and
press coverage where they overlap or conflict).

---
*Built as a portfolio project to demonstrate Business Analyst skills — problem
framing, financial modeling, SQL, and communicating a recommendation that updates
honestly when better data becomes available.*
