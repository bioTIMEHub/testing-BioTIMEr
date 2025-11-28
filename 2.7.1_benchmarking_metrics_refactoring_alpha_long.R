# benchmarking and profiling refactored functions on a big chunk of BioTIME ----
# Check your BioTIMEr version
identical(
  renv::lockfile_read()$Packages$BioTIMEr$RemoteSha,
  "81eed6e828f079395f3c19feadb620f15bb2e5a8"
)

# renv::install("biotimehub/biotimer@81eed6e")

library(dplyr)
library(BioTIMEr)

meta <- data.table::fread(file = "data/raw/BioTIME/metadata.csv")
bt <- readRDS(file = "data/raw/BioTIME/query.rds")

meta5 <- meta |> slice_head(n = nrow(meta) %/% 5L) # 1/5 BioTIME
bt5 <- semi_join(bt, meta5, by = join_by("STUDY_ID"))

x <- gridding(meta5, bt5, verbose = FALSE)
data.table::setDT(x)
df <- resampling(x, measure = "BIOMASS", verbose = FALSE, resamps = 1L)

bench::mark(
  check = FALSE,
  ref = BioTIMEr:::getAlphaMetrics_reference(df, "BIOMASS"),
  new = BioTIMEr:::getAlphaMetrics(df, "BIOMASS"),
  long = BioTIMEr:::getAlphaMetrics_long(df, "BIOMASS")
)
#   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 ref           3.07m    3.07m   0.00543  216.01GB    0.462     1    85      3.07m
# 2 new           1.19m    1.19m   0.0140     1.66GB    0.826     1    59      1.19m
# 3 long         30.38s   30.38s   0.0329   412.41MB    0.889     1    27     30.38s

# Several resamps
df3 <- resampling(x, measure = "BIOMASS", verbose = FALSE, resamps = 3L)

bench::mark(
  check = FALSE,
  ref = {
    df3 |>
      dplyr::reframe(
        BioTIMEr:::getAlphaMetrics_reference(
          x = pick(assemblageID, YEAR, Species, BIOMASS),
          measure = "BIOMASS"
        ),
        .by = resamp
      )
  },
  new = BioTIMEr:::getAlphaMetrics(df3, "BIOMASS"),
  long = BioTIMEr:::getAlphaMetrics_long(df3, "BIOMASS")
)
#   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 ref           9.83m    9.83m   0.00170  419.77GB    0.204     1   120      9.83m
# 2 new           3.71m    3.71m   0.00449    4.99GB    0.283     1    63      3.71m
# 3 long          1.36m    1.36m   0.0123     1.15GB    0.343     1    28      1.36m
