# Cancers of Unknown Primary Nomogram Application
A nomogram app for Cancers of Unknown Primary (CUP). The link to the app can be found [here](https://cupnomogram.shinyapps.io/Nomogram/).

This is a shiny application demonstrating the usage of a nomogram for Cancers of Unknown Primary, for potential use in oncology clinics.

## The CUP Problem

It is a well known problem within oncology that prognostication for cancers of unknown primary is significantly more uncertain, and assessments on survival rates can vary widely between different physicians.

To simplify this problem, we have devised a nomogram to display estimated One Year & Two Year Overall Survival (OS) rates, using 5 well known and validated prognostic factors: Sex, Eastern Cooperative Oncology Group (ECOG) Status, Histology, Number of Metastatic Sites, and the Neutrophil-Lymphocite Ratio (NLR). The nomogram was devised by Raghav et al. To allow ease of real time use of the nomogram in clinical settings, we designed a simple web and mobile friendly application. The implementation and code used to design the app is provided here.

## About the App:

The app was designed and deployed using the R Shiny package.

The sidebar details the 5 prognostic factors that can be modified.

The patient score is displayed in case the user may want to consult the original nomogram pictorial in the article.

The 2 gauges displayed in center change reactively to user input, automatically calculating survival rates.


## Acknowledgments:

More background information about CUP diagnosis, as well as information on how the nomogram was created are detailed here: (manuscript is currently under review. The article link will be posted when it has been published).
