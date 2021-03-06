# devtools::install_github("robinlovelace/stplanr")
library(stplanr)

dl_stats19()
data_dir = tempdir()
ac <- readr::read_csv(file.path(data_dir, "Accidents0514.csv"))
ac <- ac_recat(ac)


ac <- read_stats19_ac()
ve <- read_stats19_ve()
ca <- read_stats19_ca()


# save all stat19 data in one large table
all_stats19 <- dplyr::inner_join(ve, ca)
all_stats19 <- dplyr::inner_join(all_stats19, ac)

# downloader::download("https://github.com/npct/pct-data/raw/master/leeds/z.Rds", destfile = "data/z.Rds")
z <- readRDS("data/z.Rds")

plot(z)


all_stats19 <- all_stats19[!is.na(all_stats19$Location_Easting_OSGR),]
all_stats19 <- data.frame(all_stats19)
a <- SpatialPointsDataFrame(coords=matrix(c(all_stats19$Location_Easting_OSGR, all_stats19$Location_Northing_OSGR), ncol=2), data=all_stats19)

# transform
proj4string(a) <- CRS("+init=epsg:27700")
a <- spTransform(x = a, CRSobj = CRS("+init=epsg:4326"))

plot(a)
bbox(z)
bbox(a)

al <- a[z,]

plot(al)

# Now pull all cyclist casualties 
df <- al@data
al <- al[ df$Type == "Cyclist",]

raster::shapefile(al, "data/stats19-lds-cyclists.shp")
url <- "https://github.com/npct/pct-data/raw/master/leeds/rnet.RData"
download.file(url, destfile = "data/rnet.Rds", mode = "wb")

rnet <- readRDS("data/rnet.Rds")
plot(rnet)
