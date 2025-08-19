# Install required packages if not already installed
# install.packages(c("tidyverse", "scales", "patchwork", "plotly", "ggtext"))
library(tidyverse)
library(scales)
library(plotly)
library(ggtext)

# Set up directory for saving figures
fig_dir <- "docs/figures"
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

# Read sample data
mix <- read_csv("data/sample_enrollment_by_package.csv", show_col_types = FALSE)

# Calculate total dealers and percentages
mix <- mix |> 
  mutate(
    percentage = dealers / sum(dealers) * 100,
    label = sprintf("%d (%s%%)", dealers, round(percentage, 1))
  )

# Define a professional theme
theme_boardroom <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5, color = "#2E2E2E"),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "#4A4A4A"),
    plot.caption = element_text(size = 10, hjust = 1, color = "#4A4A4A"),
    axis.title = element_text(face = "bold", size = 10, color = "#2E2E2E"),
    axis.text = element_text(size = 9, color = "#4A4A4A"),
    axis.text.x = element_text(angle = 0, vjust = 0.5),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "#E0E0E0", size = 0.3),
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "#F5F6F5", color = NA),
    panel.background = element_rect(fill = "#FFFFFF", color = NA),
    legend.position = "none"
  )

# Define a professional color palette
color_palette <- c("#1F77B4", "#FF7F0E", "#2CA02C", "#D62728", "#9467BD")

# Create the bar plot
p <- ggplot(mix, aes(x = package_tier, y = dealers, fill = package_tier)) +
  geom_col() +
  geom_text(
    aes(label = label),
    vjust = -0.5,
    size = 3.5,
    color = "#2E2E2E",
    fontface = "bold"
  ) +
  labs(
    title = "Dealer Enrollment by Package Tier",
    subtitle = sprintf("Total Dealers: %s", comma(sum(mix$dealers))),
    y = "Number of Dealers",
    x = NULL,
    caption = "Data as of August 2025"
  ) +
  scale_y_continuous(labels = comma) +
  scale_fill_manual(values = color_palette) +
  theme_boardroom

# Save high-resolution static plot
ggsave(
  file.path(fig_dir, "package_mix_advanced.png"),
  p,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

# Generate interactive version using plotly
p_interactive <- ggplotly(p, tooltip = c("x", "y", "label")) %>%
  layout(
    title = list(
      text = "<b>Dealer Enrollment by Package Tier</b><br><sup>Total Dealers: {comma(sum(mix$dealers))}</sup>",
      x = 0.5,
      xanchor = "center",
      font = list(size = 16)
    ),
    margin = list(t = 100),
    plot_bgcolor = "#F5F6F5",
    paper_bgcolor = "#F5F6F5"
  )

# Save interactive HTML
htmlwidgets::saveWidget(p_interactive, file.path(fig_dir, "package_mix_interactive.html"))
