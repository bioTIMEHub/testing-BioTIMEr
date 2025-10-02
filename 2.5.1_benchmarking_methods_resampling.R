# benchmarking and profiling dtplyr functions on a big chunk of BioTIME ----
# Check your BioTIMEr version
identical(
  renv::lockfile_read()$Packages$BioTIMEr$RemoteSha,
  "b001f0e0d0604ae552794394428e82b4b1d65b41"
)

library(dplyr)
library(BioTIMEr)

meta <- read.csv(file = "data/raw/BioTIME/metadata.csv")
bt <- readRDS(file = "data/raw/BioTIME/query.rds")

x <- gridding(meta, bt)
y <- data.table::copy(x)
data.table::setDT(y)

bench::mark(
  check = FALSE,
  df = resampling(x, measure = "BIOMASS", verbose = FALSE),
  dt = resampling(y, measure = "BIOMASS", verbose = FALSE)
)
#   expression   min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 df         5.45s  5.45s     0.183    3.37GB    0.550     1     3      5.45s
# 2 dt         3.89s  3.89s     0.257    1.62GB    0.257     1     1      3.89s

bench::mark(
  check = FALSE,
  df = resampling(x, measure = "BIOMASS", verbose = FALSE, resamps = 3L),
  dt = resampling(y, measure = "BIOMASS", verbose = FALSE, resamps = 3L)
)
#   expression   min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 df         7.69s  7.69s     0.130    4.38GB    0.390     1     3      7.69s
# 2 dt          8.2s   8.2s     0.122    2.51GB    0.488     1     4       8.2s

bench::mark(
  check = FALSE,
  df = resampling(x, measure = "BIOMASS", verbose = FALSE, conservative = TRUE),
  dt = resampling(y, measure = "BIOMASS", verbose = FALSE, conservative = TRUE)
)
#   expression   min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 df         17.5s  17.5s    0.0572     8.4GB    0.572     1    10      17.5s
# 2 dt           17s    17s    0.0589    6.53GB    0.589     1    10        17s
