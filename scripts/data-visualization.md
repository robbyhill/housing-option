# Overall notes

You shouldn't split all of the data analysis and visualization work across different scripts. To the best of your ability, you should conduct all analysis necessary in a `main.R` and spin off `dataviz.R` or helper functions where necessary, but you certainly shouldn't have individual scripts for each visualization. 

If you're ever unsure about a specific visualization, you should ask for clarification. 

Always add legends, cardinal directions, and scales to maps

## PTAL
* All mapping visualizations should use the 1a-6b banding system instead of the 0 to ~100 Access Index. 
* The bar chart should use the 0 to ~100 Access Index, and include in the footer how Access Index maps to PTAL 
	* For mapping schema, see '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/ai_to_ptal.png'
* The regression uses OLS with the continuous Access Index (0–100+) as the outcome. PTAL bands are used for mapping only — the AI is the actual underlying measurement and avoids the unequally-spaced band-boundary problem in ordinal models.

## Design:
* Omit the title from the plot/image itself and instead include the title/footnotes in the Quarto file when that Quarto document is eventually produced.
* Use consistent color and visual variable design when producing the visualizations
	* Always use black boundaries to show the GLA boundary, borough boundaries
	* Always use dots to demonstrate station locations. Whenever transport stops are shown, include **all TfL modes** (Underground, DLR, Elizabeth line, Overground, Tramlink) from `data/tfl_stations/`. Always differentiate: Underground stations = filled black dot; all other TfL stops = open black dot. Always clip stations to the GLA boundary.
	* If you use blue->red chloropleth for one visualization (e.g., PTAL scores), then similar visualizations (e.g., isochromes of travel accessibility) should use different color gradients
* Unless stated otherwise, try to minimize the amount of 'chartjunk' per Tufte. A few counterexamples to this principle are labeling specific data points with text when making plots (this is often helpful), using occasional gridlines where they improve readability, and using color. 
## Visual verification
* Always check your code and check that the output is intended. If anything looks off or unclear, double check your own work. 
* You're capable of handling all of your own bugs. You should do that. 
# List of visualizations
1. Chloropleth map of PTAL at LSOA level, shaded using a cool to hot scale, and showing the 1a/1b and 6a/6b subdivsions
	1. use the PTAL data: '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/LSOA_aggregated_PTAL_stats_2023.geojson'
	2. include the outer boundary for Greater London for style:
		1. '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/gla'
	3. Include the borough boundaries in black to make the boundaries stand out and show within-borough variation: 
		1. '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/statistical-gis-boundaries-london'
	4. Add TfL stations to show how PTAL score varies closely with Tube, Rail, LU, LO, DLR, and Tramlink access. Show as dots on the map. Identify Tube stop as a black dot and all other stops as an open dot, and include in the legend. Omit those TfL stations outside the Greater London boundary: `data/tfl_stations/` (Underground, DLR, Elizabeth line, Overground, Tramlink geojsons)
2. The same as (1), but with a few differences: 
	1. A three-dimensional map with the z-dimension showing the population at the LSOA-level. Use the 2024 estimates of LSOA population by age and gender, but aggregate to one overall LSOA population figure
		1. ''/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/lsoa/sapelsoasyoa20222024.xlsx'
	2. Still use the PTAL 1a to 6b bands. 
	3. Drop the boundaries for boroughs and LSOAs, as those will be hard to project
	4. Drop the TfL stations, as those will not project cleanly onto the 3d visualization
3. Bar charts showing how Access Index (not PTAL band) is associated with various covariates, using  `facet_wrap()`
	1. Use the following file for reference: 
		1. '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/scripts/outputs/vis2-ptal-by-covariate.png'
	2. The covariates included with the `facet_wrap()` should be: 
	3. X-axis should be LSOA's quartile. Y-axis should be Access Index 
	4. the bars should have the same color
4. Regression table showing the same information as visualization (3), except the statistical approach.
	1. OLS regression of PTAL Access Index (continuous, 0–100+) ~ standardised ONS covariates + population density
	2. Predictors are standardised (mean=0, SD=1) so coefficients are directly comparable in magnitude
	3. In the notes: state that the outcome is the raw Access Index; include the AI→PTAL band mapping; note that results are robust to ordered logistic regression on PTAL bands
	4. Interpret as: a one-SD increase in each predictor is associated with β change in Access Index
5. Map showing the location of brownfield sites in London
	1. Add borough boundaries
	2. Add TfL stations 
	3. Add London boundary 
	4. Shade the brownfield sites brown 
6. Scatterplot showing the relationship between log(brownfield site size (hectares)) and distance to the nearest TfL station (m)  
	1. Include all geojsons in the `tfl_stations/` folder -- I.e., measure the distance from the brownfield site to any TfL station, not just a tube stop
	2. Use the polygon centroid from the geopackage as the location of site `i` for all sites. Do NOT use `geox`/`geoy` from the CSV — submitted coordinates are a mix of CRS systems and contain errors.
	3. Use `Shape_Area / 10000` from the geopackage as site area in hectares. Do NOT use `hectares` from the CSV — ~80% of values are rounded to 2dp and ~40% differ from the GIS area by >20%
	4. Filter to `gis_ha > 0.01` to remove polygon slivers/geometry errors.
	5. Put log site area (GIS hectares) on the x-axis and distance to TfL station (m) on the y-axis
	6. Add a horizontal dashed reference line at 800m labelled "800m walkability threshold (DfT)", citing DfT Manual for Streets (2007)
	7. For the notes, use the Quarto image notes feature, not R native captions
7. Map of the Greater Boston Region showing the location of the upzoned MBTA slices
	1. overlay the MA municipal boundaries
	2. Add in the MBTA rapid transit stops:
		1. '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/mbta_rapid_transit'
	3. Add in MA commuter rail stations
		1. '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/MBTA_Commuter_Rail_Stations'
	4. Clip the boundaries to those municipalities identified in the CSV:
		1. '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/MBTA Communities Community Categories and Capacity Calculations for web_June2025.csv'
	5. Shade the municipalities according to their community category/percentage of housing stock needed in new zone
