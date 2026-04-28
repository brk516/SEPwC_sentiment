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
    return(clean_data)
}

word_analysis<-function(toot_data, emotion) {

    return()
}

sentiment_analysis<-function(toot_data) {

    return()

}

main <- function(args) {
#look at formative for guidance
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
