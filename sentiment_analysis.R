suppressPackageStartupMessages({
library(sentimentr)
library(tidytext)
library(lubridate)
library(readr)
library(dplyr)
library(tidyr)
library(argparse)
library(ggpubr)
})

load_data<-function(filename) {
raw_data <- read_csv(filename, col_types = cols(id = col_character()))
#makes id a character not a string
clean_data <- raw_data %>%
  filter(language == "en") %>%
  #only display English toots
  select(id, created_at, sensitive, visibility, language,
         replies_count, reblogs_count, favourites_count, content) %>%
  mutate(content = gsub("<[^>]+>", "", content))
  #updates content column, removes HTML resembling tags
  glimpse(clean_data)
    return(clean_data)
}

word_analysis<-function(toot_data, emotion) {
  word_data <- toot_data %>%
    unnest_tokens(word, content)
  #break down sentences into words
  nrc_sentiment <- get_sentiments("nrc") %>%
    filter(sentiment == emotion)
  #filters desired emotion from words
  clean_table <- word_data %>%
    inner_join(nrc_sentiment, by = "word") %>%
    #compares sentiment to words
    count(id, sentiment, created_at, word, sort = TRUE) %>%
    head(10)
    return(clean_table)
}


sentiment_analysis <- function(toot_data) {
  word_data <- toot_data %>%
    unnest_tokens(word, content)
   afinn_sentiment <- get_sentiments("afinn") %>%
    inner_join(word_data, by = "word") %>%
    mutate(sentiment = as.character(value), method = "afinn") %>%
    select(id, created_at, sentiment, method)
  #mutate changes numerical values of afinn sentiment into words
  nrc_sentiment <- get_sentiments("nrc") %>%
    inner_join(word_data, by = "word", relationship = "many-to-many") %>%
    mutate(method = "nrc") %>%
    select(id, created_at, sentiment, method)
  #mutate adds a method column i.e. which lexion is doing the analysis
  bing_sentiment <- get_sentiments("bing") %>%
    inner_join(word_data, by = "word") %>%
    mutate(method = "bing") %>%
    select(id, created_at, sentiment, method)
  merged_sentiment <- bind_rows(afinn_sentiment, nrc_sentiment, bing_sentiment)
   return(merged_sentiment)
  }


#to make it fancy can add a choice asking which library to make the graph with

main <- function(args) {
  clean_data <- load_data(args$filename)
  sentiment_data <- sentiment_analysis(clean_data)
  print(sentiment_data)
  plot_data <- sentiment_data %>%
  filter(!is.na(sentiment)) %>%
    count(method, sentiment)
  sentiment_plot <- ggbarplot(
    plot_data,
    x = "sentiment",
    y = "n",
    facet.by = "method",
    scales = "free",
    fill = "method",
    title = "Sentiment analysis results"
  )
  output_filename <- if (!is.null(args$plot)) args$plot else args$output
  if (!is.null(output_filename)) {
    ggexport(sentiment_plot, filename = output_filename)
  }
  return(sentiment_data)
}


if(sys.nframe() == 0) {

  # main program, called via Rscript
  parser = ArgumentParser(
                    prog="Sentiment Analysis",
                    description="Analyse toots for word and sentence sentiments"
                    )
  parser$add_argument("filename",
                    help="the file to read the toots from")
  parser$add_argument("--emotion",
                      default="anger",
                      help="which emotion to search for")
  parser$add_argument('-v', '--verbose',
                    action='store_true',
                    help="Print progress")
  parser$add_argument('-p', '--plot',
                    help="Plot something. Give the filename")
  
  args = parser$parse_args()  
  main(args)
}
