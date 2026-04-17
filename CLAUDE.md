# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an academic course directory for an Oxford EBSIPE (Economics, Business, Strategy, and Industry Policy for Europe) option course on **Housing Policy/Economics**. It contains course readings, data files, and written work — not a software project.

## Directory Structure

- **`syllabus.pdf`** — Course syllabus with full topic list and assessment details
- **`readings/week1–week8/`** — Weekly academic PDFs organised by topic:
  - Week 1: Housing fundamentals (James 2024, Olsen 2018)
  - Week 2: Comparative housing systems (Flynn, Kemeny, Schwartz, Stephens)
  - Week 3: Financialisation of housing (Aalbers, Dewilde, Hick)
  - Week 4: Housing and social policy (Angel, Blessing, Fitzpatrick)
  - Week 5: Housing wealth and inequality (Arundel, Hick, Watt)
  - Week 6: Rent regulation and private renting (Dewilde, Hick, Kemp ×2, Kholodilin, Nelson)
  - Week 7: Social/affordable housing and segregation (August, DeLuca, Goetz, Khazbak)
  - Week 8: Homelessness and welfare (Fitzpatrick, Nordfeldt, Serpa ×2)
- **`papers/`** — Written work: assignment guidelines (CSP), formative essay (v3 .docx/.pdf), and feedback
- **`data/`** — Datasets used for analysis (full catalogue in `data/data-sources.md`):
  - `LSOA_aggregated_PTAL_stats_2023.geojson` — PTAL scores by LSOA, London 2023 (TfL)
  - `tfl_stations/` — All TfL station points by mode (use this, not the top-level `Underground_Stations.geojson`):
    - `Underground_Stations.geojson` (273), `DLR_Stations.geojson` (45), `Elizabeth_Line_Stations.geojson` (41), `Overground_Stations.geojson` (112), `Tramlink_Stations.geojson` (39) — 510 total
  - `gla/London_GLA_Boundary.shp` — Greater London outer boundary (GLA)
  - `statistical-gis-boundaries-london/` — Borough, Ward, LSOA (2011), MSOA, OA boundaries (GLA)
  - `London_West_Isochrones_Gen_*.gpkg` — PT/walking isochrones at Output Area level, London West (ONS, Nov–Dec 2022)
  - `amenities/` — Access to local amenities by LAD, England & Wales (ONS, 2024): libraries, GPs, dentists, pharmacies, parks, community facilities, post offices, religious worship
  - `journey-time-statistics-2019/` — DfT JTS 2019: journey times to 8 key services by mode; JTS04xx at LA level, JTS05xx at LSOA level
  - `2024-25-annual-network-performance-summary.ods` — TfL bus network reliability metrics (TfL)
  - `2026_02_ma_mbta/` — Massachusetts parking statistics CSVs (1-family and 4-family) and SVG visualisations, created for Abundant Housing MA
- **`scripts/`** — R scripts for data visualisation (tracked in `housing-option` GitHub repo):
  - `data-visualization.md` — visualisation brief and design principles
  - `main.R` — master script: loads all data, joins ONS to PTAL, generates all outputs
  - `dataviz.R` — plotting functions sourced by main.R (one function per visualisation)
  - `outputs/` — generated PNG/PDF/HTML outputs (not tracked in git)

## Data Notes

The MA/MBTA data (`data/2026_02_ma_mbta/`) contains parking statistics by housing type for Massachusetts, used to produce visualisation "donuts" in the style of the Abundant Housing MA Snapshots page. The CSVs are:
- `1_family_parking_stats_MA.csv` — parking stats for single-family homes
- `4_family_parking_stats_MA.csv` — parking stats for 4-family homes

The `data/tfl_stations/` folder contains all TfL station points split by mode (510 stations total across Underground, DLR, Elizabeth line, Overground, Tramlink). Always use this folder rather than the top-level `Underground_Stations.geojson`. Schemas differ across mode files — only NAME, NETWORK, FULL_NAME and geometry are common to all. Station type classification: NETWORK == "London Underground" → Underground; all others → Other TfL.

## Scripts and Visualisations

All R scripts live in `scripts/` and are tracked in the `housing-option` GitHub repo (https://github.com/robbyhill/housing-option). Scripts should be run from the project root (`housing/`). Outputs go to `scripts/outputs/` (gitignored).

**Design principles** (from `scripts/data-visualization.md`):
- No title in the plot itself — titles/captions go in the Quarto document
- Always use black lines for GLA and borough boundaries
- Tube/Underground stations: filled black dot; other TfL stops: open black dot
- Minimise chartjunk (Tufte); exceptions: text labels on specific data points, occasional gridlines, colour
- If blue→red used for one choropleth (e.g. PTAL), use a different palette for similar visualisations

**ONS Census 2021 LSOA data** (`data/lsoa/ons/`): Each dataset is a GeoPackage with multiple layers — always read layer `"Lower_Super_Output_Area"` and call `distinct(geog_code, .keep_all = TRUE)` to remove ~50 duplicate rows in the source data. Join to PTAL on `LSOA21CD == geog_code`. Datasets: economic, age, qualifications, tenure, car_availability, household_composition, accommodation, country_birth.

**Completed visualisations (all in `main.R` / `dataviz.R`):**
1. `plot_ptal_choropleth()` — PTAL by LSOA choropleth, blue→red, with borough boundaries and all TfL station dots
2. `plot_ptal_by_covariate()` — bar charts of mean PTAL AI by quartile of 6 ONS covariates (unemployed %, age 65+, no qualifications, social renting, private renting, no car)
3. `run_ptal_regression()` + `save_regression_table()` — OLS of mean_AI on standardised ONS covariates; R²=0.54, no_car_perc dominant predictor (+10.2)

# Notes on Git commits

When committing to the `housing-option` repo, never show Claude co-authoring. Never commit or push potentially sensitive information. 

# .md files

Always update the `CLAUDE.md` with new information when it becomes available. This is especially important for building context for the paper: the scripts, visualizations, and sources of data all must be like the back of your hand, figuratively speaking. 
