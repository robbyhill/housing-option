# dataviz.R
#
# Plotting functions for the housing-option paper.
# Sourced by main.R — do not run directly.

library(ggplot2)
library(dplyr)
library(tidyr)

# ── Shared constants ──────────────────────────────────────────────────────────

PTAL_LEVELS  <- c("0", "1a", "1b", "2", "3", "4", "5", "6a", "6b")
PTAL_COLOURS <- c(
  "0"  = "#2166ac", "1a" = "#4393c3", "1b" = "#92c5de",
  "2"  = "#d1e5f0", "3"  = "#f7f7f7", "4"  = "#fddbc7",
  "5"  = "#f4a582", "6a" = "#d6604d", "6b" = "#b2182b"
)

# ── Vis 1: PTAL choropleth ────────────────────────────────────────────────────

plot_ptal_choropleth <- function(ptal_graded, boroughs, gla, stations) {
  stations_other <- filter(stations, station_type == "Other TfL station")
  stations_tube  <- filter(stations, station_type == "Underground station")

  ggplot() +
    geom_sf(data = ptal_graded, aes(fill = ptal_grade), colour = NA) +
    geom_sf(data = boroughs, fill = NA, colour = "black", linewidth = 0.25) +
    geom_sf(data = gla, fill = NA, colour = "#1a1a1a", linewidth = 0.7) +
    geom_sf(data = stations_other, aes(shape = station_type),
            colour = "black", size = 1.4, stroke = 0.5) +
    geom_sf(data = stations_tube, aes(shape = station_type),
            colour = "black", size = 1.4, stroke = 0.5) +
    scale_fill_manual(values = PTAL_COLOURS, name = "PTAL",
                      na.value = "grey80", drop = FALSE) +
    scale_shape_manual(name   = "Stations",
                       values = c("Underground station" = 16, "Other TfL station" = 1)) +
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
}

# ── Vis 2: 3D PTAL map with population height ─────────────────────────────────
#
# Rasterises PTAL AI (colour) and LSOA population (z-height) to a 200m grid,
# then renders an interactive plotly 3D surface. Saved as self-contained HTML.
# Borough/LSOA borders and TfL stations are omitted (too noisy in 3D).

plot_ptal_3d <- function(ptal, pop_data, gla) {
  library(terra)
  library(plotly)
  library(sf)

  # Join population to PTAL geometry
  ptal_pop <- ptal |>
    left_join(pop_data, by = c("LSOA21CD" = "lsoa_code")) |>
    filter(!is.na(pop_total))

  # Rasterise to 200 m grid clipped to GLA
  ptal_v <- terra::vect(sf::st_transform(ptal_pop, 27700))
  gla_v  <- terra::vect(sf::st_transform(gla,      27700))

  r_template <- terra::rast(terra::ext(gla_v), resolution = 200, crs = "EPSG:27700")
  r_pop  <- terra::rasterize(ptal_v, r_template, field = "pop_total", fun = "sum")
  r_ptal <- terra::rasterize(ptal_v, r_template, field = "mean_AI",   fun = "mean")

  gla_mask <- terra::rasterize(gla_v, r_template, background = NA)
  r_pop    <- terra::mask(r_pop,  gla_mask)
  r_ptal   <- terra::mask(r_ptal, gla_mask)

  pop_mat  <- as.matrix(r_pop,  wide = TRUE)
  ptal_mat <- as.matrix(r_ptal, wide = TRUE)

  pop_mat[is.na(pop_mat)] <- 0   # outside GLA → zero height

  # Rasterise PTAL band as integer 1–9 (for discrete coloring)
  band_to_int <- setNames(seq_along(PTAL_LEVELS), PTAL_LEVELS)
  ptal_pop    <- ptal_pop |>
    mutate(ptal_band_int = band_to_int[as.character(MEAN_PTAL_)])
  ptal_v2      <- terra::vect(sf::st_transform(ptal_pop, 27700))
  r_band        <- terra::rasterize(ptal_v2, r_template, field = "ptal_band_int", fun = "min")
  r_band        <- terra::mask(r_band, gla_mask)
  band_mat      <- as.matrix(r_band, wide = TRUE)

  # Stepped discrete colorscale: each of 9 PTAL bands gets equal 1/9 segment
  n      <- length(PTAL_LEVELS)
  cols   <- unname(PTAL_COLOURS)
  steps  <- unlist(lapply(seq_along(cols), function(i) {
    list(list((i - 1) / n, cols[i]), list(i / n, cols[i]))
  }), recursive = FALSE)

  # Colorbar tick labels: one per band, positioned at band midpoint
  tick_vals <- (seq_along(PTAL_LEVELS) - 0.5) / n * n  # 0.5, 1.5, … 8.5
  tick_text <- PTAL_LEVELS

  plot_ly(
    z            = pop_mat,
    surfacecolor = band_mat,
    type         = "surface",
    colorscale   = steps,
    cmin         = 1,
    cmax         = n,
    colorbar     = list(
      title      = list(text = "PTAL", font = list(size = 11)),
      tickvals   = tick_vals,
      ticktext   = tick_text,
      tickmode   = "array"
    ),
    showscale    = TRUE,
    hovertemplate = paste0(
      "Population: %{z:.0f}<extra></extra>"
    )
  ) |>
    layout(
      scene = list(
        xaxis = list(showticklabels = FALSE, title = "", showgrid = FALSE),
        yaxis = list(showticklabels = FALSE, title = "", showgrid = FALSE),
        zaxis = list(title = "Population", showgrid = TRUE),
        camera = list(eye = list(x = 1.4, y = -1.4, z = 0.9)),
        aspectmode = "manual",
        aspectratio = list(x = 1.25, y = 1, z = 0.4)
      ),
      paper_bgcolor = "white",
      margin = list(l = 0, r = 0, t = 0, b = 30),
      annotations = list(list(
        text      = "Source: TfL Open Data; ONS SAPE mid-2024. 200 m grid.",
        showarrow = FALSE,
        x = 0, y = 0, xref = "paper", yref = "paper",
        xanchor = "left", font = list(size = 9, color = "grey50")
      ))
    )
}

# ── Vis 3: Mean PTAL Access Index by covariate quartile (household composition)
#
# For each household-composition variable, LSOAs are binned into London-relative
# quartiles. Bars show mean PTAL Accessibility Index per quartile (95% CI).
# Caption includes the Access Index → PTAL band mapping for reference.

HH_COMP_LABELS <- c(
  one_pers_all_perc  = "One-person households (%)",
  fam_lone_all_perc  = "Lone-parent families (%)",
  fam_cohab_all_perc = "Cohabiting families (%)",
  fam_mar_all_perc   = "Married/CP families (%)"
)

AI_PTAL_NOTE <- paste(
  "PTAL bands (Access Index): 0 (=0), 1a (0.01-2.50), 1b (2.51-5.0),",
  "2 (5.01-10.0), 3 (10.01-15.0), 4 (15.01-20.0),",
  "5 (20.01-25.0), 6a (25.01-40.0), 6b (40.01+)."
)

plot_ptal_by_hh_comp <- function(df) {
  quartile_labels <- c("Q1\n(lowest)", "Q2", "Q3", "Q4\n(highest)")

  results <- lapply(names(HH_COMP_LABELS), function(var) {
    df |>
      mutate(quartile = factor(ntile(.data[[var]], 4), labels = quartile_labels)) |>
      group_by(quartile) |>
      summarise(
        mean_ai = mean(mean_AI, na.rm = TRUE),
        se      = sd(mean_AI,   na.rm = TRUE) / sqrt(n()),
        .groups = "drop"
      ) |>
      mutate(covariate = HH_COMP_LABELS[[var]])
  }) |>
    bind_rows() |>
    mutate(covariate = factor(covariate, levels = unname(HH_COMP_LABELS)))

  ggplot(results, aes(x = quartile, y = mean_ai)) +
    geom_col(fill = "#6baed6", width = 0.65) +
    geom_errorbar(aes(ymin = mean_ai - 1.96 * se,
                      ymax = mean_ai + 1.96 * se),
                  width = 0.2, linewidth = 0.4) +
    facet_wrap(~ covariate, nrow = 2) +
    labs(
      x       = "Quartile of covariate (London LSOAs)",
      y       = "Mean PTAL Access Index",
      caption = paste(
        "Source: TfL Open Data; ONS Census 2021 (household composition).",
        "London LSOAs only (n ~4,994). Error bars: 95% CI. Quartiles are London-relative.",
        AI_PTAL_NOTE
      )
    ) +
    theme_minimal(base_size = 10) +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      strip.text         = element_text(face = "bold", size = 9),
      axis.text.x        = element_text(size = 8),
      plot.caption       = element_text(size = 7, colour = "grey50", hjust = 0,
                                        margin = margin(t = 6))
    )
}

# ── Vis 4: Regression table (OLS) ────────────────────────────────────────────
#
# OLS: mean_AI (continuous, 0–100+) ~ standardised ONS covariates + pop density.
# Predictors standardised (mean=0, SD=1) so coefficients are directly comparable.
# β = change in Access Index per one-SD increase in predictor.

PRED_VARS <- c(
  "unemployed_perc", "no_qualifications_perc",
  "rent_social_perc", "private_rent_perc", "no_car_perc",
  "one_pers_all_perc", "fam_lone_all_perc",
  "fam_cohab_all_perc", "fam_mar_all_perc",
  "pop_density_km2"
)

run_ptal_regression <- function(df) {
  df_scaled <- df |>
    mutate(across(all_of(PRED_VARS), \(x) as.numeric(scale(x))))

  lm(
    mean_AI ~ unemployed_perc + no_qualifications_perc +
      rent_social_perc + private_rent_perc + no_car_perc +
      one_pers_all_perc + fam_lone_all_perc +
      fam_cohab_all_perc + fam_mar_all_perc +
      pop_density_km2,
    data = df_scaled
  )
}

# ── Vis 5: Brownfield sites map ───────────────────────────────────────────────
#
# Shades brownfield site polygons brown over a grey borough base, with TfL
# stations and GLA boundary. Scale bar and north arrow included per design spec.

plot_brownfield_map <- function(brownfield_poly, boroughs, gla, stations) {
  library(ggspatial)

  stations_other <- filter(stations, station_type == "Other TfL station")
  stations_tube  <- filter(stations, station_type == "Underground station")

  ggplot() +
    geom_sf(data = boroughs, fill = "grey96", colour = "black", linewidth = 0.25) +
    geom_sf(data = brownfield_poly, fill = "#8B4513", colour = NA, alpha = 0.75) +
    geom_sf(data = gla, fill = NA, colour = "#1a1a1a", linewidth = 0.7) +
    geom_sf(data = stations_other, aes(shape = station_type),
            colour = "black", size = 1.0, stroke = 0.5) +
    geom_sf(data = stations_tube, aes(shape = station_type),
            colour = "black", size = 1.0, stroke = 0.5) +
    scale_shape_manual(name   = "Stations",
                       values = c("Underground station" = 16, "Other TfL station" = 1)) +
    guides(shape = guide_legend(override.aes = list(size = 3, colour = "black"))) +
    annotation_scale(location = "bl", width_hint = 0.2, style = "ticks") +
    annotation_north_arrow(location = "tr", which_north = "true",
                           style = north_arrow_minimal()) +
    labs(caption = "Source: GLA London Brownfield Land Register; TfL Open Data; GLA London Datastore.") +
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
}

# ── Vis 6: Brownfield site area vs distance to nearest TfL station ────────────
#
# Scatterplot of log(hectares) vs distance to nearest TfL station (any mode).
# Point locations: geox/geoy from register where available; polygon centroid
# otherwise (applies almost exclusively to the London Borough of Brent, which
# did not provide coordinates in its submission). Distance pre-computed in main.R.

plot_brownfield_distance <- function(brownfield_pts) {
  plot_df <- brownfield_pts |>
    st_drop_geometry() |>
    filter(!is.na(gis_ha), gis_ha > 0.01, !is.na(dist_m))

  ggplot(plot_df, aes(x = log(gis_ha), y = dist_m)) +
    geom_hline(yintercept = 800, linetype = "dashed", colour = "grey40",
               linewidth = 0.5) +
    geom_point(alpha = 0.35, size = 1.2, colour = "#8B4513") +
    geom_smooth(method = "lm", colour = "black", linewidth = 0.7,
                se = TRUE, fill = "grey80") +
    annotate("text", x = max(log(plot_df$gis_ha)) * 0.95, y = 750,
             label = "800m walkability threshold (DfT)", hjust = 1,
             size = 3, colour = "grey40") +
    labs(
      x = "Log site area (hectares)",
      y = "Distance to nearest TfL station (m)"
    ) +
    theme_minimal(base_size = 10) +
    theme(
      panel.grid.minor = element_blank()
    )
}

# ── Vis 7: MBTA Communities map ──────────────────────────────────────────────
#
# Choropleth of Massachusetts municipalities by MBTA community category, with
# upzoned MBTA area slices overlaid in orange, rapid transit nodes, and
# commuter rail stations. Municipal boundaries from the tigris package.

MBTA_CAT_COLOURS <- c(
  "Rapid Transit"       = "#2166ac",
  "Commuter Rail"       = "#92c5de",
  "Adjacent community"  = "#d1e5f0",
  "Adjacent small town" = "#f7f7f7"
)

plot_mbta_communities <- function(mbta_slices, mbta_csv, commuter_rail) {
  library(tigris)
  library(ggspatial)

  options(tigris_use_cache = TRUE)

  # MA municipal boundaries (county subdivisions = towns/cities in New England)
  ma_towns <- county_subdivisions("MA", cb = TRUE, progress_bar = FALSE) |>
    st_transform(4326)

  # Join community category from CSV; filter to MBTA communities only.
  # Normalise names: strip " Town"/" City" suffixes from tigris names;
  # map "Manchester-by-the-Sea" → "Manchester" to match CSV spelling.
  mbta_csv_clean <- mbta_csv |>
    mutate(community_upper = toupper(trimws(Community)))

  ma_towns_joined <- ma_towns |>
    mutate(
      name_norm = toupper(trimws(NAME)),
      name_norm = sub(" TOWN$| CITY$", "", name_norm),
      name_norm = sub("^MANCHESTER-BY-THE-SEA$", "MANCHESTER", name_norm)
    ) |>
    inner_join(
      select(mbta_csv_clean, community_upper,
             community_category = `Community category`,
             capacity_pct       = `Unit capacity % of Total Housing units`),
      by = c("name_norm" = "community_upper")
    ) |>
    mutate(community_category = factor(community_category,
                                       levels = names(MBTA_CAT_COLOURS)))

  # Compute bounding box from matched municipalities
  bbox <- st_bbox(ma_towns_joined)

  # Commuter rail: MA only, clipped to matched MBTA municipalities so that
  # stations in Boston proper (not in the communities dataset) don't float
  # over the harbour with no municipality fill beneath them.
  cr <- commuter_rail |>
    filter(STATE == "MA") |>
    st_transform(4326) |>
    st_filter(ma_towns_joined)

  # Dissolve slices to one polygon per jurisdiction for visibility.
  # st_make_valid() guards against any invalid geometries before union.
  mbta_dissolved <- mbta_slices |>
    st_make_valid() |>
    group_by(jurisdiction) |>
    summarise(.groups = "drop")

  ggplot() +
    # Municipality fill by community category
    geom_sf(data = ma_towns_joined,
            aes(fill = community_category),
            colour = "grey40", linewidth = 0.2) +
    # Commuter rail stations (filled dot)
    geom_sf(data = cr,
            aes(shape = "Commuter rail station"),
            size = 1.8, colour = "black", stroke = 0.5) +
    # Dissolved upzoned zone outlines — drawn last so visible over dots
    geom_sf(data = mbta_dissolved,
            fill = NA, colour = "#e6550d", linewidth = 0.5) +
    scale_fill_manual(
      values   = MBTA_CAT_COLOURS,
      name     = "MBTA community\ncategory",
      na.value = "grey90",
      drop     = FALSE
    ) +
    scale_shape_manual(
      name   = "Stations",
      values = c("Commuter rail station" = 16)
    ) +
    guides(
      fill  = guide_legend(order = 1,
                           override.aes = list(colour = "grey40", linewidth = 0.3)),
      shape = guide_legend(order = 2,
                           override.aes = list(size = 3, colour = "black"))
    ) +
    annotation_scale(location = "bl", width_hint = 0.2, style = "ticks") +
    annotation_north_arrow(location = "tr", which_north = "true",
                           style = north_arrow_orienteering(fill = c("black", "white"),
                                                            line_col = "black",
                                                            text_col = "black")) +
    coord_sf(xlim = c(bbox["xmin"] - 0.05, bbox["xmax"] + 0.05),
             ylim = c(bbox["ymin"] - 0.05, bbox["ymax"] + 0.05)) +
    theme_void() +
    theme(
      legend.title      = element_text(size = 9, face = "bold"),
      legend.text       = element_text(size = 8),
      legend.key.height = unit(14, "pt"),
      legend.key.width  = unit(14, "pt"),
      plot.margin       = margin(12, 12, 12, 12)
    )
}

save_regression_table <- function(model, path_html) {
  library(modelsummary)

  coef_map <- c(
    unemployed_perc        = "Unemployed (%)",
    no_qualifications_perc = "No qualifications (%)",
    rent_social_perc       = "Social renting (%)",
    private_rent_perc      = "Private renting (%)",
    no_car_perc            = "No car (%)",
    one_pers_all_perc      = "One-person households (%)",
    fam_lone_all_perc      = "Lone-parent families (%)",
    fam_cohab_all_perc     = "Cohabiting families (%)",
    fam_mar_all_perc       = "Married/CP families (%)",
    pop_density_km2        = "Population density (per km2)",
    `(Intercept)`          = "Intercept"
  )

  notes <- paste(
    "OLS. Outcome: PTAL Access Index (AI), a continuous measure of public transport",
    "accessibility ranging from 0 to ~100; higher values indicate better access.",
    "AI maps to PTAL bands as follows: 0 (AI=0), 1a (0.01-2.50), 1b (2.51-5.0),",
    "2 (5.01-10.0), 3 (10.01-15.0), 4 (15.01-20.0), 5 (20.01-25.0),",
    "6a (25.01-40.0), 6b (40.01+).",
    "All predictors are standardised (mean=0, SD=1);",
    "beta represents the change in AI associated with a one-SD increase in each predictor.",
    "Results are robust to ordered logistic regression on PTAL bands.",
    "London LSOAs only (n=4,994). Source: TfL Open Data; ONS Census 2021; ONS SAPE mid-2024."
  )

  modelsummary(
    model,
    coef_map   = coef_map,
    stars      = TRUE,
    gof_map    = c("nobs", "r.squared", "adj.r.squared"),
    notes      = notes,
    output     = path_html
  )
}
