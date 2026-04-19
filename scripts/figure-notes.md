# Figure Notes

Holding file for Quarto figure captions and notes. When a Quarto document is created, paste these into the relevant `fig-cap` / `fig-note` fields beneath each figure.

---

## Vis 5: Brownfield Sites in London

**Source:** GLA London Brownfield Land Register; TfL Open Data; GLA London Datastore.

---

## Vis 7: MBTA Communities — Greater Boston Region

**Source:** MBTA Open Data (rapid transit and commuter rail stations); MA EOHLC MBTA Communities Act capacity calculations (June 2025 update); MassGIS municipal boundaries via the `tigris` R package (2024 vintage county subdivisions).

**Notes:**
- Orange polygons are the upzoned multi-family zoning districts ("area slices") designated under the MBTA Communities Act (c.40A §3A). These represent the new zoning areas that municipalities are required to create, not the full municipal footprint.
- Municipality shading reflects the four statutory community categories under the Act: Rapid Transit, Commuter Rail, Adjacent community, and Adjacent small town. Each category carries different minimum unit capacity requirements (ranging from ~5% to ~25% of existing housing stock).
- Rapid transit stops (filled circle) include all MBTA subway and Silver Line nodes. Commuter rail stations (open triangle) include all MBTA commuter rail stops.
- 8 of 177 communities in the CSV could not be matched by exact name to tigris municipal boundaries due to naming conventions (e.g. "Braintree" vs "Braintree Town", "Manchester" vs "Manchester-by-the-Sea"); these are excluded from the choropleth but their upzoned slices remain visible where present.

---

## Vis 6: Log Site Area vs Distance to Nearest TfL Station

**Source:** GLA London Brownfield Land Register; TfL Open Data (all modes).

**Notes:**
- Site locations are polygon centroids computed from the geopackage geometry. The CSV register's submitted `geox`/`geoy` coordinates were not used: approximately 1,180 sites submitted coordinates in British National Grid rather than WGS84, and a number of submitted coordinates were invalid. Polygon centroids from the geopackage are internally consistent and free of CRS ambiguity.
- Site area is `Shape_Area / 10000` from the geopackage (GIS-computed hectares). The CSV `hectares` field was not used: ~80% of values are rounded to 2 decimal places and ~40% of sites differ from the GIS-computed area by more than 20%, indicating that many LPAs submitted estimated rather than measured areas.
- Sites with GIS area < 0.01 ha are excluded as likely polygon slivers or geometry errors (n ≈ 2 sites removed).
- One site (5 Station Road, West Drayton, LB Hillingdon) showed an implausibly large distance (~16 km) in earlier versions when CSV coordinates were used; this is resolved by using the polygon centroid.
- Line: OLS fit with 95% confidence interval.
