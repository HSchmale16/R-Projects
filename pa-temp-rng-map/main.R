suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(rgdal)
  library(raster)
  library(sp)
  library(gstat)
  library(dplyr) # for "glimpse"
  library(scales) # for "comma"
  library(magrittr)
  library(automap)
  library(rgeos)
  library(maptools)
})

# Required To Enable Polygon clipping
gpclibPermit()

# Load the station listing with their lats, and longs
stations <- data.table(read.csv(file = 'stations.csv', header = FALSE))
colnames(stations) <- c("STATION", "LAT", "LONG")

# Load up the temperature datafile
dps <- data.table(read.csv(file='1093638.csv'))
dps$RANGE <- dps$TMAX - dps$TMIN

# Group Them by station, and get the mean of the range
grouped <- dps[, mean(RANGE), by =STATION]
colnames(grouped) <- c("STATION", "avgtrange")
grouped <- as.data.frame(grouped)
grouped[is.na(grouped)] <- 0

# Merge Stations and Groups
locs <- merge(grouped, stations, by="STATION")
locs <- as.data.frame(locs)
coordinates(locs) <- c('LONG', 'LAT')
crs(locs) <- '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'

# Generate Spatial Points to put everything
us <- raster::getData('GADM', country = 'US', level = 1)
pa <- us[us$NAME_1 == "Pennsylvania",]
pa <- spTransform(pa, CRS('+proj=merc'))
locs.grid <- makegrid(pa, cellsize = 5000)
locs.grid <- SpatialPoints(locs.grid, proj4string = CRS(proj4string(pa)))
locs.grid <- locs.grid[pa,]

# Transform Regular Locs to mercerter
locs <- spTransform(locs, CRS('+proj=merc'))

# Kriege, to interpolate it
locs.krieged <- autoKrige(avgtrange ~ 1, locs, locs.grid)
locs.kr.df <- as.data.frame(locs.krieged$krige_output)

# Clean up pa into a dataframe
pa@data$id = rownames(pa@data)
pa.points = fortify(pa, region="id")
pa.df <- merge(pa.points, pa@data, by = "id")

locs.df <- as.data.frame(locs)

# Make Plot
ggplot() +
  geom_tile(data=locs.kr.df,aes(x=x1,y=x2,fill=var1.pred)) +
  coord_equal() +
  scale_fill_gradient(low = "blue", high="red") +
  geom_point(data=locs.df, aes(x=LONG,y=LAT)) +
  geom_contour(data=locs.kr.df, aes(x=x1,y=x2,z=var1.pred)) +
  geom_path(data=pa, aes(x=long,y=lat), color="black") +
  xlab('Longitude') +
  ylab('Latitude')


