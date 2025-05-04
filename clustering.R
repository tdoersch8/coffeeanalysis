##### Coffee Project Code: Clustering ####

#Load libraries
library(Rtsne)
library(ggplot2)

#Load data
species <- read.csv("data/species_dataset.csv")

#Select relevant variables
quality_vars <- c("aroma", "flavor", "aftertaste", 
                  "acidity", "sweetness", "body", 
                  "uniformity", "clean", "balance", 
                  "overall")

#Subset and clean
species_subset <- species[, c("species", quality_vars)]
species_clean <- na.omit(species_subset)
species_clean <- species_clean[!duplicated(species_clean[, quality_vars]), ]

#Store species info
species_info <- species_clean$species

#Scale data
scaled_data <- scale(species_clean[, quality_vars])

#K-means clustering (2 clusters)
set.seed(123)
kmeans_result <- kmeans(scaled_data, centers = 2, nstart = 25)

set.seed(123)
tsne_result <- Rtsne(scaled_data, dims = 2, perplexity = 30, verbose = TRUE)

tsne_df <- data.frame(tsne_result$Y)
tsne_df$cluster <- as.factor(kmeans_result$cluster)
tsne_df$species <- species_info

#Create figures folder, if it doesn't already exist
if (!dir.exists("figures")) {
  dir.create("figures")
}

#Plot 2 clusters
ggplot(tsne_df, aes(x = X1, y = X2, color = cluster, shape = species)) +
  geom_point(size = 2, alpha = 0.7) +
  labs(title = "t-SNE Visualization of Coffee Samples (2 Clusters)", 
       x = "t-SNE 1", y = "t-SNE 2") +
  theme_minimal()

#Save plot
ggsave("figures/tsne_clusters_2.png", width = 8, height = 6, dpi = 300)

#K-means clustering (3 clusters)
set.seed(123)
kmeans_result <- kmeans(scaled_data, centers = 3, nstart = 25)

set.seed(123)
tsne_result <- Rtsne(scaled_data, dims = 2, perplexity = 30, verbose = TRUE)

tsne_df <- data.frame(tsne_result$Y)
tsne_df$cluster <- as.factor(kmeans_result$cluster)
tsne_df$species <- species_info

#Plot 3 clusters
ggplot(tsne_df, aes(x = X1, y = X2, color = cluster, shape = species)) +
  geom_point(size = 2, alpha = 0.7) +
  labs(title = "t-SNE Visualization of Coffee Samples (3 Clusters)", 
       x = "t-SNE 1", y = "t-SNE 2") +
  theme_minimal()

#Save plot
ggsave("figures/tsne_clusters_3.png", width = 8, height = 6, dpi = 300)
