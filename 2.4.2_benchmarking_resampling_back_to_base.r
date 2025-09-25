# benchmarking and profiling dtplyr functions on a big chunk of BioTIME ----
# Check your BioTIMEr version
identical(
  renv::lockfile_read()$Packages$BioTIMEr$RemoteSha,
  "7111fb2d6a5373f07bd218c231a5b51bdc8df5a4"
)
# renv::install("biotimehub/biotimer@7111fb2d6a5373f07bd218c231a5b51bdc8df5a4")
library(dplyr)
library(BioTIMEr)

# Gridding ----
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
#   expression      min     median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
#   1 ref           29.2s    29.2s    0.0342   14.84GB    0.137     1     4      29.2s
#   2 new           26.5s    26.5s    0.0378    6.44GB    0.113     1     3      26.5s

#   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 ref           28.5s    28.5s    0.0351   14.84GB    0.211     1     6      28.5s
# 2 new           25.6s    25.6s    0.0391    6.43GB    0.117     1     3      25.6s

## Resampling - 1 resamp ----
### On a fraction of BioTIME
g <- gridding(meta, bt, 12, verbose = FALSE)

#### 20 STUDY_IDs ----

g20s <- g |> filter(is.element(STUDY_ID, sample(g$STUDY_ID |> unique(), 20)))

bench::mark(
  check = FALSE,
  ref = {
    set.seed(42)
    resampling_ref(g20s, measure = "BIOMASS")
  },
  new = {
    set.seed(42)
    resampling(g20s, measure = "BIOMASS", verbose = FALSE, summarise = TRUE)
  }
)

#   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 ref           1.76s    1.76s     0.569    2.42GB    0.569     1     1      1.76s
# 2 new         88.65ms  89.44ms     7.19    28.48MB    1.44      5     1   695.74ms

#### 100 STUDY_IDs ----
g100s <- g |> filter(is.element(STUDY_ID, sample(g$STUDY_ID |> unique(), 100)))
bench::mark(
  check = FALSE,
  ref = {
    set.seed(42)
    resampling_ref(g20s, measure = "BIOMASS")
  },
  new = {
    set.seed(42)
    resampling(g20s, measure = "BIOMASS", verbose = FALSE, summarise = TRUE)
  }
)
#   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 ref           14.3s    14.3s    0.0700    60.9GB     1.12     1    16      14.3s
# 2 new         357.4ms  460.3ms    2.17     153.6MB     1.09     2     1    920.7ms

#   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 ref           4.98s    4.98s     0.201    25.7GB    0.804     1     4      4.98s
# 2 new        122.67ms 123.52ms     7.84     79.4MB    0         4     0   510.41ms

#### 1/4 BioTIME
g4 <- g |> slice((floor(nrow(g) / 4L)):(floor((nrow(g) / 4L) * 2)))
beginning <- Sys.time()
r <- resampling(g4, "ABUNDANCE")
Sys.time() - beginning
# 4 seconds
bench::mark(
  check = FALSE,
  ref = resampling_ref(g4, "ABUNDANCE"),
  new = resampling(g4, "ABUNDANCE")
)

#### whole BioTIME
beginning <- Sys.time()
r1 <- resampling(g, "ABUNDANCE")
Sys.time() - beginning
# 14 seconds

beginning <- Sys.time()
r2 <- resampling(g, "BIOMASS")
Sys.time() - beginning
# 4 seconds

beginning <- Sys.time()
r3 <- resampling(g, c("BIOMASS", "ABUNDANCE"))
Sys.time() - beginning
# 4 seconds

beginning <- Sys.time()
r4 <- resampling(
  g,
  c("BIOMASS", "ABUNDANCE"),
  summarise = FALSE,
  conservative = TRUE
)
Sys.time() - beginning
# 23 seconds

## Resampling - 10 resamp ----
bench::mark(
  check = FALSE,
  ref = {
    ref10 <- resampling_ref(g20s, measure = "BIOMASS", resamps = 10)
  },
  new = {
    new10 <- resampling(g20s, mesure = "BIOMASS", resamps = 10L)
  }
)
#   expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
# 1 ref           12.2m    12.2m   0.00137    4.79TB    1.24      1   909      12.2m
# 2 new            6.1s     6.1s   0.164      1.31GB    0.164     1     1       6.1s
