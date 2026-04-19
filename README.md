# 🏏 IPL Data Analysis — RCB Auction Strategy 2017
Data-driven IPL analysis and auction strategy for Royal Challengers Bangalore using SQL and  Excel 

![SQL](https://img.shields.io/badge/SQL-MySQL-blue)
![Excel](https://img.shields.io/badge/Tool-Excel-green)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

## 📌 Overview
End-to-end SQL-based analysis of IPL data (2008–2016) to build a **data-driven auction strategy** for Royal Challengers Bangalore's 2017 mega auction. Analyzed 37,000+ ball-by-ball records across 18 database tables to identify top performers, derive KPIs, and recommend the optimal squad.

---

## 🎯 Problem Statement
> *"You are hired as a sport data analyst by RCB where the team is looking for top-performing and reliable players to win tournaments, considering both on-field performance and value for money in the mega player auction of 2017."*

RCB has reached the IPL final **3 times (2009, 2011, 2016)** and lost all three. This project uses data to find out exactly why — and what to do about it.

---

## 🗄️ Database Structure
| Metric | Value |
|--------|-------|
| Total Tables | 18 |
| Ball-by-ball Records | 37,284 |
| Players | 469 |
| Matches | 255 |
| Seasons Covered | 2008 – 2016 |
| Venues | 35 |

---

## 🔍 Key Findings

### Batting
- **V Kohli** leads with 39.87 avg runs/match across 62 matches — sustained excellence not a purple patch
- **AB de Villiers** — only player combining 34.53 avg AND 163.74 strike rate — irreplaceable
- **DA Warner** — 38.49 avg across 61 matches — Kohli's closest rival in consistency

### Bowling
- RCB's wickets declined from **78 (2013) → 71 (2016)** while batting improved every season
- **JJ Bumrah** — 2.00 avg wickets/match — data identified him as future world-class bowler early
- **SP Narine** — 6.24 economy rate — most economical bowler in IPL

### RCB Insights
- Wins **55.17%** at home (Chinnaswamy) vs **45.45%** away — home advantage is real but underutilized
- Fielding first wins **54.84%** overall — toss strategy must be venue-specific
- **2016 was RCB's best batting season** (2,859 runs) — they still lost the final to SRH's bowling

---

## 📊 KPIs Derived
| KPI | Leader | Value |
|-----|--------|-------|
| Powerplay Run Rate | Gujarat Lions | 7.49 RPO |
| Death Over Run Rate | **RCB leads!** | 10.39 RPO |
| Most Economical Bowler | SP Narine | 6.24 economy |
| Dot Ball % | R Rampaul | 50.36% |
| Boundary % | AD Russell | 24.46% |

---

## 🏆 RCB Dream XI — 2017 Mega Auction

| # | Player | Role | Nationality | Key Stat |
|---|--------|------|-------------|----------|
| 1 | V Kohli ⭐ | Opener | 🇮🇳 Indian | 39.87 avg, composite 54.09 |
| 2 | DA Warner | Opener | 🌍 Overseas | 38.49 avg, composite 54.25 |
| 3 | AB de Villiers ⭐ | Middle Order | 🌍 Overseas | 163.74 SR, composite 56.72 |
| 4 | CH Gayle | Middle Order | 🌍 Overseas | 33.35 avg, 45.83 composite |
| 5 | AD Russell | All-rounder | 🌍 Overseas | 163 SR + 1.84 avg wickets |
| 6 | YK Pathan | All-rounder | 🇮🇳 Indian | 24.02 avg, 139.28 SR |
| 7 | RA Jadeja | All-rounder | 🇮🇳 Indian | 1.93 avg wickets, 7.58 eco |
| 8 | JJ Bumrah | Pace Bowler | 🇮🇳 Indian | 2.00 avg wickets/match |
| 9 | YS Chahal | Spin Bowler | 🇮🇳 Indian | 31 wickets at Chinnaswamy |
| 10 | B Kumar | Pace Bowler | 🇮🇳 Indian | 1.79 avg wickets, 77 total |
| 11 | STR Binny | All-rounder | 🇮🇳 Indian | 6.87 economy — most economical |

> ✅ Overseas players: Warner, ABD, Gayle, Russell = exactly 4 (IPL rule compliant)

---

## 🎯 Three-Tier Auction Strategy

**🔴 Tier 1 — Must Retain (no matter the cost)**
- V Kohli
- AB de Villiers

**🟡 Tier 2 — Priority Buys (bid aggressively)**
- DA Warner
- AD Russell
- JJ Bumrah
- YS Chahal

**⚪ Tier 3 — Value Picks (smart budget buys)**
- YK Pathan
- RA Jadeja
- B Kumar
- STR Binny

---

## 🛠️ Tools & Technologies
- **MySQL** — 15 objective queries + subjective supporting queries
- **SQL Concepts** — JOINs, CTEs, Window Functions (LAG, DENSE_RANK, RANK), CASE WHEN, Subqueries
- **Excel** — 20+ charts (bar, line, scatter, pie, dual-axis)
- **PowerPoint** — 25-slide management presentation

---

## 📁 Project Structure
rcb-ipl-analysis/
│
├── ipl_analysis.sql        # All SQL queries with proper comments
├── IPL_Report.docx         # Complete analysis document with charts
├── IPL_Presentation.pptx   # 25-slide management presentation
└── README.md               # This file

---

## 📈 Composite Scoring Model
To objectively rank players for auction I created a custom composite score:

This combines **consistency** (average) with **aggression** (strike rate) into one number — removing bias from auction decisions.

| Player | Avg Runs | Strike Rate | Composite Score |
|--------|----------|-------------|-----------------|
| AB de Villiers | 34.53 | 164.27 | **56.72** |
| DA Warner | 38.49 | 140.94 | **54.25** |
| V Kohli | 39.87 | 135.68 | **54.09** |

---

## 👤 Author
**Varun Kandunuri**
- 📧 kandunurivarun123@gmail.com
- 💼 [LinkedIn](https://www.linkedin.com/in/varun-kandunuri-14053a268/)
- 🐙 [GitHub](https://github.com/zoroLuffy11)

---

*This project was completed as part of the Data Science certification at Newton School of Technology.*
