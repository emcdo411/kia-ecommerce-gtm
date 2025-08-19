# Install required packages if not already installed
# install.packages(c("tidyverse", "scales", "patchwork", "plotly", "ggtext"))
library(tidyverse)
library(scales)
library(patchwork)
library(plotly)
library(ggtext)

# Set up directory for saving figures
fig_dir <- "docs/figures"
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

# Read sample data
df <- read_csv("data/sample_program_metrics.csv", show_col_types = FALSE)

# Prepare funnel data
funnel <- df |> 
  group_by(quarter) |>
  summarise(
    find = mean(find_product),
    add = mean(add_to_cart),
    checkout = mean(begin_checkout),
    convert = mean(conversion_rate)
  ) |>
  pivot_longer(cols = c(find, add, checkout, convert), names_to = "stage", values_to = "value") |>
  mutate(
    stage = factor(stage, levels = c("find", "add", "checkout", "convert"), 
                   labels = c("Find Product", "Add to Cart", "Begin Checkout", "Conversion Rate")),
    is_rate = stage == "Conversion Rate"
  )

# Define a professional theme
theme_boardroom <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5, color = "#2E2E2E"),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "#4A4A4A"),
    plot.caption = element_text(size = 10, hjust = 1, color = "#4A4A4A"),
    axis.title = element_text(face = "bold", size = 10, color = "#2E2E2E"),
    axis.text = element_text(size = 9, color = "#4A4A4A"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    strip.text = element_text(face = "bold", size = 10, color = "#2E2E2E"),
    panel.grid.major = element_line(color = "#E0E0E0", size = 0.3),
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "#F5F6F5", color = NA),
    panel.background = element_rect(fill = "#FFFFFF", color = NA),
    legend.position = "top",
    legend.title = element_blank(),
    legend.text = element_text(size = 10, color = "#4A4A4A")
  )

# Define a professional color palette
color_palette <- c("#1F77B4", "#FF7F0E", "#2CA02C", "#D62728")

# Create the faceted funnel plot
p <- ggplot(funnel, aes(x = stage, y = value, group = quarter, color = quarter)) +
  geom_line(size = 1.2, alpha = 0.7) +
  geom_point(size = 3) +
  geom_text(
    aes(label = if_else(is_rate, percent(value, accuracy = 0.1), comma(round(value, 0)))),
    vjust = -0.8, size = 3.5, color = "#2E2E2E", fontface = "bold"
  ) +
  facet_wrap(~quarter, ncol = 2, scales = "free_y") +
  labs(
    title = "Conversion Funnel by Quarter",
    subtitle = "Tracking Average Values Across Find Product, Add to Cart, Begin Checkout, and Conversion Rate",
    x = NULL,
    y = "Average Value",
    caption = "Data as of August 2025"
  ) +
  scale_y_continuous(
    labels = function(x) if_else(funnel$is_rate, percent(x, accuracy = 0.1), comma(x)),
    breaks = pretty_breaks()
  ) +
  scale_color_manual(values = color_palette) +
  theme_boardroom

# Save high-resolution static plot
ggsave(
  file.path(fig_dir, "conversion_funnel_advanced.png"),
  p,
  width = 12,
  height = 8,
  dpi = 300,
  bg = "white"
)

# Generate interactive version using plotly
p_interactive <- ggplotly(p, tooltip = c("x", "y", "group")) %>%
  layout(
    title = list(
      text = "<b>Conversion Funnel by Quarter</b><br><sup>Tracking Average Values Across Find Product, Add to Cart, Begin Checkout, and Conversion Rate</sup>",
      x = 0.5,
      xanchor = "center",
      font = list(size = 16)
    ),
    margin = list(t = 100),
    plot_bgcolor = "#F5F6F5",
    paper_bgcolor = "#F5F6F5"
  )

# Save interactive HTML
htmlwidgets::saveWidget(p_interactive, file.path(fig_dir, "conversion_funnel_interactive.html"))
