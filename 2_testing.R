# Loading packages
library(dplyr)
library(BioTIMEr)

# Reading
meta <- read.csv(file = "data/raw/BioTIME/metadata.csv")
bt <- readRDS(file = "data/raw/BioTIME/query.rds")

# Gridding
## Gridding of whole bt 50 seconds (on eco-mode)
beginning <- Sys.time()
g <- gridding(meta, bt, res = 12)
Sys.time() - beginning

# Gridding of whole bt at Fine res - 34-40 seconds
beginning <- Sys.time()
gf <- gridding(meta, bt, res = 30)
Sys.time() - beginning
gf |> summarise(count = n_distinct(YEAR), .by = STUDY_ID) |> pull(count) ==
  1L |>
    any()

# Resampling
## gridded
### 1/6 of gridded BioTIME in 14 minutes (on eco-mode)
g6 <- g |> slice_head(n = floor(nrow(g) / 6L))
beginning <- Sys.time()
r <- resampling(g6, "ABUNDANCE")
Sys.time() - beginning

### 1/4 of gridded BioTIME in 11 minutes
g4 <- g |> slice((floor(nrow(g) / 4L)):(floor((nrow(g) / 4L) * 2)))
beginning <- Sys.time()
r <- resampling(g4, "ABUNDANCE")
Sys.time() - beginning


beginning <- Sys.time()
r <- resampling(g, "ABUNDANCE")
Sys.time() - beginning

t1 <- r |>
  summarise(n_distinct(YEAR) == 1L, .by = STUDY_ID)
