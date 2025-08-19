# install.packages(c("tidyverse","scales","patchwork","gt"))
library(tidyverse)
library(scales)
library(patchwork)
library(gt)

fig_dir <- "docs/figures"
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

# 03_conversion_funnel.R
df <- read_csv("data/sample_program_metrics.csv", show_col_types = FALSE)

funnel <- df |> 
  group_by(quarter) |>
  summarise(
    find = mean(find_product),
    add = mean(add_to_cart),
    checkout = mean(begin_checkout),
    convert = mean(conversion_rate)
  ) |>
  pivot_longer(cols = c(find, add, checkout, convert), names_to = "stage", values_to = "value")

p <- ggplot(funnel, aes(x = stage, y = value, group = quarter)) +
  geom_line(alpha = 0.4) + geom_point() +
  labs(title = "Conversion Funnel (sample)", x = "Stage", y = "Avg Value")

ggsave(file.path(fig_dir, "conversion_funnel.png"), p, width = 8, height = 5, dpi = 150)
