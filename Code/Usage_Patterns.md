Usage\_Descriptive\_Stats
================
Ilana Heaton

How are people requesting information from the system?
======================================================

``` r
# Do they ask for information from multiple locations?

In <- read.csv("~/nomadic-herders/data/In.csv")

In %>%
  group_by(id) %>%
  distinct(area, .keep_all = TRUE) %>%
  summarise(n = n()) %>%
 ungroup() %>%
  count(n) %>%
  head(n = 7) %>%
  mutate(n = as.character(n)) %>%
  ggplot(aes(x = n, y = nn)) + geom_col() + labs(title = "Distribution of Users by Number of Area Codes Requested", y = "Users", x = "Number of Area Codes") + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(),  axis.line = element_blank())
```

![](Usage_Patterns_files/figure-markdown_github/unnamed-chunk-1-1.png)

``` r
In %>%
  group_by(id) %>%
  distinct(area, .keep_all = TRUE) %>%
  summarise(n = n()) %>%
 ungroup() %>%
  count(n)
```

    ## # A tibble: 33 x 2
    ##        n    nn
    ##    <int> <int>
    ##  1     1 10142
    ##  2     2  2281
    ##  3     3   523
    ##  4     4   170
    ##  5     5    49
    ##  6     6    15
    ##  7     7    13
    ##  8     8     2
    ##  9     9     3
    ## 10    10     4
    ## # ... with 23 more rows

``` r
# How many people are frequent users?
```

``` r
# How many times do users request information?

mult_requests <- In %>%
  group_by(id, Date) %>%
  summarise(n = n()) %>%
  filter(n > 1) %>% 
  ungroup() %>%
  group_by(Date) %>%
  summarise(n = n()) 

requests <- In %>%
  group_by(Date) %>%
  distinct(id, .keep_all = TRUE) %>%
  summarise(total = n())

mult_requests %>%
  left_join(requests, by = c("Date" = "Date")) %>% 
  mutate(prop = n/total) %>%
  summarise(num = n(), max = max(prop), min = min(prop), mean = mean(prop), median = median(prop))
```

    ## # A tibble: 1 x 5
    ##     num   max    min  mean median
    ##   <int> <dbl>  <dbl> <dbl>  <dbl>
    ## 1   572  1.00 0.0625 0.296  0.290

Here, number is equivalent to the number of days at least one user sent in more than one correctly formatted request for information. The max is the max proportion of users who sent in multiple requests, and min is the min proportion of users who sent in more than one request for information. Mean and median are about equivalent, suggesting that they're fairly indicative of the center of the data.

What kind of information do people ask about?
=============================================

``` r
Correct <- read_csv("~/nomadic-herders/data/Correct.csv")
```

    ## Warning: Missing column names filled in: 'X1' [1]

    ## Warning: Duplicated column names deduplicated: 'area' => 'area_1' [9]

    ## Parsed with column specification:
    ## cols(
    ##   X1 = col_integer(),
    ##   id = col_integer(),
    ##   Date = col_date(format = ""),
    ##   Time = col_datetime(format = ""),
    ##   Type = col_character(),
    ##   area = col_integer(),
    ##   request = col_integer(),
    ##   correct = col_logical(),
    ##   area_1 = col_integer(),
    ##   area_correct = col_character()
    ## )

``` r
# total of each kind of request by month

tot_request <- Correct %>%
  mutate(Month = month(Date), Year = year(Date)) %>%
  filter(request < 4, request > 0) %>%
mutate(request = as.factor(request)) %>%
  group_by(Month, Year) %>%
  summarise(total = n()) %>%
  mutate(Date = make_date(year = Year, month = Month))

# Over time?
Correct %>%
  mutate(Month = month(Date), Year = year(Date)) %>%
  filter(request < 4, request > 0) %>%
  group_by(Month, Year, request) %>%
  summarise(num = n()) %>%
  mutate(Date = make_date(month = Month, year = Year)) %>%
  mutate(request = as.factor(request)) %>%
  ggplot(aes(x = Date, y = num, fill = request)) + geom_col(position = "dodge")
```

![](Usage_Patterns_files/figure-markdown_github/unnamed-chunk-5-1.png)

``` r
# By proportion?

Correct %>%
  mutate(Month = month(Date), Year = year(Date)) %>%
  filter(request < 4, request > 0) %>%
  group_by(Month, Year, request) %>%
  summarise(num = n()) %>%
  mutate(Date = make_date(month = Month, year = Year)) %>%
  mutate(request = as.factor(request)) %>%
  left_join(tot_request, by = "Date") %>%
  mutate(prop = num/total) %>%
  ggplot(aes(x = Date, y = prop, fill = request)) + geom_col(position = "dodge")
```

![](Usage_Patterns_files/figure-markdown_github/unnamed-chunk-5-2.png)

``` r
# THIS ANALYSIS IS INCLUDED IN TYPE OF REQUEST GRAPH
Correct %>% 
  filter(request <4, request > 0) %>%
  group_by(request) %>%
  summarise(n = n())
```

    ## # A tibble: 3 x 2
    ##   request     n
    ##     <int> <int>
    ## 1       1 36188
    ## 2       2 14628
    ## 3       3  1349

``` r
# NUMBER OF USERS ASKING FOR PASTURE INFORMATION

ids <- Correct %>% 
  filter(request == "3") %>%
  group_by(id) %>%
  summarise(n = n()) %>%
  arrange(desc(n))

ids <- as.vector(ids$id)  

Correct %>%
  filter(id %in% ids) %>%
  mutate(year = year(Date), month = month(Date)) %>%
  group_by(year, month) %>%
  summarise(n = n()) %>%
  mutate(date = make_date(year = year, month = month)) %>%
  ggplot(aes(x = date, y = n)) + geom_line()
```

![](Usage_Patterns_files/figure-markdown_github/unnamed-chunk-5-3.png)

Which area codes have the most usage over time? How does that relate to weather patterns?
=========================================================================================

``` r
pop_areas <- In %>%
  filter(area_correct == "real") %>%
 group_by(area) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  filter(!is.na(area)) %>%
  head(n = 30)
  
In %>% 
  mutate(Month = month(Date), Year = year(Date)) %>%
  filter(area == "62267") %>%
  group_by(Month, Year) %>% 
  summarise(n = n()) %>%
  mutate(Date = make_date(month = Month, year = Year)) %>%
  ggplot(aes(x = Date, y = n)) + geom_line()
```

![](Usage_Patterns_files/figure-markdown_github/unnamed-chunk-6-1.png)

``` r
In %>% 
  mutate(Month = month(Date), Year = year(Date)) %>%
  filter(area == "84217") %>%
  group_by(Month, Year) %>% 
  summarise(n = n()) %>%
  mutate(Date = make_date(month = Month, year = Year)) %>%
  ggplot(aes(x = Date, y = n)) + geom_line()
```

![](Usage_Patterns_files/figure-markdown_github/unnamed-chunk-6-2.png)

``` r
In %>% 
  mutate(Month = month(Date), Year = year(Date)) %>%
  filter(area == "46135") %>%
  group_by(Month, Year) %>% 
  summarise(n = n()) %>%
  mutate(Date = make_date(month = Month, year = Year)) %>%
  ggplot(aes(x = Date, y = n)) + geom_line()
```

![](Usage_Patterns_files/figure-markdown_github/unnamed-chunk-6-3.png)

``` r
In %>% 
  mutate(Month = month(Date), Year = year(Date)) %>%
  filter(area == "67179") %>%
  group_by(Month, Year) %>% 
  summarise(n = n()) %>%
  mutate(Date = make_date(month = Month, year = Year)) %>%
  ggplot(aes(x = Date, y = n)) + geom_line()
```

![](Usage_Patterns_files/figure-markdown_github/unnamed-chunk-6-4.png)

``` r
# Read in zip coords csv

zip_data <- read_excel("~/nomadic-herders/LTSdata/Zip_extension_2016_2017.xlsx")

pop_coords <- tribble(
  ~"area", ~"lat", ~"lon",
   62267, 45.874712248905, 101.39282226562,
  84217, 46.105613079983, 91.419982910156, 
  46135, 43.6604462286, 101.955970337,
  67179, 51.481382896101, 99.596557617188,
  23177, 46.717268685074, 109.75341796875,
  62110, 46.918379324152, 102.76259422302,
  62211, 46.852678248531, 102.21130371094
)
pop_areas <- pop_areas %>%
  left_join(pop_coords, by = c("area" = "area"))

write.csv(pop_areas, "pop_areas.csv")
```
