# Overall notes
## Design:
* Omit the title from the plot/image itself and instead include the title/footnotes in the Quarto file when that Quarto document is eventually produced.
* Use consistent color and visual variable design when producing the visualizations
	* Always use black boundaries to show the GLA boundary, borough boundaries
	* Always use dots to demonstrate 
	* If you use blue->red chloropleth for one visualization (e.g., PTAL scores), then similar visualizations (e.g., isochromes of travel accessibility) should use different color gradients
* Unless stated otherwise, try to minimize the amount of 'chartjunk' per Tufte. A few counterexamples to this principle are labeling specific data points with text when making plots (this is often helpful), using occasional gridlines where they improve readability, and using color. 
## Visual verification
* Always check your code and
# List of visualizations
1. Chloropleth map of PTAL at LSOA level, shaded using a cool to hot scale, and showing the 1a/1b and 6a/6b subdivsions
	1. use the PTAL data: '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/LSOA_aggregated_PTAL_stats_2023.geojson'
	2. include the outer boundary for Greater London for style: '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/gla'
	3. Include the borough boundaries in black to make the boundaries stand out and show within-borough variation: '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/statistical-gis-boundaries-london'
	4. Add TfL stations to show how PTAL score varies closely with Tube, Rail, LU, LO, DLR, and Tramlink access. Show as dots on the map. Identify Tube stop as a black dot and all other stops as an open dot, and include in the legend. Omit those TfL stations outside the Greater London boundary:  '/Users/roberthill/Library/Mobile Documents/com~apple~CloudDocs/oxford/ebsipe/option/housing/data/Underground_Stations.geojson'
2. Bar chart showing the 