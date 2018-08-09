#!/usr/bin/env Rscript
#############
args <- commandArgs(TRUE)
inputfile <- args[1]
outfile <- args[2]
dilution_factor <- as.numeric(args[3])

data <- read.csv(inputfile, header=FALSE)
outdata <- cbind(format(round(((4/3)*pi*(data[,1]/2)^3), 4), nsmall=2),data, data[,2]/dilution_factor)
write.table(outdata, outfile, row.names = FALSE, col.names = FALSE, sep=",")
