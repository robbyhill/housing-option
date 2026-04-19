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

## Session 3 — 2026-04-17/18

**Tool:** Claude Code (claude-sonnet-4-6) via CLI

### Interactions

13. **Policy research: demand-side housing subsidies and transport accessibility**
    Researched whether London/UK housing demand-side subsidies (Housing Benefit, Universal Credit/LHA, Help to Buy) are conditioned on transport accessibility or PTAL. Finding: no explicit conditionality exists. Explained the Housing Benefit → Universal Credit transition and the LHA/BRMA rate-setting mechanism. Identified that LHA's BRMA geography (supra-borough) obscures sub-borough variation in mobility, and that LHA's 30th-percentile rent cap may push low-income households toward lower-PTAL areas.

14. **Policy research: congestion charging and housing demand (Tang 2017)**
    Read and analysed Tang, C.K. (2017), "The Cost of Traffic: Evidence from the London Congestion Charge" (LSE working paper). Key finding: homebuyers pay 4.27% more in the CCZ and 2.23% more in the WEZ after the charge is implemented. User clarified that this paper evidences WTP to avoid traffic disamenity rather than WTP for transit accessibility per se. Identified Gibbons & Machin (2005) as the more appropriate citation for transit accessibility premiums in housing markets.

15. **Writing: Top-Down Approaches section (`papers/summative_v1.docx`)**
    Extracted text from the "old material" section of the draft paper (docx via Python zipfile) and rewrote it as the "Top-Down Approaches" sub-section of "Policies to Boost the Supply of Housing in High-PTAL LSOAs". Covers TOD rationale, London's housing delivery shortfall, the London Plan/NPPF mechanism, and its two structural failures (prisoner's dilemma, regulatory accumulation). Edited directly into the docx using python-docx. Original old material preserved in place.

16. **Vis 5: Brownfield sites map (`plot_brownfield_map()`)**
    Loaded GLA Brownfield Land Register geopackage (3,066 sites, MultiPolygon, EPSG:27700) and CSV (28-column attribute table). Produced a map overlaying brownfield polygons (brown fill) on borough boundaries with TfL stations and GLA boundary. Installed `ggspatial` for scale bar and north arrow.

17. **Vis 6: Brownfield site area vs distance to TfL station (`plot_brownfield_distance()`)**
    Scatterplot of log(GIS hectares) vs distance to nearest TfL station (m). Extensive data quality investigation:
    - CSV `hectares` field rejected: ~80% of values rounded to 2dp, ~40% differ from GIS area by >20% — LPAs submitted estimates not GIS measurements. Switched to `Shape_Area / 10000` from geopackage.
    - CSV `geox`/`geoy` coordinates rejected: 1,180 sites submitted BNG coordinates instead of WGS84; additional invalid values. Switched to polygon centroids from geopackage for all sites.
    - Added `gis_ha > 0.01` filter to exclude polygon slivers.
    - Added 800m reference line citing DfT *Manual for Streets* (2007) as the standard walkability threshold for rail stations.
    - Updated `data-visualization.md` and created `scripts/figure-notes.md` as a holding file for Quarto figure notes.

18. **Policy research: TOD catchment radius standards**
    Researched accepted walking-distance thresholds for TOD in UK and metric countries. UK standard: 800m (DfT) to 960m (TfL/PTAL methodology) for rail stations. International metric countries converge on 400m (bus) / 800m (rail). The US half-mile (~800m) is consistent with UK practice.

19. **Policy concepts: land value capture and street votes**
    Provided brief definitions of land value capture (Section 106, CIL as UK instruments) and the 2022–23 street votes proposal (Hughes & Southwood, Policy Exchange; included in LURA 2023 but not operationalised). User clarified that street votes is unambiguously a bottom-up supply-side mechanism — the supermajority threshold is an empirical obstacle to delivery, not a conceptual tension.

### Scope of AI contribution
The AI tool performed: policy literature research, document editing (docx), R code development and debugging, data quality investigation, and file maintenance. All analytical framing, paper argument direction, and policy interpretation came from the user.

---

## Session 4 — 2026-04-18/19

**Tool:** Claude Code (claude-sonnet-4-6) via CLI

### Interactions

20. **HCV and transport access findings (`political_economy/hill_final.docx`)**
    Read the user's prior political economy paper on US housing policy. Extracted key findings on Housing Choice Vouchers: Graves (2016) identifies limited transit access as one of four barriers to HCV uptake in high-opportunity areas; user's paper distinguishes real vs informational transit barriers and recommends transit mapping tools via mobility counselling programs. User noted the parallel to London's LHA/BRMA argument.

21. **MBTA Communities Act dataset inspection (`data/mbta_new_area_slices.gpkg`)**
    Inspected the MBTA area slices geopackage: 1,898 polygon features across 110 municipalities, fields: id_union, jurisdiction_id, jurisdiction, county, acres; CRS WGS 84. Also inspected companion data: MBTA rapid transit nodes (170 points, LINE field), commuter rail stations (166 points, STATE field — 4 RI stations present), and the MBTA Communities CSV (177 communities, 4 categories, capacity % of housing stock).

22. **Vis 7: MBTA Communities map (`plot_mbta_communities()`)**
    Built an R map of Greater Boston showing municipalities shaded by MBTA community category (Rapid Transit / Commuter Rail / Adjacent community / Adjacent small town) with upzoned area slice outlines in orange and commuter rail station dots. Multiple rounds of iteration: (a) installed `tigris` package and pulled MA municipal boundaries via `county_subdivisions()`; (b) fixed name-matching (tigris appends " Town"/" City", uses "Manchester-by-the-Sea"); (c) removed rapid transit nodes (too clustered); (d) changed commuter rail from triangles to dots; (e) fixed north arrow style; (f) removed caption/sources from image for Quarto; (g) dissolved slices to municipality level and drew as orange outlines rendered on top of station dots for visibility; (h) clipped commuter rail to MA only and to matched municipalities to remove floating Boston-area dots. Updated `figure-notes.md`, `CLAUDE.md`, and `data-visualization.md`.

23. **Population and area computations**
    Used `tidycensus` (installed) to pull 2020 Decennial Census population for MBTA communities + Boston: ~5.1M across 168 matched municipalities. Breakdown: Commuter Rail 2.3M, Adjacent community 1.1M, Rapid Transit 760K, Boston 676K, Adjacent small town 264K. Computed area of MBTA communities region (dissolved union): 9,062 km². Computed Greater London area from GLA boundary: 1,595 km². MBTA region is ~5.7× the size of Greater London with ~57% of the population.

24. **Policy research: MBTA Communities Act rationale and quote**
    Confirmed the Act is framed primarily as a housing supply measure, not a transport expansion effort. Key quote from Housing Secretary Mike Kennealy (2022): "The multifamily zoning requirement is all about setting the table for more transit-oriented housing in the years and decades ahead—which is not just good housing policy, but good climate and transportation policy, too." Source: Massachusetts Housing Partnership, verified via web fetch.

25. **Policy research: UK Planning and Infrastructure Bill TOD provisions**
    Researched the Bill's transit-oriented development provisions. Key findings: "default yes" presumption for housing within ~800m of stations; 40 dph minimum around all qualifying stations, 50 dph for "well-connected" stations (top 60 TTWAs by GVA, ≥4 trains/hour); Pennycook quote on development corporations and transport provision. Flagged that the NPPF 2025 density provisions are still in draft consultation; Bill's Royal Assent date (claimed December 2025) was flagged as unverified.

26. **Paper structure advice (`papers/summative_v1.docx`)**
    Read the full draft and advised on where PIB material fits: (a) at end of "Top-Down Approaches" section as government's response to the failures described, (b) in the incomplete para 35 on London lacking zoning. Framed the analytical thread: PIB sits between the current NPPF (discretionary) and the MBTA Act (mandatory) on a binding-mechanism spectrum.

### Scope of AI contribution
The AI tool performed: R code development and iteration (spatial mapping, statistical computation), policy literature research, dataset inspection, and paper structure advice. All analytical framing, argument direction, variable selection, and paper content came from the user.

---
