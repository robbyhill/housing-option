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
