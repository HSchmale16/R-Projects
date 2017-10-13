library(data.table)

dps <- data.table(read.csv(file='1093638.csv'))
dps$RANGE <- dps$TMAX - dps$TMIN

grouped <- dps[, mean(RANGE), by = STATION]
