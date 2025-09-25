# benchmarking and profiling dtplyr functions on a big chunk of BioTIME ----
# Check your BioTIMEr version
identical(
  renv::lockfile_read()$Packages$BioTIMEr$RemoteSha,
  "7111fb2d6a5373f07bd218c231a5b51bdc8df5a4"
)
# renv::install("biotimehub/biotimer@7111fb2d6a5373f07bd218c231a5b51bdc8df5a4")
library(dplyr)
library(BioTIMEr)
seed <- 42

# Gridding ----
x <- gridding(BTsubset_meta, BTsubset_data)

# Resampling ----
rf <- resampling_ref(x, "BIOMASS", resamps = 10L)
nw <- resampling(x, "BIOMASS", resamps = 10L)

colnames(rf)
colnames(nw)

set.seed(seed)
x |>
  resampling_ref(measure = "BIOMASS", resamps = 10L) |>
  filter(assemblageID == "211_529239") |>
  summarise(N = sum(BIOMASS), .by = c(assemblageID, Species)) |>
  arrange() |>
  head()
set.seed(seed)
x |>
  resampling("BIOMASS", resamps = 10L) |>
  filter(assemblageID == "211_529239") |>
  summarise(N = sum(BIOMASS), .by = c(assemblageID, Species)) |>
  arrange() |>
  head()

rf |>
  filter(assemblageID == "211_529239") |>
  summarise(S = n_distinct(Species), .by = assemblageID) |>
  arrange()
nw |>
  filter(assemblageID == "211_529239") |>
  summarise(S = n_distinct(Species), .by = assemblageID) |>
  arrange()
