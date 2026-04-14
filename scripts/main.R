# main.R
#
# Master analysis script for the housing-option paper.
# Sources dataviz.R for all plotting functions.
# Run from the project root (housing/).
# Outputs saved to scripts/outputs/.

library(sf)
library(dplyr)

source("scripts/dataviz.R")

dir.create("scripts/outputs", showWarnings = FALSE, recursive = TRUE)

# ── 1. Load spatial / boundary data ──────────────────────────────────────────

ptal     <- st_read("data/LSOA_aggregated_PTAL_stats_2023.geojson", quiet = TRUE)
gla      <- st_read("data/gla/London_GLA_Boundary.shp",             quiet = TRUE)
boroughs <- st_read(
  "data/statistical-gis-boundaries-london/ESRI/London_Borough_Excluding_MHW.shp",
  quiet = TRUE
)

ptal     <- st_transform(ptal,     27700)
gla      <- st_transform(gla,      27700)
boroughs <- st_transform(boroughs, 27700)

# ── 2. Load TfL stations (all modes, clipped to GLA) ─────────────────────────

stations <- {
  files <- list.files("data/tfl_stations", pattern = "[.]geojson$", full.names = TRUE)
  lapply(files, function(f) {
    st_read(f, quiet = TRUE) |> select(NAME, NETWORK, FULL_NAME)
  }) |>
    bind_rows() |>
    st_transform(27700) |>
    st_filter(gla) |>
    mutate(station_type = if_else(
      NETWORK == "London Underground", "Underground station", "Other TfL station"
    ))
}

# ── 3. Prep PTAL data for choropleth ─────────────────────────────────────────

ptal_graded <- ptal |>
  mutate(ptal_grade = factor(MEAN_PTAL_, levels = PTAL_LEVELS, ordered = TRUE))

# ── 4. Load ONS Census 2021 LSOA data and join to PTAL ───────────────────────
# Each GPKG contains multiple layers; we read the Lower_Super_Output_Area layer.
# The join is keyed on LSOA21CD (PTAL) == geog_code (ONS), naturally filtering
# to London's 4,994 LSOAs.

read_ons_lsoa <- function(path) {
  st_read(path, layer = "Lower_Super_Output_Area", quiet = TRUE) |>
    st_drop_geometry() |>
    distinct(geog_code, .keep_all = TRUE)   # 50 exact duplicate rows in source data
}

ons_economic  <- read_ons_lsoa("data/lsoa/ons/economic/ons-economic-ew-2021_6355563.gpkg")
ons_age       <- read_ons_lsoa("data/lsoa/ons/age/ons-age-ew-2021_6355560.gpkg")
ons_quals     <- read_ons_lsoa("data/lsoa/ons/qualifications/ons-qualifications-ew-2021_6355565.gpkg")
ons_tenure    <- read_ons_lsoa("data/lsoa/ons/tenure/ons-tenure-ew-2021_6355566.gpkg")
ons_cars      <- read_ons_lsoa("data/lsoa/ons/car_availability/ons-car-availability-ew-2021_6355561.gpkg")

london_ons <- ptal |>
  st_drop_geometry() |>
  select(LSOA21CD, mean_AI = mean_AI) |>
  inner_join(select(ons_economic, geog_code, unemployed_perc),
             by = c("LSOA21CD" = "geog_code")) |>
  inner_join(select(ons_age,  geog_code, age_65_plus_perc),
             by = c("LSOA21CD" = "geog_code")) |>
  inner_join(select(ons_quals, geog_code, no_qualifications_perc),
             by = c("LSOA21CD" = "geog_code")) |>
  inner_join(select(ons_tenure, geog_code, rent_social_perc, private_rent_perc),
             by = c("LSOA21CD" = "geog_code")) |>
  inner_join(select(ons_cars, geog_code, no_car_perc),
             by = c("LSOA21CD" = "geog_code"))

message("London LSOAs in joined dataset: ", nrow(london_ons))

# ── 5. Generate and save visualisations ──────────────────────────────────────

# Vis 1: PTAL choropleth
p1 <- plot_ptal_choropleth(ptal_graded, boroughs, gla, stations)
ggsave("scripts/outputs/vis1-ptal-choropleth.png",
       p1, width = 10, height = 8, dpi = 300, bg = "white")
ggsave("scripts/outputs/vis1-ptal-choropleth.pdf",
       p1, width = 10, height = 8)
message("Saved vis1-ptal-choropleth")

# Vis 2: Mean PTAL by covariate quartile
p2 <- plot_ptal_by_covariate(london_ons)
ggsave("scripts/outputs/vis2-ptal-by-covariate.png",
       p2, width = 10, height = 6, dpi = 300, bg = "white")
ggsave("scripts/outputs/vis2-ptal-by-covariate.pdf",
       p2, width = 10, height = 6)
message("Saved vis2-ptal-by-covariate")

# Vis 3: Regression table
model <- run_ptal_regression(london_ons)
save_regression_table(model, "scripts/outputs/vis3-regression-table.html")
message("Saved vis3-regression-table")
message("\nAll outputs written to scripts/outputs/")
