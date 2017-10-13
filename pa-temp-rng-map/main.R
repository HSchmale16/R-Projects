library(data.table)
library(maps)
library(ggplot2)

# Load the station listing with their lats, and longs
stations <- data.table(read.csv(file = 'stations.csv', header = FALSE))
colnames(stations) <- c("STATION", "LAT", "LONG")

# Load up the temperature datafile
dps <- data.table(read.csv(file='1093638.csv'))
dps$RANGE <- dps$TMAX - dps$TMIN

# Group Them by station, and get the mean of the range
grouped <- dps[, mean(RANGE), by = STATION]
colnames(grouped) <- c("STATION", "AVGTRANGE")

# Merge Stations and Groups
locs <- merge(grouped, stations, by="STATION")

# GET LOCS MIN MAX
lat_min <- min(locs$LAT)
lat_max <- max(locs$LAT)
lng_min <- min(locs$LONG)
lng_max <- max(locs$LONG)

# GET MAP BOUND
states <- map_data('state')
pa <- subset(states, region %in% 'pennsylvania')

ditch_the_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
)

state_outline <- ggplot(data = pa) + 
  geom_polygon(aes(x = long, y = lat, group = group), fill = "palegreen", color = "black") +
  coord_fixed(1.3) + ditch_the_axes

scatter_points <- ggplot(data=locs) +
  geom_point(aes(x=LONG, y=LAT))

gg <- ggplot() +
  geom_polygon(data = pa, aes(x = long, y = lat, group = group)) +
  geom_point(data = locs, aes(x=LONG, y=LAT))

