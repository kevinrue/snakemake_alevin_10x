library(tidyverse)
library(tximport)
library(DelayedMatrixStats)
library(cowplot)
library(sessioninfo)

quants_mat_file <- snakemake@input[["quants"]]
plot_file <- snakemake@output[[1]]

txi <- tximport::tximport(files = quants_mat_file, type = "alevin")
str(txi)

plot <- tibble(
    barcode = colnames(txi$counts),
    total = DelayedMatrixStats::colSums2(txi$counts)
) %>%
    arrange(desc(total)) %>%
    mutate(rank = row_number()) %>%
    ggplot() +
    geom_point(aes(rank, total)) +
    scale_y_log10() + scale_x_log10() +
    theme_cowplot()
ggsave(filename = plot_file, plot = plot)

sessioninfo::session_info()
