##### Coffee Project Code: Classification ####

#Load necessary libraries
library(tidyverse)
library(caret)
library(pROC)

#Load the data
species <- read.csv("data/species_dataset.csv")

#Prepare the label: Convert species to binary (e.g., robusta = 0, arabica = 1)
species2 <- species %>%
  mutate(label = ifelse(species == "arabica", 1, 0)) %>%
  select(-species)

#Set a seed for reproducibility
set.seed(42)

#Train-test split (80% train, 20% test)
trainIndex <- createDataPartition(species2$label, p = 0.8, list = FALSE)
trainData <- species2[trainIndex, ]
testData <- species2[-trainIndex, ]

#Create balanced version of your training data
train_bal <- downSample(x = trainData[, -which(names(trainData) == "label")],
                        y = as.factor(trainData$label), yname = "label")

#Keep these variables in model, do not have near perfect prediction
table(train_bal$label, train_bal$aroma)
table(train_bal$label, train_bal$flavor)
table(train_bal$label, train_bal$aftertaste)
table(train_bal$label, train_bal$acidity)
table(train_bal$label, train_bal$balance)
table(train_bal$label, train_bal$overall)
table(train_bal$label, train_bal$body)

#Remove these variables from model, have near perfect prediction
table(train_bal$label, train_bal$sweetness)
table(train_bal$label, train_bal$uniformity)
table(train_bal$label, train_bal$clean)

#Train the logistic regression model using the balanced data set
model <- glm(label ~ aroma + flavor + aftertaste + acidity + body + 
               balance + overall, data = train_bal, family = binomial)

#Make predictions on the test set (use the original test set)
predictions <- predict(model, testData, type = "response")

#Convert predictions to binary outcomes (threshold of 0.5)
predicted_class <- ifelse(predictions > 0.5, 1, 0)

#Generate the ROC curve
roc_curve <- roc(testData$label, predictions)

roc_plot <- ggroc(roc_curve) +
  ggtitle("ROC Curve") +
  xlab("1 - Specificity") +
  ylab("Sensitivity")

#Create figures folder, if it doesn't already exist
if (!dir.exists("figures")) {
  dir.create("figures")
}

#Save the ROC curve plot explicitly as a PNG
ggsave("figures/roc_curve.png", plot = roc_plot, device = "png")

#Calculate the AUC
auc_value <- auc(roc_curve)

#Create data folder, if it doesn't already exist
if (!dir.exists("data")) {
  dir.create("data")
}

#Print and save the AUC value to an RMarkdown file
cat(sprintf("The AUC is %0.2f.", auc_value), file = "data/auc.Rmd")