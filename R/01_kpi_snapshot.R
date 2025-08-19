# install.packages(c("tidyverse","scales","patchwork","gt"))
library(tidyverse)
library(scales)
library(patchwork)
library(gt)

fig_dir <- "docs/figures"
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

# 01_kpi_snapshot.R
df <- read_csv("data/sample_program_metrics.csv", show_col_types = FALSE)

kpi <- df |> group_by(quarter) |> 
  summarise(
    add_to_cart = mean(add_to_cart),
    begin_checkout = mean(begin_checkout),
    conversion_rate = mean(conversion_rate),
    sales = sum(sales)
  )

p1 <- ggplot(kpi, aes(x = quarter, y = add_to_cart, group = 1)) +
  geom_line() + geom_point() + labs(title = "Add to Cart", y = "Count", x = "")

p2 <- ggplot(kpi, aes(x = quarter, y = begin_checkout, group = 1)) +
  geom_line() + geom_point() + labs(title = "Begin Checkout", y = "Count", x = "")

p3 <- ggplot(kpi, aes(x = quarter, y = conversion_rate, group = 1)) +
  geom_line() + geom_point() + labs(title = "Conversion Rate", y = "Rate", x = "")

p4 <- ggplot(kpi, aes(x = quarter, y = sales/1000, group = 1)) +
  geom_line() + geom_point() + labs(title = "Total Sales (k$)", y = "k$", x = "")

combo <- (p1 | p2) / (p3 | p4)
ggsave(file.path(fig_dir, "kpi_snapshot.png"), combo, width = 10, height = 6, dpi = 150)
