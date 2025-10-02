# benchmarking and profiling dtplyr functions on a big chunk of BioTIME ----
# Check your BioTIMEr version
identical(
  renv::lockfile_read()$Packages$BioTIMEr$RemoteSha,
  "65f2c142a68bdc949d862a1a6c9ee80f3c2ab25b"
)

library(dplyr)
library(BioTIMEr)

meta <- data.table::fread(file = "data/raw/BioTIME/metadata.csv")
bt <- readRDS(file = "data/raw/BioTIME/query.rds")

meta4 <- meta |> slice_head(n = floor(nrow(meta) / 4L)) # 1/4 BioTIME
bt4 <- semi_join(bt, meta4, by = join_by("STUDY_ID"))

x <- gridding(meta4, bt4, verbose = FALSE)
data.table::setDT(x)
df <- resampling(x, measure = "BIOMASS", verbose = FALSE, resamps = 1L)

bench::mark(
  check = FALSE,
  ref = getAlphaMetrics_reference(df, "BIOMASS"),
  new = getAlphaMetrics(df, "BIOMASS")
)
#   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 ref           3.43m    3.43m   0.00486  217.21GB    0.404     1    83      3.43m
# 2 new           1.34m    1.34m   0.0124     1.77GB    0.697     1    56      1.34m

# Several resamps
df2 <- resampling(x, measure = "BIOMASS", verbose = FALSE, resamps = 2L)

bench::mark(
  check = FALSE,
  ref = {
    df2 |>
      dplyr::reframe(
        getAlphaMetrics_reference(
          x = pick(assemblageID, YEAR, Species, BIOMASS),
          measure = "BIOMASS"
        ),
        .by = resamp
      )
  },
  new = getAlphaMetrics(df2, "BIOMASS")
)
#   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 ref           7.86m    7.86m   0.00212  281.16GB    0.269     1   127      7.86m
# 2 new           2.85m    2.85m   0.00586    3.54GB    0.433     1    74      2.85m
