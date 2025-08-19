# install.packages(c("tidyverse","scales","patchwork","gt"))
library(tidyverse)
library(scales)
library(patchwork)
library(gt)

fig_dir <- "docs/figures"
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

# 04_regional_perf.R
df <- read_csv("data/sample_program_metrics.csv", show_col_types = FALSE)

regional <- df |> group_by(region, quarter) |>
  summarise(sales = sum(sales), .groups = "drop")

p <- ggplot(regional, aes(x = quarter, y = sales/1000, group = region)) +
  geom_line() + geom_point() +
  facet_wrap(~ region, scales = "free_y") +
  labs(title = "Regional Performance (k$)", y = "k$", x = "")

ggsave(file.path(fig_dir, "regional_perf.png"), p, width = 10, height = 6, dpi = 150)

# Top movers QoQ (sample)
regional_q <- df |> group_by(region, quarter) |> summarise(sales = sum(sales), .groups = "drop")
regional_q <- regional_q |> group_by(region) |> arrange(quarter, .by_group = TRUE) |>
  mutate(qoq = sales - lag(sales)) |>
  filter(!is.na(qoq)) |>
  slice_max(abs(qoq), n = 1)

p2 <- ggplot(regional_q, aes(x = reorder(region, qoq), y = qoq)) +
  geom_point(size = 3) +
  coord_flip() +
  labs(title = "Top Movers QoQ (sample)", x = "", y = "Δ Sales")

ggsave(file.path(fig_dir, "top_movers.png"), p2, width = 8, height = 5, dpi = 150)
