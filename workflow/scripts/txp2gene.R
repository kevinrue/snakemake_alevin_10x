library(rtracklayer)

gtf_file <- snakemake@input[["gtf"]]
tgmap_file <- snakemake@output[[1]]

gtf_data <- import.gff2(gtf_file, feature.type = 'transcript')
stopifnot(all(gtf_data$type == 'transcript'))

tg_map <- mcols(gtf_data)[, c('transcript_id', 'gene_id')]
tg_map <- unique(tg_map)

write.table(tg_map, tgmap_file, quote = FALSE, sep = '\t', row.names = FALSE, col.names = FALSE)

sessioninfo::session_info()
