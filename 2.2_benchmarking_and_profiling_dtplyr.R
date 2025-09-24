# benchmarking and profiling dtplyr functions on a big chunk of BioTIME ----
# Check your BioTIMEr version
identical(
  renv::lockfile_read()$Packages$BioTIMEr$RemoteSha,
  "be6e4a0eace0c1a5a930a71b410e23fe43bdd0b2"
)

library(dplyr)
library(BioTIMEr)

## Reading ----
meta <- read.csv(file = "data/raw/BioTIME/metadata.csv")
bt <- readRDS(file = "data/raw/BioTIME/query.rds")

meta <- meta |> slice_head(n = floor(nrow(meta) / 2L))
bt <- semi_join(bt, meta, by = join_by("STUDY_ID"))

## Gridding ----
bench::mark(
  check = FALSE,
  dplyr = gridding_reference(meta, bt, 12, verbose = FALSE),
  dtplyr = gridding(meta, bt, 12, verbose = FALSE)
)
#   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time result memory
#   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm> <list> <list>
# 1 dplyr         17.3s    17.3s    0.0579    10.8GB    0.116     1     2      17.3s <NULL> <Rprofmem>
# 2 dtplyr        26.6s    26.6s    0.0377    21.2GB    0.226     1     6      26.6s <NULL> <Rprofmem>

profvis::profvis(gridding(meta, bt, 12, verbose = FALSE))
profvis::profvis(gridding_reference(meta, bt, 12, verbose = FALSE))

## Resampling ----
study_id_selection <- sample(meta$STUDY_ID |> unique(), 20)
meta_sel <- meta |> filter(is.element(STUDY_ID, study_id_selection))
bt_sel <- bt |> filter(is.element(STUDY_ID, study_id_selection))

g <- gridding_reference(meta_sel, bt_sel, 12, verbose = FALSE)
gdt <- gridding(meta_sel, bt_sel, 12, verbose = FALSE)

bench::mark(
  check = FALSE,
  dplyr = {
    set.seed(42)
    resampling_ref(g, measure = "BIOMASS")
  },
  dtplyr = {
    set.seed(42)
    resampling(gdt, measure = "BIOMASS", verbose = FALSE, summarise = FALSE)
  }
)
#   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time result memory
#   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm> <list> <list>
# 1 dplyr         51.9s    51.9s  0.0193       276GB    0.482     1    25      51.9s <NULL> <Rprofmem>
# 2 dtplyr        21.9m    21.9m  0.000762    1010GB    0.133     1   174      21.9m <NULL> <Rprofmem>

profvis::profvis(resampling_ref(g, measure = "BIOMASS"), )
profvis::profvis(resampling(
  gdt,
  measure = "BIOMASS",
  verbose = FALSE,
  summarise = FALSE
))
