# Install required packages if not already installed
# install.packages(c("tidyverse", "scales", "patchwork", "gt", "plotly", "ggtext"))
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

# Aggregate KPIs by quarter
kpi <- df |> 
  group_by(quarter) |> 
  summarise(
    add_to_cart = mean(add_to_cart),
    begin_checkout = mean(begin_checkout),
    conversion_rate = mean(conversion_rate),
    sales = sum(sales)
  )

# Define a professional theme
theme_boardroom <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, color = "#2E2E2E"),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "#4A4A4A"),
    axis.title = element_text(face = "bold", size = 10, color = "#2E2E2E"),
    axis.text = element_text(size = 9, color = "#4A4A4A"),
    panel.grid.major = element_line(color = "#E0E0E0", size = 0.3),
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "#F5F6F5", color = NA),
    panel.background = element_rect(fill = "#FFFFFF", color = NA),
    legend.position = "none"
  )

# Helper function to add annotations
add_annotations <- function(data, x, y, label) {
  geom_text(
    data = data,
    aes_string(x = x, y = y, label = label),
    vjust = -0.5, size = 3, color = "#2E2E2E",
    fontface = "bold"
  )
}

# Plot 1: Add to Cart
p1 <- ggplot(kpi, aes(x = quarter, y = add_to_cart, group = 1)) +
  geom_line(color = "#1F77B4", size = 1.2) +
  geom_point(color = "#1F77B4", size = 3) +
  add_annotations(kpi, "quarter", "add_to_cart", "round(add_to_cart, 0)") +
  labs(title = "Add to Cart", y = "Count", x = NULL) +
  scale_y_continuous(labels = comma) +
  theme_boardroom

# Plot 2: Begin Checkout
p2 <- ggplot(kpi, aes(x = quarter, y = begin_checkout, group = 1)) +
  geom_line(color = "#FF7F0E", size = 1.2) +
  geom_point(color = "#FF7F0E", size = 3) +
  add_annotations(kpi, "quarter", "begin_checkout", "round(begin_checkout, 0)") +
  labs(title = "Begin Checkout", y = "Count", x = NULL) +
  scale_y_continuous(labels = comma) +
  theme_boardroom

# Plot 3: Conversion Rate
p3 <- ggplot(kpi, aes(x = quarter, y = conversion_rate, group = 1)) +
  geom_line(color = "#2CA02C", size = 1.2) +
  geom_point(color = "#2CA02C", size = 3) +
  add_annotations(kpi, "quarter", "conversion_rate", "percent(conversion_rate, accuracy = 0.1)") +
  labs(title = "Conversion Rate", y = "Rate", x = NULL) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  theme_boardroom

# Plot 4: Total Sales
p4 <- ggplot(kpi, aes(x = quarter, y = sales / 1000, group = 1)) +
  geom_line(color = "#D62728", size = 1.2) +
  geom_point(color = "#D62728", size = 3) +
  add_annotations(kpi, "quarter", "sales / 1000", "dollar(round(sales / 1000, 1))") +
  labs(title = "Total Sales", y = "k$", x = NULL) +
  scale_y_continuous(labels = dollar_format(prefix = "$", suffix = "k")) +
  theme_boardroom

# Combine plots with a title and subtitle
combo <- (p1 | p2) / (p3 | p4) +
  plot_annotation(
    title = "Quarterly KPI Performance Overview",
    subtitle = "Tracking Add to Cart, Begin Checkout, Conversion Rate, and Total Sales",
    theme = theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(b = 5)),
      plot.subtitle = element_text(size = 12, hjust = 0.5, margin = margin(b = 10))
    )
  )

# Save high-resolution plot
ggsave(
  file.path(fig_dir, "kpi_snapshot_advanced.png"),
  combo,
  width = 12,
  height = 8,
  dpi = 300,
  bg = "white"
)

# Optional: Generate interactive version using plotly
p_interactive <- ggplotly(combo, tooltip = c("x", "y")) %>%
  layout(
    title = list(
      text = "<b>Quarterly KPI Performance Overview</b><br><sup>Tracking Add to Cart, Begin Checkout, Conversion Rate, and Total Sales</sup>",
      x = 0.5,
      xanchor = "center",
      font = list(size = 16)
    ),
    margin = list(t = 100)
  )

# Save interactive HTML
htmlwidgets::saveWidget(p_interactive, file.path(fig_dir, "kpi_snapshot_interactive.html"))
