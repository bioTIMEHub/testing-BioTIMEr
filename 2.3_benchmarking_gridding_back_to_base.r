# benchmarking and profiling dtplyr functions on a big chunk of BioTIME ----
# Check your BioTIMEr version
identical(
  renv::lockfile_read()$Packages$BioTIMEr$RemoteSha,
  "97682087c2131305d148d2cadde9eaa6c4f8a526"
)
# renv::install("biotimehub/biotimer@97682087c2131305d148d2cadde9eaa6c4f8a526")
library(dplyr)
library(BioTIMEr)

## Reading ----
meta <- read.csv(file = "data/raw/BioTIME/metadata.csv")
bt <- readRDS(file = "data/raw/BioTIME/query.rds")

x <- gridding(BTsubset_meta, BTsubset_data)
y <- gridding_reference(BTsubset_meta, BTsubset_data)

# Whole BioTIME ----
bench::mark(
  check = FALSE,
  ref = gridding_reference(meta, bt),
  new = gridding(meta, bt)
)
# Slightly faster and only half of the memory
# expression         min   median  `itr/sec` mem_alloc `gc/sec` n_itr  n_gc
#   1 ref           30.9s    30.9s    0.0323   14.84GB   0.129      1     4
#   2 new           25.9s    25.9s    0.0386    6.34GB   0.0386     1     1

# expression          min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
#   1 ref           27.8s    27.8s    0.0359   14.87GB   0.251      1     7      27.8s
#   2 new           25.3s    25.3s    0.0395    6.44GB   0.0789     1     2      25.3s
