# AI Collaboration Log

Record of interactions with AI tools (Claude Code, claude-sonnet-4-6) during the preparation of this paper. Kept for academic transparency and submission requirements.

---

## Session 1 — 2026-04-14

**Tool:** Claude Code (claude-sonnet-4-6) via CLI

### Interactions

1. **Running notes file (`papers/paper_ideas.md`)**
   Created a running notes file to capture paper ideas. Logged the first substantive argument: that existing analyses of housing development and transport access operate at LA level, which is problematic because (a) there is huge within-LA variation in mobility and (b) housing policy is decided at LA level through LPAs, making LA averages non-actionable for TOD-based solutions. Sub-LA data is needed for LPAs to make targeted decisions.

2. **Data sources file (`data/data-sources.md`)**
   Inspected all datasets in `data/` and created an enriched data sources file recording the title, unit(s) of analysis, and information conveyed for each dataset. Datasets covered: LSOA PTAL Stats 2023 (TfL), TfL Stations GeoJSON, ONS Travel Area Isochrones (London West), ONS Access to Local Amenities (8 XLSX files), TfL Bus Network Performance Summary, DfT Journey Time Statistics 2019 (31 ODS files).

3. **Data sources file corrections and additions**
   Corrected the DfT JTS 500-series unit of analysis from LA to LSOA (per user instruction). Added entries for the GLA outer boundary (`gla/London_GLA_Boundary.shp`) and the GLA Statistical GIS Boundary Files folder (`statistical-gis-boundaries-london/`), with a note that both are used as visualisation aids only.

4. **Choropleth map — PTAL by LSOA (`scripts/ptal-choropleth.R`)**
   Wrote and ran an R script using `sf` and `ggplot2` to produce a choropleth map of PTAL at LSOA level across London with a cool-to-hot colour scale (blue = PTAL 0, red = PTAL 6b). Overlaid white borough boundaries and a dark GLA outer boundary. Output saved to `scripts/outputs/ptal-choropleth.{png,pdf}`.

5. **GitHub repository (`housing-option`)**
   Initialised git in the project root, created `.gitignore` to exclude data, readings, papers, and output files, and created the public GitHub repository `robbyhill/housing-option`. Committed and pushed the `scripts/` directory and supporting root files.

6. **This log file**
   Created `ai-collaboration-log.md` at the project root to record AI tool usage for academic transparency.

### Scope of AI contribution
The AI tool performed: file inspection and summarisation, code generation (R), git/GitHub setup, and file organisation. All intellectual direction — the paper's argument, framing, choice of datasets, and visualisation goals — came from the user.

---

## Session 2 — 2026-04-14 (continued)

**Tool:** Claude Code (claude-sonnet-4-6) via CLI

### Interactions

7. **PTAL choropleth iterations (`scripts/ptal-choropleth.R`, later folded into `dataviz.R`)**
   Multiple rounds of refinement to the choropleth map: changed borough boundaries from white to black; added all TfL station modes (Underground filled dot, all others open dot); clipped stations to GLA boundary; removed title from plot per design principle (titles to live in Quarto document); fixed legend duplication bug caused by mapping both `shape` and `colour` aesthetics.

8. **Full TfL stations dataset (`data/tfl_stations/`)**
   User added a `tfl_stations/` folder with separate GeoJSON files for each TfL mode (Underground, DLR, Elizabeth line, Overground, Tramlink — 510 stations total). Script updated to load and combine all five files, classifying stations by mode for the filled/open dot distinction. Updated `data-sources.md`, `CLAUDE.md`, and `scripts/data-visualization.md` to reflect the canonical data source and design rule.

9. **Script restructure: `main.R` + `dataviz.R`**
   Per user instruction, consolidated individual per-visualisation scripts into a single `main.R` (data loading, joining, output generation) and `dataviz.R` (plotting functions). Removed `ptal-choropleth.R`.

10. **ONS Census 2021 LSOA data (`data/lsoa/ons/`)**
    Explored 8 ONS Census 2021 datasets (economic, age, qualifications, tenure, car availability, household composition, accommodation, country of birth) — all GeoPackages with multiple layers. Identified that the correct layer is `Lower_Super_Output_Area` (not the default OA layer), and that the source data contains ~50 exact duplicate rows requiring deduplication. All 4,994 London LSOAs in the PTAL data matched successfully via `LSOA21CD == geog_code`.

11. **Vis 2: Mean PTAL by covariate quartile (`plot_ptal_by_covariate()`)**
    Bar chart showing mean PTAL Accessibility Index by London-relative quartile of 6 ONS covariates (unemployed %, age 65+, no qualifications, social renting, private renting, no car), with 95% CI error bars and `facet_wrap()` by covariate. User specified Option C framing (covariate quartile on X axis, mean PTAL on Y).

12. **Vis 3: OLS regression table (`run_ptal_regression()`, `save_regression_table()`)**
    OLS regression of PTAL Accessibility Index on standardised ONS covariates. User confirmed: use `mean_AI` as DV; omit TfL stop binary (circular with PTAL). R² = 0.54. Dominant predictor: `no_car_perc` (+10.2 per SD). Saved as HTML via `modelsummary`.

### Scope of AI contribution
The AI tool performed: iterative code refinement and debugging (R/sf/ggplot2), data exploration, schema reconciliation across sources, and file/repo maintenance. All analytical framing, variable selection, and paper argument direction came from the user.

---
