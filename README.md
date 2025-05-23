## Data

I am using coffee quality data from the Coffee Quality Institute's (CQI) database. Both Arabica and Robusta coffees were reviewed by CQI's trained reviewers. I edited web scraping code from [Fatih Boyar](https://github.com/fatih-boyar), who referenced code from [James LeDoux](https://github.com/jldbc). I used the web scraping code to retrieve all of the most recent reviews present on the [Coffee Quality Institute](https://www.coffeeinstitute.org) database. See the [codebook](https://github.com/tdoersch8/coffeeanalysis/blob/main/codebook.csv) for a description of variables.

## Analysis

The code provided does the following tasks:

- Cleans the data
- Explores differences between Arabica and Robusta coffees using key characteristics via ggplot
- Visualizes the distribution of aesthetic variables between species
- Conducts Principal Component Analysis (PCA) for dimensionality reduction
-	Creates a correlation matrix for aesthetic variables to examine relationships
-	Performs t-SNE clustering
-	Builds and trains a generalized linear model (GLM) for species classification
-	Evaluates the model using an ROC curve

## Usage

You will need access to Docker. Follow these steps to use the provided code:

### 1. Clone the Repository

Using your terminal in Docker, run the following commands:

```bash
git clone https://github.com/tdoersch8/coffeeanalysis
cd coffeeanalysis
```

This will clone the GitHub repository and move into the project directory.

### 2. Build the Docker Image

Using your terminal in Docker, run the following command to start the Docker container:

```bash
./start.sh
```

### 3. Go to Rstudio Server

You can now open your browser and go to:

```bash
http://localhost:8787
```

Log in using the credentials set in your Dockerfile (username: rstudio, password: yourpassword).

### 4. Rendering the report

Using your terminal in Rstudio, run the following code:

```bash
make clean
make report.pdf
```








