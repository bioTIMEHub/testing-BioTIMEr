# Loading packages
library(dplyr)
library(BioTIMEr)

# Reading
bt <- readRDS(file = "data/raw/BioTIME/query.rds") |>
  filter(is.element(STUDY_ID, c(10, 42, 194))) |>
  mutate(across(
    .cols = c(
      ID_ALL_RAW_DATA,
      ID_SPECIES,
      SAMPLE_DESC,
      STUDY_ID,
      newID,
      valid_name
    ),
    .fns = as.factor
  )) |>
  as_tibble()

meta <- read.csv(file = "data/raw/BioTIME/metadata.csv") |>
  filter(is.element(STUDY_ID, unique(bt$STUDY_ID))) |>
  mutate(across(
    .cols = c(STUDY_ID, TAXA, ABUNDANCE_TYPE, BIOMASS_TYPE),
    .fns = as.factor
  ))


# Gridding
g <- gridding(meta, bt, res = 12)

# Resampling
summ <- resampling(g, "ABUNDANCE", summarise = TRUE)
full <- resampling(g, "ABUNDANCE", summarise = FALSE)

summ |>
  filter(
    assemblageID == "10_359170" & YEAR == 1996 & Species == "Amelanchier laevis"
  )
full |>
  filter(
    assemblageID == "10_359170" & YEAR == 1996 & Species == "Amelanchier laevis"
  )
