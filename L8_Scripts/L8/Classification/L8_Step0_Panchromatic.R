# TODO: Add comment
# 
# Author: cade
###############################################################################

###list rasters 

##read in l8_final for match up date



###pansharpen for match-up date
RStoolbox
pcaSharp <- panSharpen()









##untar
setwd("E:\\cade\\SPOT5Take5_11_25_2016\\L8_Panchromatic")
list.l8 <- list.files(getwd(), pattern=".tar.gz$")
lapply(list.l8, untar)














install.packages(doParallel)
install.packages(foreach)
library (raster)
library(doParallel)
library(foreach)

#make a cluster. In this instance we are going to use 15 of the 20 cpus
cl <-  makeCluster(15)
registerDoParallel(cl)

#define what column name we are going to extract on - I can't remember the one we picked

ndvi_extract<-foreach (i = 1:length(wetlands_proj$label_head), .combine='c', .packages="raster") %dopar% {extract(spot_ndvi, wetlands_proj[i], sp=T, fun=mean, na.rm=T)}

