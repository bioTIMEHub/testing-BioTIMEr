# Testing parser and finding SAMPLE_DESC and SAMPLE_DESC_NAME
# Check your BioTIMEr version
# renv::install("biotimehub/biotimer@2fa6719a91dfb33bf94fa32d47bbc8f7a7bcff8e")
identical(
  renv::lockfile_read()$Packages$BioTIMEr$RemoteSha,
  "2fa6719a91dfb33bf94fa32d47bbc8f7a7bcff8e"
)

# Loading packages
library(dplyr)
library(BioTIMEr)

# Reading
meta <- read.csv(file = "data/raw/BioTIME/metadata.csv")
bt <- readRDS(file = "data/raw/BioTIME/query.rds")

dt <- dplyr::left_join(
  meta |> dplyr::select(STUDY_ID, SAMPLE_DESC_NAME),
  bt |>
    dplyr::distinct(STUDY_ID, SAMPLE_DESC),
  dplyr::join_by(STUDY_ID)
) |>
  mutate(parser_BioTIME(
    SAMPLE_DESC,
    SAMPLE_DESC_NAME,
    "_"
  ))

n_distinct(dt$STUDY_ID)

dt |> filter(!is.na(error_format)) |> distinct(STUDY_ID)

#   STUDY_ID
# 1       313
# 2       321
# 3       333
# 4       457
# 5       475
# 6       554
# 7       556
# 8       557
# 9       559
# 10      563
# 11      644
# 12      662
# 13      672
# 14      676
# 15      756
# 16      784
