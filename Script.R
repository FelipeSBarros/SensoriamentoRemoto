library(raster)
library(rgdal)

satelite <- stack("./LandSat8.tif")
plotRGB(satelite, r = 4, g = 3, b = 2, stretch = 'lin')

rj <- readOGR("./shp/", "RJ")
plot(rj, add=T)

cat("Processing C-means (fuzzy K-means) \n")
library(e1071)

mydata <- getValues(satelite)

# Identificando pixel nao NA
a <- which(!is.na(mydata))

# Creating data to Kmeans analysis
mydata <- na.omit(values(satelite))

# Not used for this prupouse
mydata <- scale(mydata) # standardize variables

set.seed(123)
fuzzy <- cmeans(mydata, centers = 8, iter.max = 100, verbose = FALSE,
                dist = c("euclidean", "manhattan")[1], method = c("cmeans","ufcl")[1], m = 2,
                rate.par = 0.3, weights = 1, control = list())

# Saving statistical results
save(fuzzy, file="Fuzzy.RData")

# creating a raster layer to recieve group values
fuzzy_SegmentationRaster <- satelite[[1]]

# changing pixel values to group values
fuzzy_SegmentationRaster[a] <- fuzzy$cluster

cat("Fuzzy segmentation done. \n")
plot(fuzzy_SegmentationRaster)
