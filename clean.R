##### Coffee Project Code: Clean ####

#Load required libraries
library(lubridate)
library(dplyr)
library(stringr)
library(tidyverse)

# Load Robusta data
robusta <- read.csv("df_1_robusta.csv") %>% 
  rename(
    Aroma = Fragrance...Aroma,
    Acidity = Salt...Acid,
    Uniformity = Uniform.Cup,
    Sweetness = Bitter...Sweet,
    Body = Mouthfeel,
    Clean = Clean.Cup,
    Country = Country.of.Origin,
    Total = Total.Cup.Points
  )

# Load Arabica data
arabica <- read.csv("df_1_arabica.csv") %>% 
  rename(
    Clean = Clean.Cup,
    Country = Country.of.Origin,
    Total = Total.Cup.Points
  )

#View data
robusta %>% names()
view(robusta)

arabica %>% names()
view(arabica)

lapply(robusta, function(col) sort(table(col), decreasing = TRUE))

lapply(arabica, function(col) sort(table(col), decreasing = TRUE))

#Simplify strings
simplify_strings <- function(s){
  s <- str_to_lower(s);
  s <- str_trim(s);
  s
}

robusta_simplify <- robusta %>%
  mutate_if(is.character, simplify_strings)

arabica_simplify <- arabica %>%
  mutate_if(is.character, simplify_strings)

#Simplify variable names
simplify_variablenames <- function(s) {
  s <- str_to_lower(s)  
  s <- str_trim(s)      
  s <- str_replace_all(s, "[^a-z]+", "_")  
  s <- str_replace(s, "_$", "")  # Remove trailing underscore
  
  # If the result is blank, replace it with "id" (vectorized)
  s <- ifelse(s == "" | is.na(s), "id", s)
  
  return(s)
}

names(robusta_simplify) <- simplify_variablenames(names(robusta_simplify))

names(arabica_simplify) <- simplify_variablenames(names(arabica_simplify))

#Select desired variables
robusta2 <- robusta_simplify %>%
  select(species,country,number_of_bags,bag_weight,altitude,
         aroma:moisture) %>% select(-defects)

arabica2 <- arabica_simplify %>%
  select(species,country,number_of_bags,bag_weight,altitude,
         aroma:moisture) %>% select(-defects)

#Check if total is sum of individual asthetic rankings, and remove if not
arabica_check <- arabica2 %>%
  rowwise() %>%
  mutate(
    calculated_total = round(sum(c_across(aroma:overall), 
                                 na.rm = TRUE), 2), match_check = 
      abs(round(total, 2) - calculated_total) <= 0.02) %>% ungroup()

arabica_check %>% filter(!match_check)

arabica3 <- arabica_check %>% 
  filter(match_check) %>%
  select(-match_check, -calculated_total)

robusta_check <- robusta2 %>%
  rowwise() %>%
  mutate(
    calculated_total = round(sum(c_across(aroma:overall), 
                                 na.rm = TRUE), 2), match_check = 
      abs(round(total, 2) - calculated_total) <= 0.02) %>% ungroup()

robusta_check %>% filter(!match_check)

robusta3 <- robusta_check %>% 
  filter(match_check) %>%
  select(-match_check, -calculated_total)

# Convert moisture % to proportion in both data sets
robusta4 <- robusta3 %>%
  mutate(moisture = parse_number(moisture) / 100)

arabica4 <- arabica3 %>%
  mutate(moisture = parse_number(moisture) / 100)

#Check all bag weights are in kg and multiply by number of bags to get total kg
arabica_check2 <- arabica4 %>%
  mutate(is_kg = str_detect(bag_weight, "kg"))

arabica_check2 %>% filter(!is_kg)

robusta_check2 <- robusta4 %>%
  mutate(is_kg = str_detect(bag_weight, "kg"))

robusta_check2 %>% filter(!is_kg)

arabica5 <- arabica_check2 %>%
  mutate(
    weight_kg = as.numeric(str_extract(bag_weight, "\\d+\\.*\\d*")),
    total_weight = weight_kg * number_of_bags
  ) %>% select(-weight_kg,-number_of_bags,-bag_weight,-is_kg)

robusta5 <- robusta_check2 %>%
  mutate(
    weight_kg = as.numeric(str_extract(bag_weight, "\\d+\\.*\\d*")),
    total_weight = weight_kg * number_of_bags
  ) %>% select(-weight_kg,-number_of_bags,-bag_weight,-is_kg)

#Calculate mean altitude
arabica6 <- arabica5 %>%
  mutate(
    mean_altitude = str_extract_all(altitude, "\\d+") %>%
      lapply(function(x) round(mean(as.numeric(x)), 0)) %>%
      unlist() %>%
      as.numeric()  # Ensure the result is numeric
  ) %>%
  select(-altitude)

robusta6 <- robusta5 %>%
  mutate(
    mean_altitude = str_extract_all(altitude, "\\d+") %>%
      lapply(function(x) round(mean(as.numeric(x)), 1)) %>%
      unlist()
  ) %>%
  select(-altitude)

# Combine the datasets
final <- rbind(robusta6, arabica6)

species <- rbind(robusta6, arabica6) %>% 
  select(species,aroma:overall)

aesthetics <- rbind(robusta6, arabica6) %>% 
  select(aroma:overall)

#Create data folder, if it doesn't already exist
if (!dir.exists("data")) {
  dir.create("data")
}

# Save the 'final' data set
write.csv(final, "data/final_dataset.csv", row.names = FALSE)

# Save the 'species' data set
write.csv(species, "data/species_dataset.csv", row.names = FALSE)

# Save the 'aesthetics' data set
write.csv(aesthetics, "data/aesthetics_dataset.csv", row.names = FALSE)
         