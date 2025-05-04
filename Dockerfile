FROM rocker/verse

RUN R -e "install.packages(c('tidyverse', 'lubridate', 'dplyr', 'stringr', 'ggplot2', 'caret', 'pROC', 'corrplot', 'Rtsne'), repos='http://cran.us.r-project.org')"