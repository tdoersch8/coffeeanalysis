# Coffee Project Code

library(lubridate)
library(dplyr)
library(stringr)
library(tidyverse)

robusta <- read_csv("work/robusta_data_cleaned.csv")
arabica <- read_csv("work/arabica_data_cleaned.csv")

robusta %>% names()
view(robusta)

arabica %>% names()
view(arabica)

lapply(robusta, function(col) sort(table(col), decreasing = TRUE))
lapply(arabica, function(col) sort(table(col), decreasing = TRUE))

arrange(tally(group_by(robusta, Farm.Name)),n)

simplify_strings <- function(s){
  s <- str_to_lower(s);
  s <- str_trim(s);
  s
}

robusta_simplify <- robusta %>%
  mutate_if(is.character, simplify_strings)

arabica_simplify <- arabica %>%
  mutate_if(is.character, simplify_strings)

simplify_strings2 <- function(s) {
  s <- str_to_lower(s)  
  s <- str_trim(s)      
  s <- str_replace_all(s, "[^a-z]+", "_")  
  s <- str_replace(s, "_$", "")  # Remove trailing underscore
  
  # If the result is blank, replace it with "id" (vectorized)
  s <- ifelse(s == "" | is.na(s), "id", s)
  
  return(s)
}

names(robusta_simplify) <- simplify_strings2(names(robusta_simplify))
names(arabica_simplify) <- simplify_strings2(names(arabica_simplify))
