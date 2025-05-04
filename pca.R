##### Coffee Project Code: PCA ####

#Load necessary libraries
library(ggplot2)

#Load data
aesthetics <- read.csv("data/aesthetics_dataset.csv")
species <- read.csv("data/species_dataset.csv")

#Initial plot
plot(aesthetics)

#PCA
pca_results <- prcomp(aesthetics)

#Summarize results
summary(pca_results)

#Plot results
plot(pca_results$x)

#Plot results by species
ggplot(pca_results$x) + geom_point(aes(x=PC1,y=PC2,color=species$species))  

#Final plot
pca_plot <- ggplot(pca_results$x, aes(x = PC1, y = PC2)) +
  geom_point() +
  facet_wrap(~ species$species) +
  ggtitle("PCA plot by species")

#Print the plot
print(pca_plot)

#Create figures folder, if it doesn't already exist
if (!dir.exists("figures")) {
  dir.create("figures")
}

#Save the plot as a PNG file
ggsave("figures/pca_plot.png", plot = pca_plot, width = 8, height = 6)
