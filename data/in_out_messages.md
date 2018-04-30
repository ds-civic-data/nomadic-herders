In\_out\_messages
================

``` r
# load deidentified data

LTS_data <- read_csv("~/nomadic-herders/LTSdata/LTS_deidentified (1).csv")
```

    ## Warning: Missing column names filled in: 'X1' [1]

``` r
# wrangle data - get rid of unnecessary column

LTS_data <- LTS_data %>%
  select(-X1)
```

Working with incoming messages
------------------------------

``` r
# create incoming messages dataframe
In <- LTS_data %>%
  filter(Type == "in")

# regexpression to pull out messages in correct/incorrect format
correct_exp <- "(^[0-9]{5}\\s{1,}[0-9]{1})"


# create correct/incorrect column
In$correct <- if_else(grepl(correct_exp,In$Message),'correct','incorrect')

# create area column for correct/incorrect
In <- In %>%
  mutate(area = str_extract(In$Message, "[0-9]{5}")) 

write.csv(In, file = "In.csv")

# separate message column into area code and request type - this probably only makes sense to do for correct messages
Correct <- In %>%
  filter(correct == "correct") %>%
  separate(Message, c("area", "request"), sep = ("(\\s{1,4}|\\.)"), extra = "drop")

write.csv(Correct, file = "Correct.csv")
```

Working with outgoing messages
------------------------------

``` r
# outgoing messages - separate to translate

Out <- LTS_data %>%
  filter(Type == "out") 

# create a column for the type of outgoing message
weather_exp <- "((nartai)|(borootoi)|(tsastai)|(uulerheg))"

  
Out$info_type <- if_else(grepl(weather_exp, Out$Message),'weather','pasture')

Out <- Out %>%
  mutate(weather = str_extract(Out$Message, weather_exp))

# create weather key 
Weather <- tribble(
  ~weather_eng, ~weather_mon, 
  "snow ", "tsastai",
  "rain", "borootoi",
  "sun", "nartai",
  "clouds", "uulerheg")

#join english with mongolian weather forecast

Out <- Out %>%
  full_join(Weather, by = c("weather" = "weather_mon"))

write.csv(Out, "out_LTS_data.csv")
```
