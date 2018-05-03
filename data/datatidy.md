unique\_identifier
================
Wenxin Du
2018/4/1

``` r
library(lubridate)
```

    ## 
    ## Attaching package: 'lubridate'

    ## The following object is masked from 'package:base':
    ## 
    ##     date

``` r
library(readxl)
library(dplyr)
```

``` r
JunSep16 <- read_excel("~/nomadic-herders/LTSdata/2016JunToSep.xls")
OctNov16 <- read_excel("~/nomadic-herders/LTSdata/2016OctNov.xlsx")
Dec16 <- read_excel("~/nomadic-herders/LTSdata/2016Dec.xlsx")
Apr17 <- read_excel("~/nomadic-herders/LTSdata/2017Apr.xlsx")
AugSep17 <- read_excel("~/nomadic-herders/LTSdata/2017AugSep.xlsx")
Dec17 <- read_excel("~/nomadic-herders/LTSdata/2017Dec.xlsx")
JanMar17 <- read_excel("~/nomadic-herders/LTSdata/2017JanToMar.xlsx")
Jul17 <- read_excel("~/nomadic-herders/LTSdata/2017Jul.xlsx")
Jun17 <-read_excel("~/nomadic-herders/LTSdata/2017Jun.xlsx")
May17 <- read_excel("~/nomadic-herders/LTSdata/2017May.xlsx")
OctDec17 <- read_excel("~/nomadic-herders/LTSdata/2017OctDec.xlsx")
```

``` r
JunSep16 <- JunSep16 %>%
  mutate(Number = as.numeric(substr(Number, 2, 100)))
OctNov16 <- OctNov16 %>%
  mutate(Number = as.numeric(Number), Name = as.numeric(Name))
```

    ## Warning in evalq(as.numeric(Number), <environment>): NAs introduced by
    ## coercion

    ## Warning in evalq(as.numeric(Name), <environment>): NAs introduced by
    ## coercion

``` r
Jul17 <- Jul17 %>%
  mutate(Name = as.numeric(Name))
```

    ## Warning in evalq(as.numeric(Name), <environment>): NAs introduced by
    ## coercion

``` r
LTS <- bind_rows(Apr17, AugSep17, Dec17, JanMar17, Jul17, Jun17, JunSep16, May17, OctDec17, OctNov16, Dec16)
LTS <- select(LTS, Date, Time, Type, Number, Message)
```

``` r
LTS <- LTS %>%
  mutate(Number = ifelse(nchar(as.character(Number)) == 11, Number %% 100000000, Number),
         Number = ifelse(nchar(as.character(Number)) == 10, Number %% 10000000, Number))
```

``` r
n <- LTS %>%
  distinct(Number)
nl <- as.vector(n$Number)
nr <- n %>%
  nrow()
```

``` r
set.seed(111)
id_ <- sample(10000:99999, nr, replace=FALSE)
id <- floor(runif(nr, min = 10000, max = 99999)) ###wrong code, not truly distinct numbers generated
```

``` r
identifier <- data.frame(nl, id_) %>%
  mutate(Number = nl, id = id_) %>%
  select(Number, id)
```

``` r
LTS_unique_ident <- left_join(LTS, identifier) %>%
  select(id, Date, Time, Type, Message) 
```

    ## Joining, by = "Number"

``` r
LTS_unique_ident
```

    ## # A tibble: 125,409 x 5
    ##       id Date                Time                Type  Message         
    ##    <int> <dttm>              <dttm>              <chr> <chr>           
    ##  1 63368 2017-04-01 00:00:00 1899-12-31 00:00:49 in    83183   2       
    ##  2 63368 2017-04-01 00:00:00 1899-12-31 00:01:33 out   4sar4: tsastai  
    ##  3 75382 2017-04-01 00:00:00 1899-12-31 02:52:27 out   3sar31: uulerheg
    ##  4 75382 2017-04-01 00:00:00 1899-12-31 02:53:04 out   3sar31: uulerheg
    ##  5 75382 2017-04-01 00:00:00 1899-12-31 02:53:05 out   3sar31: uulerheg
    ##  6 43337 2017-04-01 00:00:00 1899-12-31 06:31:14 in    23177 1         
    ##  7 43337 2017-04-01 00:00:00 1899-12-31 06:31:30 in    23177 2         
    ##  8 56341 2017-04-01 00:00:00 1899-12-31 06:31:44 in    23281           
    ##  9 43337 2017-04-01 00:00:00 1899-12-31 06:31:50 out   4sar1: uulerheg 
    ## 10 43337 2017-04-01 00:00:00 1899-12-31 06:31:55 out   4sar4: uulerheg 
    ## # ... with 125,399 more rows

``` r
write.csv(LTS_unique_ident, file = "LTS_deidentified.csv")
```
