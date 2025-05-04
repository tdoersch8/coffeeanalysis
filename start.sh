docker build --platform linux/amd64 -t indstudy .
docker run -v $(pwd):/home/rstudio -p 8787:8787 -it indstudy
