library(dplyr)

library(readr)
lyrics = read_csv("data/lyrics.csv")


# Column 'release_date' has problems. Extracting year

library(stringr)
get_release_year = function(vector) {
  if (length(vector) < 20) {
    year = str_extract(vector, "\\d{4}")
    return(year)  
  } else {
    return(NA)  
  }
}
lyrics$release_year = sapply(lyrics$release_date, get_release_year)



# Genre e bigram count Analysis

library(tidyverse)
library(tidytext)
library(tm)

lyrics_bigrams = lyrics %>%
  unnest_tokens(bigram, lyrics, token = "ngrams", n = 2)

pronouns = c("he", "she")
stopwords = stopwords("english")

bigram_counts = lyrics_bigrams %>%
  count(bigram, sort = TRUE) %>%
  separate(bigram, c("pronoun", "around"), sep = " ") %>%
  filter(! around %in% stopwords)

bigram_counts_he_she = lyrics_bigrams %>%
  count(bigram, sort = TRUE) %>%
  separate(bigram, c("pronoun", "around"), sep = " ") %>%
  filter((pronoun %in% pronouns & ! around %in% stopwords))



# Most important words in albuns and tracks

lyrics$n_words = str_count(lyrics$lyrics,'\\w+')
lyrics$index = rownames(lyrics)

lyrics_album_words = lyrics %>%
  unnest_tokens(word, lyrics) %>%
  count(album, word, sort = TRUE) %>%
  ungroup() %>%
  filter(! word %in% stopwords)

lyrics_album_total_words = lyrics_album_words %>% group_by(album) %>% summarize(total = sum(n))
lyrics_album_words = left_join(lyrics_album_words, lyrics_album_total_words)

lyrics_tdidf_album = lyrics_album_words  %>%
  bind_tf_idf(word, album, n) %>%
  select(-total) %>%
  arrange(desc(tf_idf)) 

lyrics_song_words = lyrics %>%
  unnest_tokens(word, lyrics) %>%
  count(song, word, sort = TRUE) %>%
  ungroup() %>%
  filter(! word %in% stopwords)

lyrics_song_total_words = lyrics_song_words %>% group_by(song) %>% summarize(total = sum(n))
lyrics_song_words = left_join(lyrics_song_words, lyrics_song_total_words)

lyrics_tdidf_song = lyrics_song_words %>%
  bind_tf_idf(word, song, n) %>%
  select(-total) %>%
  arrange(desc(tf_idf))