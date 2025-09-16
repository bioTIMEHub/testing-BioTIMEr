# Downloading BioTIME
if (!file.exists("data/raw/BioTIME/metadata.csv")) {
  dir.create(
    path = "data/raw/BioTIME/",
    showWarnings = FALSE,
    recursive = TRUE
  )
  curl::curl_download(
    url = "https://zenodo.org/records/15222193/files/biotime_v2_metadata_15April25.csv?download=1",
    destfile = "data/raw/BioTIME/metadata.csv"
  )
}

if (!file.exists("data/raw/BioTIME/query.rds")) {
  curl::curl_download(
    url = "https://zenodo.org/records/15222193/files/biotime_v2_query_15April25.rds?download=1",
    destfile = "data/raw/BioTIME/query.rds"
  )
}
