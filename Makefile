clean:
	rm -rf data/* figures/*
	
data/final_dataset.csv: df_1_arabica.csv df_1_robusta.csv clean.R
	Rscript clean.R
	
data/species_dataset.csv: df_1_arabica.csv df_1_robusta.csv clean.R
	Rscript clean.R

data/aesthetics_dataset.csv: df_1_arabica.csv df_1_robusta.csv clean.R
	Rscript clean.R
	
figures/coffee_characteristics_alignment_plot.png: data/final_dataset.csv data/species_dataset.csv ggplot.R
	Rscript ggplot.R
	
figures/country_plot.png: data/final_dataset.csv data/species_dataset.csv ggplot.R
	Rscript ggplot.R
	
figures/altitude_plot.png: data/final_dataset.csv data/species_dataset.csv ggplot.R
	Rscript ggplot.R
	
figures/total_plot.png: data/final_dataset.csv data/species_dataset.csv ggplot.R
	Rscript ggplot.R
	
figures/weight_plot.png: data/final_dataset.csv data/species_dataset.csv ggplot.R
	Rscript ggplot.R

figures/correlation_plot.png: data/aesthetics_dataset.csv correlation.R
	Rscript correlation.R
	
figures/tsne_clusters_2.png: data/species_dataset.csv clustering.R
	Rscript clustering.R
	
figures/tsne_clusters_3.png: data/species_dataset.csv clustering.R
	Rscript clustering.R
	
figures/pca_plot.png: data/species_dataset.csv data/aesthetics_dataset.csv pca.R
	Rscript pca.R

figures/roc_curve.png: data/species_dataset.csv classification.R
	Rscript classification.R
	
data/auc.Rmd: data/species_dataset.csv classification.R
	Rscript classification.R
	
report.pdf: report.Rmd figures/country_plot.png figures/altitude_plot.png figures/total_plot.png figures/weight_plot.png figures/coffee_characteristics_alignment_plot.png figures/correlation_plot.png figures/pca_plot.png figures/tsne_clusters_2.png figures/tsne_clusters_3.png figures/roc_curve.png data/auc.Rmd
	R -e "rmarkdown::render('report.Rmd', output_format = 'pdf_document')"
	