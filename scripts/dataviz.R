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

# ── Vis 2: Mean PTAL AI by covariate quartile ─────────────────────────────────
#
# For each covariate, LSOAs are binned into London-relative quartiles.
# Bars show mean PTAL Accessibility Index per quartile; error bars are 95% CI.

COVARIATE_LABELS <- c(
  unemployed_perc         = "Unemployed (%)",
  age_65_plus_perc        = "Age 65+ (%)",
  no_qualifications_perc  = "No qualifications (%)",
  rent_social_perc        = "Social renting (%)",
  private_rent_perc       = "Private renting (%)",
  no_car_perc             = "No car (%)"
)

plot_ptal_by_covariate <- function(df) {
  quartile_labels <- c("Q1\n(lowest)", "Q2", "Q3", "Q4\n(highest)")

  results <- lapply(names(COVARIATE_LABELS), function(var) {
    df |>
      mutate(quartile = factor(ntile(.data[[var]], 4), labels = quartile_labels)) |>
      group_by(quartile) |>
      summarise(
        mean_ptal = mean(mean_AI, na.rm = TRUE),
        se        = sd(mean_AI,   na.rm = TRUE) / sqrt(n()),
        .groups   = "drop"
      ) |>
      mutate(covariate = COVARIATE_LABELS[[var]])
  }) |>
    bind_rows() |>
    mutate(covariate = factor(covariate, levels = unname(COVARIATE_LABELS)))

  ggplot(results, aes(x = quartile, y = mean_ptal)) +
    geom_col(fill = "#6baed6", width = 0.65) +
    geom_errorbar(aes(ymin = mean_ptal - 1.96 * se,
                      ymax = mean_ptal + 1.96 * se),
                  width = 0.2, linewidth = 0.4) +
    facet_wrap(~ covariate, nrow = 2) +
    labs(
      x       = "Quartile of covariate (London LSOAs)",
      y       = "Mean PTAL Accessibility Index",
      caption = paste(
        "Source: TfL Open Data; ONS Census 2021. London LSOAs only (n = 4,994).",
        "Error bars: 95% CI. Quartiles are London-relative."
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

# ── Vis 3: Regression table ───────────────────────────────────────────────────
#
# OLS: mean_AI ~ ONS covariates (standardised). Saved as HTML for inspection;
# the modelsummary() call can be embedded directly in Quarto.

run_ptal_regression <- function(df) {
  df_scaled <- df |>
    mutate(across(all_of(names(COVARIATE_LABELS)), \(x) as.numeric(scale(x))))

  lm(
    mean_AI ~ unemployed_perc + age_65_plus_perc + no_qualifications_perc +
      rent_social_perc + private_rent_perc + no_car_perc,
    data = df_scaled
  )
}

save_regression_table <- function(model, path_html) {
  library(modelsummary)

  coef_map <- c(
    unemployed_perc        = "Unemployed (%)",
    age_65_plus_perc       = "Age 65+ (%)",
    no_qualifications_perc = "No qualifications (%)",
    rent_social_perc       = "Social renting (%)",
    private_rent_perc      = "Private renting (%)",
    no_car_perc            = "No car (%)",
    `(Intercept)`          = "Intercept"
  )

  modelsummary(
    model,
    coef_map   = coef_map,
    stars      = TRUE,
    gof_map    = c("nobs", "r.squared", "adj.r.squared"),
    notes      = paste("OLS. DV: PTAL Accessibility Index (0–100).",
                       "Predictors standardised (mean = 0, SD = 1).",
                       "London LSOAs only. Source: TfL Open Data; ONS Census 2021."),
    output     = path_html
  )
}
