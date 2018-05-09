LTS-2 System: Exploratory Analysis of Service Usage Over Time and Space
================

The System:
-----------

The LTS-2 is an SMS information system designed to help Mongolian Nomadic herders to improve lives outcomes. The system works by providing weather forecast and pasture information to herders by text message. Anyone with a Mongolian phone number can text into the system, though the information provided is tailored for nomadic herders. In particular, the system aims to reduce livestock deaths due to severe weather, and ensure long-term sustainability of herding by reducing overgrazing.

Users can request weather or pasture information via text. One to three, and four day forecasts are available, in addition to pasture information pulled from the Livestock Early Warning system run by Texas A&M University. To receive a text message response, users must request information for a specific bagh (subdistrict). The data we analyzed is comprised of all the incoming and outgoing texts associated with the LTS-2 system. Incoming texts consist of a bagh-level area code and an integer from 1-3 indicating request type. 1 and 2 represent one- to three-day and four- to six-day forecast respectively, while 3 represents a request for pasture information. The formatting of an incoming text must conform to fairly strict rules for a user to receive a response. The text must begin with a 5 digit bagh area code, followed by at least one space and the request type. Any change in formatting, or addition of other information will mean a user does not receive a response. In general, outgoing weather forecasts contain the starting date of the forecast interval, one of four predicted meteorological conditions (sun, clouds, rain, snow). When available, higher resolution forecasts that include high and low temperature are provided.

The Data
--------

As described above the system is comprised of incoming and outgoing messages in the system. Due to the system’s cataloging method, the dataset does not contain a response for every request, or a request for every response. The first is due to user error. Improperly formatted messages are catalogued but do not receive a response. The second, is a system error. In the dataset, these errors appear to be messages sent to phone numbers that never sent requests for information; however, these messages are due to transcription errors in the system’s data collection method, and no actual messages were sent out. An update to the system in the fall of 2016 mostly solved the problem. These phantom messages appear only infrequently after September 2016.

The raw data we analyzed contained 125,000 observations spanning from June of 2016 to December of 2018. Observations were of individual messages, either ingoing and outgoing, and contained five variables: telephone number, date, time, message, and message type (incoming/outgoing). Since telephone numbers are traceable to individuals, we replace telephone numbers with random unique identifiers. There are a roughly equivalent number of incoming and outgoing messages, with 61,000 incoming messages and 63,000 outgoing.

| I.D.  | Date       | Times    | Type | Message          |
|-------|------------|----------|------|------------------|
| 14278 | 2017-04-01 | 08:11:21 | In   | 62267 2          |
| 14278 | 2017-04-01 | 08:12:17 | Out  | 4sar4: uurlerheg |
| 24056 | 2017-04-01 | 08:18:57 | In   | 23177 2          |
| 24056 | 2017-04-01 | 08:19:18 | Out  | 4sar4: uulerheg  |
| 50171 | 2017-04-01 | 08:36:27 | In   | 62131 1          |
| 50171 | 2017-04-01 | 08:37:25 | Out  | 4sar1: uulerheg  |

Fig 1: (above) Several lines of the de-identified, raw dataset.

Analysis:
---------

Our analysis of the LTS-2 dataset focused identifying and describing patterns in system usage over time and space. In addition to generally describing patterns in system usage, the following analysis looks at the characteristics of individual users, with some attention to user and system errors. Our analysis included mapping of spatial usage of the system over time using an interactive shiny dashboard. The shiny dashboard creates an interactive map that displays the number of requests from each area code. Users can filter the displayed requests by specify a time interval or request type.

In analyzing the ways the system is used, we focused on three major areas. First, characterizing the average user. Second, describing in general trends in system usage over time, and finally looking at the spatial distribution of usage.

*Individual Users:*

We began by characterizing the average user. In total, 11,520 different users requested information from the system between June 2016 and December. The majority of these users requested information relatively few times.

| Mean | Median | Min | Max |
|------|--------|-----|-----|
| 4.63 | 2      | 1   | 492 |

Table 1: (above) Descriptive statistics of the number of the distribution of times individual users requested information.

The above table shows the descriptive statistics of the distribution of the number of times individual users requested information. With a mean of 4.63 and median of 2, the distribution of the number of requests by individual users, suggesting that many of the system’s users stop using the system after a short time.

| Type of Request  | Number of Requests |
|------------------|--------------------|
| 1-3 Day Forecast | 36,188             |
| 4-6 Day Forecast | 14,628             |
| Pasture          | 1,349              |

Table 2: Total counts of requests for each of the three types of information offered by the LTS-2

Users seem mostly interested in weather information. Of the approximately 52,000 correctly formatted messages (messages that contain only a five-digit area code, and a request code between 1 and 3), about 36,000 were for 1-3 day weather forecasts and 14,000 were for 4-6 day weather forecasts. In comparison, only about 1300 requests for pasture information, suggesting that weather information is the main type of information users are interested in.

``` r
# load deidentified data

LTS_data <- read_csv("~/nomadic-herders/LTSdata/LTS_deidentified (1).csv")
```

    ## Warning: Missing column names filled in: 'X1' [1]

    ## Parsed with column specification:
    ## cols(
    ##   X1 = col_integer(),
    ##   id = col_integer(),
    ##   Date = col_date(format = ""),
    ##   Time = col_datetime(format = ""),
    ##   Type = col_character(),
    ##   Message = col_character()
    ## )

``` r
# wrangle data - get rid of unnecessary column

LTS_data <- LTS_data %>%
  select(-X1)

# create incoming messages dataframe
In <- LTS_data %>%
  filter(Type == "in")

# regexpression to pull out messages in correct/incorrect format
correct_exp <- "^[0-9]{5}\\s+[0-9]{1}$"


# create correct/incorrect column
In$correct <- grepl(correct_exp,In$Message)


# create area column for correct/incorrect
In <- In %>%
  mutate(area = str_extract(In$Message, "[0-9]{5}")) 

# Is the area code correct?

zip_data <- read_excel("~/nomadic-herders/LTSdata/Zip_extension_2016_2017.xlsx") %>% rename(`Zip code` = `Regional code`)
zip_data2 <- read_excel("~/nomadic-herders/LTSdata/Zip_extension_2017_2018.xlsx") %>%
  select("Sub-District", "Zip code", "Latitude", "Longitude") 
 

Zip_Data <- bind_rows(zip_data, zip_data2) %>%
  distinct(`Zip code`)

area_vector <- as.vector(Zip_Data$`Zip code`)

In <- In %>%
  mutate(area_correct = if_else(In$area %in% area_vector, 'real', 'fake')) %>% mutate(area_correct = if_else(is.na(In$area), 'fake', area_correct))

In %>% filter(area_correct == "real") %>%
  summarise(n = n())
```

    ## # A tibble: 1 x 1
    ##       n
    ##   <int>
    ## 1 56142

``` r
write.csv(In, file = "In.csv")

# separate message column into area code and request type - this probably only makes sense to do for correct messages
Correct <- In %>%
  filter(correct == "TRUE") %>%
  separate(Message, c("area", "request"), sep = ("(\\s{1,4}|\\.)"), extra = "drop")

write.csv(Correct, file = "Correct.csv")


# create 
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

![](Final_White_Paper_files/figure-markdown_github/unnamed-chunk-1-1.png)

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

Fig. 2: The distribution of number of area codes requested by individual users. Most users only requested information for a single area code.

The above bar plot shows the distribution of number of area codes for which individual users requested information. Most users only requested information for one area code (around 10,000). Number of area codes drops off significantly after that, with about 2,500 users requesting 2. It’s difficult to know whether this pattern is at all related to the geographical location of users, because many users only queried the system a single time; however, using the shiny dashboard mapping geographical usage, it’s possible to gain some insight into the spatial distribution of users.

``` r
bb <- In %>%
  mutate(Date = ymd(Date)) %>%
  mutate(Year = year(Date), month = month(Date)) %>%
  mutate(month = ifelse(nchar(as.character(month)) == 1, paste("0", sep = "", as.character(month)), as.character(month))) %>%
  mutate(year_month = paste(as.character(Year), "-", month)) 

pattern <- "^[0-9]{5}\\s+[0-9]{1}$"
bb <- bb %>%
  mutate(correct = grepl(pattern, Message))

# Plot proportion of incorrectly formatted messages over time
bb %>%
  mutate(Messages = ifelse(correct == TRUE & area_correct == "real", "Correct Format, Correct Area Code", 
                           ifelse(correct == TRUE & area_correct == "fake", "Incorrect Area Code, Correct Format", 
                                  ifelse(correct == FALSE & area_correct == "real", "Incorrect Format, Correct Area Code", "Incorrect Area Code, Incorrect Format")))) %>%
  group_by(year_month, Messages) %>%
  summarize(n = n()) %>%
  mutate(prop = n/sum(n)) %>%
  filter(Messages != "Correct Format, Correct Area Code") %>%
  ggplot(aes(year_month, prop, fill = Messages)) + geom_col() +
  theme(axis.text.x = element_text(angle = 40, hjust = 1)) +
  scale_fill_manual(values=c("tan1", "cadetblue4", "lightcoral")) +
  ggtitle("Proportion of Invalid Incoming Messages") +
  xlab("Year-Month") +
  ylab("Proportion") + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank())
```

![](Final_White_Paper_files/figure-markdown_github/unnamed-chunk-2-1.png)

Fig. 3: (above) Proportion of incorrectly formatted messages by type over time.

The graph above shows the proportions of invalid messages each month, which are caused by incorrectly formatting and/or area codes that do not correspond to actual places. We see an overall decreasing pattern in the total proportion of invalid requests. The proportion of messages with incorrect formatting does not change much over time, while the use of non-existing area codes in messages tends to decrease. Incorrect formatting appears to be the most common and consistent type of user errors.

Users were creative in their formatting of messages. Incorrect messages involved anything from requests for multiple types of information at a time or multiple area codes at a time, to entire sentences describing the information a user wanted. Given the relatively high proportion of incorrectly formatted messages over time, it may be helpful for the service to respond with formatting instructions to any unreadable messages. Currently, incorrectly formatted messages do not receive a response, so providing a response to incorrectly formatted messages may improve users’ interactions with the system.

``` r
LTS_yearmonth <-  LTS_data %>%
  mutate(Date = ymd(Date)) %>%
  mutate(Year = year(Date), month = month(Date)) %>%
  mutate(month = ifelse(nchar(as.character(month)) == 1, paste("0", sep = "", as.character(month)), as.character(month))) %>%
  mutate(year_month = paste(as.character(Year), "-", month)) 

p <- LTS_yearmonth %>%
  filter(Type == "in") %>%
  group_by(id) %>%
  summarize(n = n()) %>%
  filter(n == 1) %>%
  select(id)
pp <- as.vector(p$id)
LTS_yearmonth %>%
  mutate(only_once = id %in% pp) %>%
  group_by(year_month, only_once) %>%
  distinct(id)  %>%
  summarize(n = n()) %>%
  mutate(prop = n/sum(n)) %>%
  ggplot(aes(x = year_month, y = n, fill = only_once)) + geom_col()+
  theme(axis.text.x = element_text(angle = 40, hjust = 1)) +
  ggtitle("Distribution of Total Users Each Month") +
  xlab("Year-Month") +
  ylab("Number of Users") +
  labs(fill= "Used only once") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank())
```

![](Final_White_Paper_files/figure-markdown_github/unnamed-chunk-3-1.png)

The graph above shows the total number of users that texted into the system each month, along with the proportion of users that only ever text into the system once. Clearly, a significant portion of users text into the LTS-2 system and then never use it again. Any conclusion about seasonal usage is difficult given the newness of the LTS system, though the apparent trend seems to lower usage in the summer months (June, July, August, and September). Three months, in particular, stand out both as having the most number of users and a large proportion of one-time users: June, November, and December 2016.

Looking at the ways individual users queried the system, two trends stand out. The first is that most users used the system a small number of times. The second is that the number of users is inconsistent over time.

*General Patterns in Usage:*

To get a better understanding of the ways users enter and exit the system, and to understand aggregate usage patterns, we looked at spatio-temporal usage.

Since the dataset covers a relatively short period of time, we calculated monthly churn rates by dividing the number of users who used the system for the last time in a given month by the total number of users that month. The timeplot below shows this churn rate over time. Since we have no data for January 2018, December 2017 was excluded in the analysis.

``` r
# create graph of churn rate

total_use <- In %>%
  mutate(month = month(Date), year = year(Date)) %>%
  group_by(month, year) %>%
  distinct(id, .keep_all = TRUE) %>%
  summarise(total = n()) %>%
  arrange(year)
  

last_use <- In %>% 
  mutate(month = month(Date), year = year(Date)) %>%
  group_by(id) %>%
  arrange(month, year) %>%
  slice(n()) %>%
  ungroup() %>%
  group_by(month, year) %>%
  summarise(n = n()) %>%
  arrange(year)

left_join(last_use, total_use, by = c("year" = "year", "month" = "month")) %>%
  mutate(churn = n/total) %>% arrange(desc(churn))
```

    ## # A tibble: 19 x 5
    ## # Groups:   month [12]
    ##    month  year     n total churn
    ##    <dbl> <dbl> <int> <int> <dbl>
    ##  1 12.0   2017   435   435 1.00 
    ##  2 12.0   2016  2937  3047 0.964
    ##  3  6.00  2016  2731  3474 0.786
    ##  4 11.0   2016  1826  2387 0.765
    ##  5  9.00  2016   448   635 0.706
    ##  6  7.00  2016   686  1008 0.681
    ##  7  8.00  2016   392   611 0.642
    ##  8 10.0   2016   435   706 0.616
    ##  9 10.0   2017   449   761 0.590
    ## 10 11.0   2017   378   641 0.590
    ## 11  4.00  2017   487  1190 0.409
    ## 12  5.00  2017   326   838 0.389
    ## 13  9.00  2017   151   402 0.376
    ## 14  1.00  2017   539  1581 0.341
    ## 15  2.00  2017   350  1040 0.337
    ## 16  8.00  2017   124   375 0.331
    ## 17  6.00  2017   133   439 0.303
    ## 18  3.00  2017   314  1080 0.291
    ## 19  7.00  2017    98   348 0.282

``` r
a <- date("2016-12-01")
b <- date("2016-06-01")
e <- date("2017-07-01")
d <- date("2017-10-01")

left_join(last_use, total_use, by = c("year" = "year", "month" = "month")) %>%
  mutate(churn = n/total) %>%
  ungroup() %>%
  filter(!row_number() == n()) %>%
  mutate(date = make_date(year = year, month = month)) %>%
ggplot(aes(x = date, y = churn)) + geom_line() + labs(title = "Monthly Churn Rate June 2016 - November 2017", y = "Rate", x = "Month") + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(),  axis.line = element_line(colour = "black")) + annotate("text", x = a, y = 1, label = c("December")) +
  annotate("text", x = b, y = 0.82, label = c("June")) + annotate("text", x = e, y = 0.33, label = c("July")) +
annotate("text", x = d, y = 0.62, label = c("November"))
```

![](Final_White_Paper_files/figure-markdown_github/unnamed-chunk-4-1.png)

The system’s churn rate was relatively high, indicating that people are constantly entering and exiting the system. 2016 had consistently high churn rates, with a range between 60% and 80% between June and November of 2016, peaking in December at 96%, which was the highest churn rate throughout the year. Relative to 2016, 2017 saw low churn rates, with a range from 28% in July to 59% in October.

``` r
Out <- read_csv("~/nomadic-herders/data/out_LTS_data.csv")
```

    ## Warning: Missing column names filled in: 'X1' [1]

    ## Parsed with column specification:
    ## cols(
    ##   X1 = col_integer(),
    ##   id = col_integer(),
    ##   Date = col_date(format = ""),
    ##   Time = col_datetime(format = ""),
    ##   Type = col_character(),
    ##   Message = col_character(),
    ##   info_type = col_character(),
    ##   weather = col_character(),
    ##   weather_eng = col_character()
    ## )

``` r
Out %>% mutate(month = month(Date), year = year(Date)) %>%
  filter(!is.na(weather_eng)) %>%
  group_by(month, year, weather_eng) %>%
  summarise(n = n()) %>%
  ungroup() %>%
  mutate(date = make_date(year = year, month = month)) %>%
  ggplot(aes(x = date, y = n, fill = weather_eng)) + geom_col() +
  labs(title = "Outgoing Messages by Weather Type", x = "Month", y ="Messages", fill = "Weather Type") 
```

![](Final_White_Paper_files/figure-markdown_github/unnamed-chunk-5-1.png)

The above plot shows shows the distribution of weather types in outgoing forecasts by month. This graph uses the type weather forecasted - clouds, rain, snow, or sun - as an indicator of Mongolian weather patterns during a given month. While this provides only a rough sense of actual weather patterns, there does appear to noticeable seasonal patterns in types of weather forecasts, with snow forecasted in late fall into winter and early spring, and rain in spring/summer. Usage patterns appear to rise and fall with the appearance of snow, increasing in winter and dipping in summer. June 2016 has relatively high usage, though, is likely an outlier because the system started operation that month.

``` r
# graph number of new users over time
new_users <- bb %>%
  group_by(id) %>%
  summarize(min = min(Date)) %>%
  mutate(Year = year(min), month = month(min)) %>%
  mutate(month = ifelse(nchar(as.character(month)) == 1, paste("0", sep = "", as.character(month)), as.character(month))) %>%
  mutate(year_month = paste(as.character(Year), "-", month))%>%
  group_by(year_month) %>%
  summarize(n = n()) 
new_users %>%
  ggplot(aes(x = year_month, y = n)) + geom_col() +
  theme(axis.text.x = element_text(angle = 40, hjust = 1)) +
  ggtitle("Number of New Users Each Month") +
  xlab("Year-Month") +
  ylab("Number of New Users") +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank())
```

![](Final_White_Paper_files/figure-markdown_github/unnamed-chunk-6-1.png)

Mirroring the above graph of new users per month above (fig \#), the number of requests for information directed at the service decreased over time, again with a slight uptick around late fall and winter. The number of messages per month shows a more substantial drop in usage around summer time than number of new users. Still, the plots seem to map fairly well onto each other, as well as onto the above plot of the total number of users per month over time (fig \#). From this we conclude that there may be a trend in usage over time, but the time frame is too short to determine what processes might be behind that trend.

``` r
# graph number of requests each month
bb %>%
  group_by(year_month) %>%
  summarize(n = n()) %>%
  ggplot(aes(x = year_month, y = n)) + geom_col() +
  theme(axis.text.x = element_text(angle = 40, hjust = 1)) +
  ggtitle("Number of Requests Each Month") +
  xlab("Year-Month") +
  ylab("Number of Requests") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank())
```

![](Final_White_Paper_files/figure-markdown_github/unnamed-chunk-7-1.png)

Mirroring the above graph of new users per month above (fig \#), the number of requests for information directed at the service decreased over time, again with a slight uptick around late fall and winter. The number of messages per month shows a more substantial drop in usage around summer time than number of new users. Still, the plots seem to map fairly well onto each other, as well as onto the above plot of the total number of users per month over time (fig \#). From this we conclude that there may be a trend in usage over time, but the time frame is too short to determine what processes might be behind that trend.

We expected to see a seasonal cycle in the usage of the LTS-2 system due to the seasonal nature of nomadic herding. The LTS-2 system experienced a usage spike during the winter of 2016. However, while there was also an uptick in requests during the winter of 2017, it was of a significantly smaller magnitude. Our plot of requests per month (fig \#) and number of users per month (fig \#) above shows that usage during the summer months seems fairly consistent, and low from 2016 to 2017. Though it's difficult to discern whether there is a seasonal pattern in usage, there does appear to be a some relationship between snow and number of requests. Our weather analysis relied on the forecast information contained within the LTS outgoing messages, so we were only able look at weather patterns at low-resolution. Snow may be a proxy for cold weather, so future analysis should look at the effects of storms versus cold weather on system usage.