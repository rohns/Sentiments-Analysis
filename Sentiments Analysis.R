---
  title: "Sentiment Analysis "
output:
  pdf_document: default
html_notebook: default
word_document: default
---
  
  
```{r, echo=FALSE, message=FALSE}
library(dplyr) # for data wrangling & manipulation
library(tidytext) # for unnest_tokens
library(stringr) # to manage text
library(ggplot2) # For data visualizations & graphs

#read the data file
articles <- read.csv("articles.csv")
#clean the data - remove unwanted variables fields
df_art <- subset(articles, select = -c(X))

#dropping entries with missing values
df_art<- na.omit(df_art)

#add date column
df<- df_art%>%
  mutate(published_date = format (as.Date(publication_date, format= "%d-%b-%y"), "%B-%Y"))
#load stop words data
#data("stop_words")
```

## Article Titles
The analysis shows that among the most popular words used in article titles are: COVID-19, SARS, 2020, and United States. The top 10 commonly used words and the number of times they appeared on the article titles are shown below. 
```{r, echo=FALSE, message=FALSE, warning=FALSE}
#art_title
title <- data_frame(text = df$art_title) %>%
  unnest_tokens(word, text) %>%    # split words
  anti_join(stop_words) %>%    # take out "a", "an", "the", etc.
  count(word, sort = TRUE)    # count occurrences

head(title, 10)
title %>% filter(n > 30)%>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col(fill = "darkred") + theme_classic() +
  xlab(NULL) +
  ylab("Word Count") +
  coord_flip() +
  ggtitle(" Frequently Used Words in Article Title")
```

## What is Known
The variable represent further information about the titles. Analysis of the variable shows that similar words are used like in the headlines. COVID, SARS, health, and transmission are some of th most commonly used terms. A list of top 10 words is shown below accompanied with a visualization of the commonly used words with more than 30 entries.
```{r,  echo=FALSE, message=FALSE}
#what_is_known
known <- data_frame(text = df$what_is_known) %>% 
  unnest_tokens(word, text) %>%    # split words
  anti_join(stop_words) %>%    # take out "a", "an", "the", etc.
  count(word, sort = TRUE)    # count occurrences


head(known,10)
known%>% filter(n > 30)%>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col(fill = "darkred") + theme_classic() +
  xlab(NULL) +
  ylab("Word Count") +
  coord_flip() +
  ggtitle("Frequently Used Words in Known information")
```

## What is Added
Additional information included in the articles was analyzed to determine how it impacted the audience. Sentiment analysis shows that most of the terms used affected the readers negatively. Below is a list of words and how they could have affected the audience. The analysis shows more negative sentiments than positive.
```{r,  echo=FALSE, message=FALSE}

#what_is_added
added <- data_frame(text = df$what_is_added) %>% 
  unnest_tokens(word, text) %>%    # split words
  anti_join(stop_words) %>%    # take out "a", "an", "the", etc.
  count(word, sort = TRUE)    # count occurrences


added_bing <- added %>%
  inner_join(get_sentiments("bing"))

head(added_bing, 10)

added_bing %>%
  filter(n > 10) %>%
  mutate(n = ifelse(sentiment == "negative", -n, n)) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill=sentiment)) +
  theme_classic() +
  geom_col() +
  xlab(NULL) +
  coord_flip() +
  ylab("Contribution to sentiment") +
  ggtitle("Word Usage in Added Information", subtitle = "Sentiment Analysis Using
Bing et al.")
```

## Implications
Similarly, sentiments analysis is used to further determine effects of the information on the audience and healthcare sector. The analysis shows more negative effects than positive. The visualization shows the sentiments from the implications variable.
```{r,  echo=FALSE, message=FALSE}
#Implication
implication <- data_frame(text = df$implications) %>% 
  unnest_tokens(word, text) %>%    # split words
  anti_join(stop_words) %>%    # take out "a", "an", "the", etc.
  count(word, sort = TRUE)    # count occurrences


implication_bing <- implication %>%
  inner_join(get_sentiments("bing"))


head(implication_bing, 10)
implication_bing %>%
  filter(n > 10) %>%
  mutate(n = ifelse(sentiment == "negative", -n, n)) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill=sentiment)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() +
  ylab("Contribution to sentiment") +
  ggtitle("Word Usage in Implications", subtitle = "Sentiment Analysis Using
Bing et al.")

```

## Publication Dates
We analyzed the publications dates by determining the number of publication done in each month. April 2021 had the most publications followed by October 2020. The publication date data is visualized below for clear understanding of the differences in number of articles published between 2020 and 2021.

```{r,  echo=FALSE, message=FALSE}
library(lubridate)

dates <- df %>%
  group_by(published_date) %>%
  count()%>%
  arrange(desc(n))



head(dates, 10)   
dates %>%
  ggplot(aes(published_date, n, fill = n)) +
  theme_classic()+
  geom_col() +
  xlab("Date of publication") +
  coord_flip() +
  ylab("Number of publications") +
  ggtitle("Dates of Publication and Number of Publications")
```