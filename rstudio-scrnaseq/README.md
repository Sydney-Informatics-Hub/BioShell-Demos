# rstudio-scrnaseq

## Data prep

Download data from
[https://github.com/swbioinf/scRNAseq_Workshop/tree/main/data](https://github.com/swbioinf/scRNAseq_Workshop/tree/main/data),
then run subset_kang2018.Rmd to split into individual .rds files per `ind` to align with SIH/scrna-analysis.

Git clone SIH/scrnaseq

## Script

### Intro

* This is the laptop I used when I was learning R for bioinformatics

* It has 4GB RAM, it can barely have multiple tabs open in the browser, let alone do anything in R.

* When it did work, it took so long to run any code I had to keep the laptop open on my commutes home, and hope the battery didn't die 

* You may or may not be able to relate to my story, but these bottlenecks are exactly why RStudio is available as part of the BioShell.

* It is the exact same RStudio you would download and use on your own device, except that you use it from a browser tab and your laptop essentially becomes the screen to interact with it

* With your own BioShell, you will have access to RStudio with the sufficient compute resources required for demanding analyses

* And it is all self-contained so you are free to experiment, and won't have to worry about making mistakes on a shared computer or server

* In this video, I will show how to get RStudio running on a BioShell, install packages, load some single-cell data, and do quality control on it.
