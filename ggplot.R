##### Coffee Project Code: GGPlot ####

#Load required libraries
library(tidyverse)
library(tidyr)

#Read in the data
coffee_data <- read.csv("data/species_dataset.csv")
full <- read.csv("data/final_dataset.csv")

#Pivot the data longer to have characteristic and value
long_coffee <- coffee_data %>%
  pivot_longer(cols = aroma:overall, 
               names_to = "characteristic", values_to = "value") %>%
  drop_na(species, value)

#Normalize numeric values within each characteristic
long_coffee <- long_coffee %>%
  group_by(species, characteristic) %>%
  mutate(scaled_value = scale(value)) %>%
  ungroup()

#Compute average value by species and characteristic
avg_values <- long_coffee %>%
  group_by(species, characteristic) %>%
  summarize(mean_value = mean(scaled_value), .groups = "drop")

#Rank characteristics within each species
ranked_species <- avg_values %>%
  group_by(species) %>%
  arrange(desc(mean_value)) %>%
  mutate(rank = row_number()) %>%
  filter(rank <= 10) %>%
  ungroup()

#Order characteristics by average rank for better plotting
char_order <- ranked_species %>%
  group_by(characteristic) %>%
  summarize(avg_rank = mean(rank)) %>%
  arrange(avg_rank) %>%
  pull(characteristic)

ranked_species$characteristic <- factor(ranked_species$characteristic, 
                                        levels = char_order)

#Assign numeric x-position
species_to_x <- function(s) {
  x <- c("arabica" = -1, "robusta" = 1)
  x[s]
}

#Create connection data between species
arabica <- ranked_species %>% filter(species == "arabica") %>% 
  rename(arabica_rank = rank)
robusta <- ranked_species %>% filter(species == "robusta") %>% 
  rename(robusta_rank = rank)

line_data <- full_join(arabica, robusta, by = "characteristic") %>%
  mutate(arabica_rank = replace_na(arabica_rank, 11),
         robusta_rank = replace_na(robusta_rank, 11))

#Create figures folder, if it doesn't already exist
if (!dir.exists("work/figures")) {
  dir.create("work/figures")
}

#Final plot
ggplot(ranked_species) +
  geom_rect(aes(xmin = species_to_x(species) - 0.5,
                xmax = species_to_x(species) + 0.5,
                ymin = rank - 0.45,
                ymax = rank + 0.45,
                fill = characteristic),
            show.legend = FALSE) +
  geom_text(aes(x = species_to_x(species),
                y = rank,
                label = characteristic),
            size = 3) +
  geom_segment(data = line_data, aes(x = -0.5, xend = 0.5,
                                     y = arabica_rank,
                                     yend = robusta_rank,
                                     color = characteristic),
               show.legend = FALSE) +
  ylim(0, 21) +
  scale_y_reverse(breaks = 1:20) +
  scale_x_continuous(breaks = c(-1, 1),
                     labels = c("Arabica", "Robusta")) + 
  labs(x = "Species", y = "Rank",
       title = "Are coffee characteristics distributed differently by species?")

#Save plot to figures folder
ggsave("figures/coffee_characteristics_alignment_plot.png", width = 10, 
       height = 8, dpi = 300)

#Plot country by species
ggplot(full, aes(x = country, fill = species)) +
  geom_bar(position = "dodge") +
  labs(title = "Country of origin by species", x = "Country", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#Save plot to figures folder
ggsave("figures/country_plot.png", width = 10, 
       height = 8, dpi = 300)

#Plot altitude by species
ggplot(full, aes(x = mean_altitude, fill = species)) +
  geom_density(alpha = 0.5) +
  labs(title = "Altitude density by species",
       x = "Mean Altitude (m)", y = "Density") +
  theme_minimal()

#Save plot to figures folder
ggsave("figures/altitude_plot.png", width = 10, 
       height = 8, dpi = 300)

#Plot total score by species
ggplot(full, aes(x = total, fill = species)) +
  geom_density(alpha = 0.5) +
  labs(title = "Total score by species",
       x = "Score out of 100", y = "Density") +
  theme_minimal()

#Save plot to figures folder
ggsave("figures/total_plot.png", width = 10, 
       height = 8, dpi = 300)

#Boxplot comparing weights produced by species
ggplot(full, aes(x = species, y = total_weight, fill = species)) +
  geom_boxplot() +
  scale_y_log10() +
  labs(title = "Log-scaled total weight by species",
       x = "Species", y = "Log10(total weight in kg)") +
  theme_minimal()

#Save plot to figures folder
ggsave("figures/weight_plot.png", width = 10, 
       height = 8, dpi = 300)
