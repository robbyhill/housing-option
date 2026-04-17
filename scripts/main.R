# main.R
#
# Master analysis script for the housing-option paper.
# Sources dataviz.R for all plotting functions.
# Run from the project root (housing/).
# Outputs saved to scripts/outputs/.

library(sf)
library(dplyr)
library(readxl)

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

# ── 4. Load ONS Census 2021 LSOA data ────────────────────────────────────────
# Each GPKG contains multiple layers; we read the Lower_Super_Output_Area layer.
# ~50 exact duplicate rows in the source data are removed with distinct().

read_ons_lsoa <- function(path) {
  st_read(path, layer = "Lower_Super_Output_Area", quiet = TRUE) |>
    st_drop_geometry() |>
    distinct(geog_code, .keep_all = TRUE)
}

ons_economic  <- read_ons_lsoa("data/lsoa/ons/economic/ons-economic-ew-2021_6355563.gpkg")
ons_quals     <- read_ons_lsoa("data/lsoa/ons/qualifications/ons-qualifications-ew-2021_6355565.gpkg")
ons_tenure    <- read_ons_lsoa("data/lsoa/ons/tenure/ons-tenure-ew-2021_6355566.gpkg")
ons_cars      <- read_ons_lsoa("data/lsoa/ons/car_availability/ons-car-availability-ew-2021_6355561.gpkg")
ons_hh_comp   <- read_ons_lsoa("data/lsoa/ons/household_composition/ons-hh-comp-ew-2021_6355564.gpkg")

# ── 5. Load ONS SAPE mid-2024 LSOA population estimates ──────────────────────
# Sheet has 3 header rows; col 3 = LSOA 2021 Code, col 5 = Total population.

pop_data <- read_excel(
  "data/lsoa/sapelsoasyoa20222024.xlsx",
  sheet = "Mid-2024 LSOA 2021",
  skip  = 3
) |>
  select(lsoa_code = `LSOA 2021 Code`, pop_total = Total) |>
  filter(!is.na(lsoa_code), !is.na(pop_total)) |>
  mutate(pop_total = as.numeric(pop_total))

message("SAPE 2024 LSOAs loaded: ", nrow(pop_data))

# ── 6. Compute LSOA area and population density ───────────────────────────────

lsoa_area <- ptal |>
  st_drop_geometry() |>
  bind_cols(area_m2 = as.numeric(st_area(ptal))) |>
  select(LSOA21CD, area_m2) |>
  mutate(area_km2 = area_m2 / 1e6)

# ── 7. Join all data to PTAL LSOAs ───────────────────────────────────────────
# Inner-join keeps only London's ~4,994 LSOAs present in all datasets.

london_ons <- ptal |>
  st_drop_geometry() |>
  select(LSOA21CD, mean_AI = mean_AI, ptal_grade = MEAN_PTAL_) |>
  mutate(ptal_grade = factor(ptal_grade, levels = PTAL_LEVELS, ordered = TRUE)) |>
  inner_join(select(ons_economic, geog_code, unemployed_perc),
             by = c("LSOA21CD" = "geog_code")) |>
  inner_join(select(ons_quals,    geog_code, no_qualifications_perc),
             by = c("LSOA21CD" = "geog_code")) |>
  inner_join(select(ons_tenure,   geog_code, rent_social_perc, private_rent_perc),
             by = c("LSOA21CD" = "geog_code")) |>
  inner_join(select(ons_cars,     geog_code, no_car_perc),
             by = c("LSOA21CD" = "geog_code")) |>
  inner_join(
    select(ons_hh_comp, geog_code,
           one_pers_all_perc, fam_lone_all_perc,
           fam_cohab_all_perc, fam_mar_all_perc),
    by = c("LSOA21CD" = "geog_code")
  ) |>
  inner_join(pop_data,   by = c("LSOA21CD" = "lsoa_code")) |>
  inner_join(lsoa_area,  by = "LSOA21CD") |>
  mutate(pop_density_km2 = pop_total / area_km2)

message("London LSOAs in joined dataset: ", nrow(london_ons))

# ── 8. Generate and save visualisations ──────────────────────────────────────

# Vis 1: PTAL choropleth
p1 <- plot_ptal_choropleth(ptal_graded, boroughs, gla, stations)
ggsave("scripts/outputs/vis1-ptal-choropleth.png",
       p1, width = 10, height = 8, dpi = 300, bg = "white")
ggsave("scripts/outputs/vis1-ptal-choropleth.pdf",
       p1, width = 10, height = 8)
message("Saved vis1-ptal-choropleth")

# Vis 2: 3D PTAL map with population height (interactive HTML)
p2 <- plot_ptal_3d(ptal, pop_data, gla)
htmlwidgets::saveWidget(p2, "scripts/outputs/vis2-ptal-3d.html", selfcontained = FALSE)
message("Saved vis2-ptal-3d")

# Vis 3: Mean household composition % by PTAL category
p3 <- plot_ptal_by_hh_comp(london_ons)
ggsave("scripts/outputs/vis3-ptal-by-hh-comp.png",
       p3, width = 10, height = 6, dpi = 300, bg = "white")
ggsave("scripts/outputs/vis3-ptal-by-hh-comp.pdf",
       p3, width = 10, height = 6)
message("Saved vis3-ptal-by-hh-comp")

# Vis 4: Regression table
model <- run_ptal_regression(london_ons)
save_regression_table(model, "scripts/outputs/vis4-regression-table.html")
message("Saved vis4-regression-table")

message("\nAll outputs written to scripts/outputs/")
