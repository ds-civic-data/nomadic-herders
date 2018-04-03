unique\_identifier
================
Wenxin Du
2018/4/1

``` r
library(readxl)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
JunSep16 <- read_excel("~/nomadic-herders/LTSdata/2016JunToSep.xls")
OctNov16 <- read_excel("~/nomadic-herders/LTSdata/2016OctNov.xlsx")
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
JunSep16
```

    ## # A tibble: 24,887 x 5
    ##    Date                Time                     Number Type  Message      
    ##    <dttm>              <dttm>                    <dbl> <chr> <chr>        
    ##  1 2016-06-02 00:00:00 1899-12-31 12:10:51 97699793744 in    Soum davst   
    ##  2 2016-06-02 00:00:00 1899-12-31 16:28:30 97699062968 in    621101 1 640…
    ##  3 2016-06-03 00:00:00 1899-12-31 09:29:34 97699013127 in    85020 1      
    ##  4 2016-06-03 00:00:00 1899-12-31 09:31:14 97699013127 out   6sar3: uuler…
    ##  5 2016-06-03 00:00:00 1899-12-31 10:50:46 97699013652 in    82100 1      
    ##  6 2016-06-03 00:00:00 1899-12-31 11:26:44 97699089685 in    62110 1      
    ##  7 2016-06-03 00:00:00 1899-12-31 12:19:51 97699013127 in    83021 2      
    ##  8 2016-06-03 00:00:00 1899-12-31 12:20:45 97699013127 out   6sar6: uuler…
    ##  9 2016-06-03 00:00:00 1899-12-31 12:57:13 97699062968 in    64030 1      
    ## 10 2016-06-03 00:00:00 1899-12-31 14:00:45 97699171711 in    65080 1      
    ## # ... with 24,877 more rows

``` r
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
LTS <- bind_rows(Apr17, AugSep17, Dec17, JanMar17, Jul17, Jun17, JunSep16, May17, OctDec17, OctNov16)
LTS <- select(LTS, Date, Time, Type, Number, Message)
LTS
```

    ## # A tibble: 107,213 x 5
    ##    Date                Time                Type       Number Message      
    ##    <dttm>              <dttm>              <chr>       <dbl> <chr>        
    ##  1 2017-04-01 00:00:00 1899-12-31 00:00:49 in       80130123 83183   2    
    ##  2 2017-04-01 00:00:00 1899-12-31 00:01:33 out   97680130123 4sar4: tsast…
    ##  3 2017-04-01 00:00:00 1899-12-31 02:52:27 out   97698430992 3sar31: uule…
    ##  4 2017-04-01 00:00:00 1899-12-31 02:53:04 out   97698430992 3sar31: uule…
    ##  5 2017-04-01 00:00:00 1899-12-31 02:53:05 out   97698430992 3sar31: uule…
    ##  6 2017-04-01 00:00:00 1899-12-31 06:31:14 in    97698822696 23177 1      
    ##  7 2017-04-01 00:00:00 1899-12-31 06:31:30 in    97698822696 23177 2      
    ##  8 2017-04-01 00:00:00 1899-12-31 06:31:44 in    97698515193 23281        
    ##  9 2017-04-01 00:00:00 1899-12-31 06:31:50 out   97698822696 4sar1: uuler…
    ## 10 2017-04-01 00:00:00 1899-12-31 06:31:55 out   97698822696 4sar4: uuler…
    ## # ... with 107,203 more rows

``` r
LTS <- LTS %>%
  mutate(Number = ifelse(nchar(as.character(Number)) == 11, Number %% 100000000, Number),
         Number = ifelse(nchar(as.character(Number)) == 10, Number %% 10000000, Number))
LTS %>%
  arrange(desc(Number))
```

    ## # A tibble: 107,213 x 5
    ##    Date                Time                Type    Number Message         
    ##    <dttm>              <dttm>              <chr>    <dbl> <chr>           
    ##  1 2016-06-19 00:00:00 1899-12-31 15:08:05 in    99999374 65025 2         
    ##  2 2016-06-19 00:00:00 1899-12-31 15:09:43 out   99999374 6sar22: uulerhe…
    ##  3 2017-04-06 00:00:00 1899-12-31 21:40:28 in    99998331 62103 1         
    ##  4 2017-04-06 00:00:00 1899-12-31 21:41:44 out   99998331 4sar6: uulerheg 
    ##  5 2017-10-22 00:00:00 1899-12-31 14:28:14 out   99998331 10sar22: nartai 
    ##  6 2017-10-22 00:00:00 1899-12-31 14:30:08 in    99998331 62090 1         
    ##  7 2017-07-07 00:00:00 1899-12-31 19:39:10 in    99996938 84211 1         
    ##  8 2017-07-07 00:00:00 1899-12-31 19:39:22 out   99996938 7sar7: nartai   
    ##  9 2016-06-12 00:00:00 1899-12-31 13:44:25 in    99996149 85060 1         
    ## 10 2016-06-12 00:00:00 1899-12-31 13:44:51 out   99996149 6sar11: nartai;…
    ## # ... with 107,203 more rows

``` r
n <- LTS %>%
  distinct(Number)
nl <- as.vector(n$Number)
nr <- n %>%
  nrow()
```

``` r
set.seed(111)
id <- floor(runif(nr, min = 10000, max = 99999))
```

``` r
identifier <- data.frame(nl, id) %>%
  mutate(Number = nl) %>%
  select(Number, id)
```

``` r
LTS_unique_ident <- full_join(LTS, identifier) %>%
  select(id, Date, Time, Type, Message) 
```

    ## Joining, by = "Number"

``` r
LTS_unique_ident
```

    ## # A tibble: 107,213 x 5
    ##       id Date                Time                Type  Message         
    ##    <dbl> <dttm>              <dttm>              <chr> <chr>           
    ##  1 63367 2017-04-01 00:00:00 1899-12-31 00:00:49 in    83183   2       
    ##  2 63367 2017-04-01 00:00:00 1899-12-31 00:01:33 out   4sar4: tsastai  
    ##  3 75382 2017-04-01 00:00:00 1899-12-31 02:52:27 out   3sar31: uulerheg
    ##  4 75382 2017-04-01 00:00:00 1899-12-31 02:53:04 out   3sar31: uulerheg
    ##  5 75382 2017-04-01 00:00:00 1899-12-31 02:53:05 out   3sar31: uulerheg
    ##  6 43337 2017-04-01 00:00:00 1899-12-31 06:31:14 in    23177 1         
    ##  7 43337 2017-04-01 00:00:00 1899-12-31 06:31:30 in    23177 2         
    ##  8 56342 2017-04-01 00:00:00 1899-12-31 06:31:44 in    23281           
    ##  9 43337 2017-04-01 00:00:00 1899-12-31 06:31:50 out   4sar1: uulerheg 
    ## 10 43337 2017-04-01 00:00:00 1899-12-31 06:31:55 out   4sar4: uulerheg 
    ## # ... with 107,203 more rows
