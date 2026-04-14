# ptal-choropleth.R
#
# Choropleth map of Public Transport Accessibility Level (PTAL) at LSOA level
# across London, overlaid with borough and GLA outer boundaries, and all TfL
# station locations (Underground, DLR, Elizabeth line, Overground, Tramlink).
#
# Design: no title in plot — add title/caption in the Quarto document.
# Run from the project root (housing/).
# Output saved to scripts/outputs/.

library(sf)
library(ggplot2)
library(dplyr)

# ── Paths (relative to project root) ─────────────────────────────────────────

ptal_path       <- "data/LSOA_aggregated_PTAL_stats_2023.geojson"
gla_path        <- "data/gla/London_GLA_Boundary.shp"
boroughs_path   <- "data/statistical-gis-boundaries-london/ESRI/London_Borough_Excluding_MHW.shp"
stations_folder <- "data/tfl_stations"

# ── Load data ─────────────────────────────────────────────────────────────────

ptal     <- st_read(ptal_path,     quiet = TRUE)
gla      <- st_read(gla_path,      quiet = TRUE)
boroughs <- st_read(boroughs_path, quiet = TRUE)

# Load all TfL station files and combine. Schemas differ across modes (not all
# have LINES/MODES/ATCOCODE), so select only the common columns before binding.
station_files <- list.files(stations_folder, pattern = "[.]geojson$", full.names = TRUE)

stations <- lapply(station_files, function(f) {
  s <- st_read(f, quiet = TRUE)
  s |> select(NAME, NETWORK, FULL_NAME)
}) |>
  bind_rows()

# ── Align CRS → British National Grid (EPSG:27700) ───────────────────────────

ptal     <- st_transform(ptal,     27700)
gla      <- st_transform(gla,      27700)
boroughs <- st_transform(boroughs, 27700)
stations <- st_transform(stations, 27700)

# ── Clip stations to Greater London boundary ──────────────────────────────────
# Removes stations outside the GLA boundary (e.g. Watford, Chesham, Amersham
# on the Underground; some Elizabeth line stops beyond Greater London).

stations <- st_filter(stations, gla)

# ── Classify station type ─────────────────────────────────────────────────────
# Underground → filled dot; all other TfL modes → open dot.

stations <- stations |>
  mutate(station_type = if_else(
    NETWORK == "London Underground",
    "Underground station",
    "Other TfL station"
  ))

# ── PTAL grade as ordered factor ──────────────────────────────────────────────
# Levels: 0 (worst) → 6b (best), preserving 1a/1b and 6a/6b subdivisions

ptal_levels <- c("0", "1a", "1b", "2", "3", "4", "5", "6a", "6b")

ptal <- ptal |>
  mutate(ptal_grade = factor(MEAN_PTAL_, levels = ptal_levels, ordered = TRUE))

# ── Colour palette: cool (blue) → hot (red) ───────────────────────────────────
# 9-colour diverging RdBu palette reversed (blue = poor access, red = excellent)

ptal_colours <- c(
  "0"  = "#2166ac",
  "1a" = "#4393c3",
  "1b" = "#92c5de",
  "2"  = "#d1e5f0",
  "3"  = "#f7f7f7",
  "4"  = "#fddbc7",
  "5"  = "#f4a582",
  "6a" = "#d6604d",
  "6b" = "#b2182b"
)

# ── Plot ──────────────────────────────────────────────────────────────────────

# Draw other TfL stations first (below Underground) so Tube dots are on top
# where stops of different types share a location.
stations_other <- filter(stations, station_type == "Other TfL station")
stations_tube  <- filter(stations, station_type == "Underground station")

p <- ggplot() +
  # LSOA fill — no borders at this resolution (too dense)
  geom_sf(data = ptal, aes(fill = ptal_grade), colour = NA) +
  # Borough boundaries in black to show within-borough variation
  geom_sf(data = boroughs, fill = NA, colour = "black", linewidth = 0.25) +
  # Outer GLA boundary, slightly thicker to frame the map
  geom_sf(data = gla, fill = NA, colour = "#1a1a1a", linewidth = 0.7) +
  # Other TfL stops first (open dots, drawn beneath Underground)
  geom_sf(data = stations_other,
          aes(shape = station_type),
          colour = "black", size = 1.4, stroke = 0.5) +
  # Underground stations on top (filled dots)
  geom_sf(data = stations_tube,
          aes(shape = station_type),
          colour = "black", size = 1.4, stroke = 0.5) +
  scale_fill_manual(
    values   = ptal_colours,
    name     = "PTAL",
    na.value = "grey80",
    drop     = FALSE
  ) +
  scale_shape_manual(
    name   = "Stations",
    values = c("Underground station" = 16, "Other TfL station" = 1)
  ) +
  guides(
    fill  = guide_legend(order = 1, override.aes = list(colour = NA)),
    shape = guide_legend(order = 2, override.aes = list(size = 3, colour = "black"))
  ) +
  labs(caption = "Source: TfL Open Data. Borough and GLA boundaries: GLA London Datastore.") +
  theme_void() +
  theme(
    plot.caption      = element_text(size = 7, colour = "grey50", hjust = 0,
                                     margin = margin(t = 8)),
    legend.title      = element_text(size = 9, face = "bold"),
    legend.text       = element_text(size = 8),
    legend.key.height = unit(14, "pt"),
    legend.key.width  = unit(14, "pt"),
    plot.margin       = margin(12, 12, 12, 12)
  )

# ── Save ──────────────────────────────────────────────────────────────────────

dir.create("scripts/outputs", showWarnings = FALSE, recursive = TRUE)

ggsave("scripts/outputs/ptal-choropleth.png",
       p, width = 10, height = 8, dpi = 300, bg = "white")

ggsave("scripts/outputs/ptal-choropleth.pdf",
       p, width = 10, height = 8)

message("Saved to scripts/outputs/ptal-choropleth.{png,pdf}")
