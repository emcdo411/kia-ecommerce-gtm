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

# Prepare regional performance data
regional <- df |> 
  group_by(region, quarter) |>
  summarise(sales = sum(sales), .groups = "drop") |>
  mutate(sales_k = sales / 1000)

# Prepare top movers QoQ data
regional_q <- df |> 
  group_by(region, quarter) |> 
  summarise(sales = sum(sales), .groups = "drop") |>
  group_by(region) |> 
  arrange(quarter, .by_group = TRUE) |>
  mutate(
    qoq = sales - lag(sales),
    qoq_percent = (sales - lag(sales)) / lag(sales) * 100
  ) |>
  filter(!is.na(qoq)) |>
  slice_max(abs(qoq), n = 1) |>
  mutate(
    label = sprintf("%s (%s%%)", dollar(round(qoq / 1000, 1), prefix = "$", suffix = "k"), round(qoq_percent, 1))
  )

# Define a professional theme
theme_boardroom <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, color = "#2E2E2E"),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "#4A4A4A"),
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
color_palette <- c("#1F77B4", "#FF7F0E", "#2CA02C", "#D62728", "#9467BD", "#8C564B")

# Plot 1: Regional Performance
p1 <- ggplot(regional, aes(x = quarter, y = sales_k, group = region, color = region)) +
  geom_line(size = 1.2, alpha = 0.7) +
  geom_point(size = 3) +
  geom_text(
    aes(label = dollar(round(sales_k, 1), prefix = "$", suffix = "k")),
    vjust = -0.8, size = 3.5, color = "#2E2E2E", fontface = "bold"
  ) +
  facet_wrap(~region, scales = "free_y", ncol = 2) +
  labs(
    title = "Regional Sales Performance",
    subtitle = sprintf("Total Sales: %s", dollar(sum(regional$sales), prefix = "$")),
    y = "Sales (k$)",
    x = NULL,
    caption = "Data as of August 2025"
  ) +
  scale_y_continuous(labels = dollar_format(prefix = "$", suffix = "k")) +
  scale_color_manual(values = color_palette) +
  theme_boardroom

# Plot 2: Top Movers QoQ
p2 <- ggplot(regional_q, aes(x = reorder(region, qoq), y = qoq / 1000, color = region)) +
  geom_point(size = 4) +
  geom_text(
    aes(label = label),
    hjust = if_else(regional_q$qoq >= 0, -0.2, 1.2),
    size = 3.5, color = "#2E2E2E", fontface = "bold"
  ) +
  coord_flip() +
  labs(
    title = "Top Quarterly Sales Changes (QoQ)",
    subtitle = "Largest Quarter-over-Quarter Sales Changes by Region",
    x = NULL,
    y = "Δ Sales (k$)"
  ) +
  scale_y_continuous(labels = dollar_format(prefix = "$", suffix = "k")) +
  scale_color_manual(values = color_palette) +
  theme_boardroom

# Combine plots with a unified title
combo <- (p1 / p2) +
  plot_annotation(
    title = "Regional Sales Analysis",
    subtitle = "Quarterly Performance and Top Quarter-over-Quarter Movers",
    theme = theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(b = 5)),
      plot.subtitle = element_text(size = 12, hjust = 0.5, margin = margin(b = 10))
    )
  )

# Save high-resolution combined plot
ggsave(
  file.path(fig_dir, "regional_perf_advanced.png"),
  combo,
  width = 12,
  height = 10,
  dpi = 300,
  bg = "white"
)

# Generate interactive version using plotly
p1_interactive <- ggplotly(p1, tooltip = c("x", "y", "group")) %>%
  layout(
    title = list(
      text = "<b>Regional Sales Performance</b><br><sup>Total Sales: {dollar(sum(regional$sales), prefix = '$')}</sup>",
      x = 0.5,
      xanchor = "center",
      font = list(size = 14)
    ),
    margin = list(t = 100),
    plot_bgcolor = "#F5F6F5",
    paper_bgcolor = "#F5F6F5"
  )

p2_interactive <- ggplotly(p2, tooltip = c("x", "y", "label")) %>%
  layout(
    title = list(
      text = "<b>Top Quarterly Sales Changes (QoQ)</b><br><sup>Largest Quarter-over-Quarter Sales Changes by Region</sup>",
      x = 0.5,
      xanchor = "center",
      font = list(size = 14)
    ),
    margin = list(t = 100),
    plot_bgcolor = "#F5F6F5",
    paper_bgcolor = "#F5F6F5"
  )

# Save interactive HTML files
htmlwidgets::saveWidget(p1_interactive, file.path(fig_dir, "regional_perf_interactive.html"))
htmlwidgets::saveWidget(p2_interactive, file.path(fig_dir, "top_movers_interactive.html"))
