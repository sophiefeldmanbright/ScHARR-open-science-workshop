---
title: Home
layout: default
---

# Health economics modelling Project workflow skills in R

{% include figure.html img="destinations-stockholm-banner-mobile-1024x553.jpg" alt="intro image here" caption="Stockholm" width="75%" %}

> Karolinska Institutet and University College London will be hosting a course on health economics modelling in R.

* __Where__: ScHARR, University of Sheffield (see [program](https://n8thangreen.github.io/ScHARR-open-science-workshop/content/program.html) for details of lecture rooms)
* __Date__: 3<sup>rd</sup> August 2022
* __Time__: 09:00-17:30 
* __Instructor__: [Nathan Green](https://iris.ucl.ac.uk/iris/browse/profile?upi=NGGRE44)


Learn about the data science of health economics modelling workflow in R.

## Prerequisites
* __Day 1__: No health economics background is assumed. Basic statistics and probabilty is preferable and ideally some Bayesian inference.

# Learning Objectives
 
From basic principles to advanced graphics. You will be able to 

* Write `clean code'
* Understand package workflows in RStudio
* Write Functions
* Use tidyverse
* Do basic debugging
* Document your code
* Create a GitHub page
* Create visualisations
* Make a simple Shiny app



## Software
Required software (for day 2):
* R (free general statistical software)

We suggest all participants bring a laptop on which they have installed R.


### Installation
The following sets out a basic installation process:

If necessary [download and install R](https://www.r-project.org/) and potentially a user interface to R like [RStudio](https://www.rstudio.com/).

Once R and Rstudio are both installed, if you open RStudio and things have gone according to plan then in the console you will see something like the following:

```
R version 3.6.1 (2019-07-05) -- "Action of the Toes"
Copyright (C) 2019 The R Foundation for Statistical Computing
Platform: x86_64-w64-mingw32/x64 (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.
```

### Install Necessary Packages
Open RStudio and paste the following code into your console, then press Enter to run it:


```r
# Download packages from CRAN

install.packages(c("devtools", "knitr", "magrittr", "sf", "sp", "rmarkdown", "usethis", "ggplot2", "dplyr", "zoo", "reshape2", "scales", "maptools",
                   "readxl", "rgdal"))

```

These are the main packages for the workshop.
If we require more then we can either install them from the web or from e.g. a USB if we have them.
 

<br>

## Target audience
The course is open to everyone with an interest in health economics modelling.

{% include toc.html %}

------

{% include template/credits.html %}
