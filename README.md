# testing-BioTIMEr
This repository provides a "controlled" environment for trying and testing the
BioTIMEr package.

## Repeatability
### Packages
The exact versions of the used package, most importantly BioTIMEr, are stored in
`/renv.lock`

``` r
renv::lockfile_read()$Packages$BioTIMEr
renv::restore()
```

### Data
A specific version of the BioTIME data set is downloaded in the
`/1_downloading_BioTIME.R` script.
