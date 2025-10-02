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
  ref = getBetaMetrics_reference(df, "BIOMASS"),
  new = getBetaMetrics(df, "BIOMASS")
)
#   expression      min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 ref           2.96m  2.96m   0.00563  209.07GB    0.805     1   143      2.96m
# 2 new           39.6s  39.6s   0.0253     1.14GB    0.859     1    34      39.6s

# Several resamps
df2 <- resampling(x, measure = "BIOMASS", verbose = FALSE, resamps = 2L)

bench::mark(
  check = FALSE,
  ref = {
    df2 |>
      dplyr::reframe(
        getBetaMetrics_reference(
          x = pick(assemblageID, YEAR, Species, BIOMASS),
          measure = "BIOMASS"
        ),
        .by = resamp
      )
  },
  new = getBetaMetrics(df2, "BIOMASS")
)
#   expression      min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 ref           5.54m  5.54m   0.00301  264.93GB    0.406     1   135      5.54m
# 2 new           1.36m  1.36m   0.0123     2.28GB    0.724     1    59      1.36m
