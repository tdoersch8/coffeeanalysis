docker build -t indstudy .
docker run -v $(pwd):/home/rstudio/work -p 8787:8787 -it indstudy
