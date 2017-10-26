library(ggplot2)
library(raster)
library(sp)
library(reshape)
library(maps)

setwd('~/R-Projects/GFit-Where-I-Was/csv')
temp <- list.files()
activeBoxes <- lapply(temp, function(x) {
  csv <- read.csv(x)
  csv <- cbind(Date=tools::file_path_sans_ext(x), csv)
  csv <- csv[complete.cases(csv[6:9]),]
  if(ncol(csv) > 17) {
    csv <- csv[c(1,6:9,18:ncol(csv))]
    if(nrow(csv) > 0)
      melt(csv, id.vars=1:5)
  }
})
activeBoxes <- do.call(rbind, activeBoxes)

ggplot() +
  geom_rect(data=activeBoxes,
            aes(xmin = activeBoxes$Low.longitude..deg,
                xmax = activeBoxes$High.longitude..deg,
                ymin = activeBoxes$Low.latitude..deg,
                ymax = activeBoxes$High.latitude..deg,
                fill = activeBoxes$variable),
            color="transparent", alpha=0.5)

