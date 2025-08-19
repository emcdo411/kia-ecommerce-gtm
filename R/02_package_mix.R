# install.packages(c("tidyverse","scales","patchwork","gt"))
library(tidyverse)
library(scales)
library(patchwork)
library(gt)

fig_dir <- "docs/figures"
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

# 02_package_mix.R
mix <- read_csv("data/sample_enrollment_by_package.csv", show_col_types = FALSE)

p <- ggplot(mix, aes(x = package_tier, y = dealers, fill = package_tier)) +
  geom_col() +
  geom_text(aes(label = dealers), vjust = -0.3) +
  labs(title = "Dealer Count by Package Tier", x = "", y = "Dealers") +
  theme(legend.position = "none")

ggsave(file.path(fig_dir, "package_mix.png"), p, width = 8, height = 5, dpi = 150)
