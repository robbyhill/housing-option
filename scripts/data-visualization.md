# Overall notes

You shouldn't split all of the data analysis and visualization work across different scripts. To the best of your ability, you should conduct all analysis necessary in a `main.R` and spin of `dataviz.R` or helper functions where necessary, but you certainly shouldn't have individual scripts for each visualization. 

If you're ever unsure about a specific visualization, you should ask for clarification. 
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
	2. include the outer boundary for Greater London for style: '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/gla'
	3. Include the borough boundaries in black to make the boundaries stand out and show within-borough variation: '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/statistical-gis-boundaries-london'
	4. Add TfL stations to show how PTAL score varies closely with Tube, Rail, LU, LO, DLR, and Tramlink access. Show as dots on the map. Identify Tube stop as a black dot and all other stops as an open dot, and include in the legend. Omit those TfL stations outside the Greater London boundary: `data/tfl_stations/` (Underground, DLR, Elizabeth line, Overground, Tramlink geojsons)
2. Bar charts showing the percentages of the population living in each of the different PTAL categories, with `facet_wrap()` by different covariates of lower mobility
	1. Use the PTAL data and combine it with the ONS' data: '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/lsoa/ons/household_composition'
	2. The goal is to see LSOAs' PTAL scores co-vary with things like economic composition of the household, age, qualifications, and tenure
3. Regression table showing the same information as visualization (2), except the statistical approach. Regression of PTAL score ~ ONS covariates + TfL access 