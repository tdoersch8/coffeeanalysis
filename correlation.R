##### Coffee Project Code: Correlation ####

#Load necessary libraries
library(corrplot)
library(ggplot2)

#Load the data
aesthetics <- read.csv("data/aesthetics_dataset.csv")

#Create correlation matrix
cor_matrix <- cor(aesthetics, use = "complete.obs")

#View correlation matrix
round(cor_matrix, 2)

#Create figures folder, if it doesn't already exist
if (!dir.exists("figures")) {
  dir.create("figures")
}

#Open PNG device
png("figures/correlation_plot.png", width = 800, height = 600)

#Force new plot and set margins
par(oma = c(0, 0, 3, 0), mar = c(1, 1, 1, 1))

#Plot
corrplot(cor_matrix, 
         method = "color", 
         type = "upper", 
         tl.col = "black", 
         tl.srt = 45,
         addCoef.col = "black",    
         number.cex = 0.8)

#Add title
mtext("Correlation Matrix", outer = TRUE, cex = 1.5, line = 1)

#Close device
dev.off()
