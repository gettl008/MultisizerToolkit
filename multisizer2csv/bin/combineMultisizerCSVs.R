#!/usr/bin/env Rscript
#############
# Functions #
#############
volumetricFraction <- function(data, vol_col, data_col){
  volsums <- data[,vol_col] * data[,data_col]
  return(volsums / sum(volsums))
}
#############

args <- commandArgs(TRUE)
dir <- args[1]
outbase <- args[2]
blank <- args[3]

#extension <- data.frame(volume_um3 = c(38792.3860865268,39820.1862554772,40875.449925535,41958.5365834821,43070.3924050182,44211.6948160625,45383.134648542,46585.7293916107,47820.2137919615,49087.3371683578,50387.8636245769,51723.2435993969,53093.6236839176,54500.5093997719,55944.7634421716,57427.265664964,58948.9133321897,60510.9940575671,62114.4603495802,63760.283578492,65449.8469497874,67184.1811015002,68964.3370867952,70791.8004573652,72667.6858218585,74593.1298650604,76569.7276749055,78598.6840583754,80681.2276733948,82819.0707934672,85013.5150596616,87266.3635788416,89578.5108699433,91952.3225754708),
#                        diameter_um = c(42,42.3677,42.7387,43.1129,43.4904,43.8712,44.2553,44.6428,45.0337,45.428,45.8257,46.227,46.6317,47.04,47.4519,47.8674,48.2865,48.7093,49.1358,49.566,50,50.4378,50.8794,51.3249,51.7743,52.2276,52.6849,53.1462,53.6115,54.0809,54.5544,55.0321,55.5139,56),
#                        raw.counts = rep(0, times=34),
#                        counts.per.ml = rep(0, times=34))

setwd(dir)
outcpm <- data.frame()
outcounts <- data.frame()
for(file in list.files(dir)) {
  if (grepl('.csv', file)) {
    name <- tools::file_path_sans_ext(file)
#    print(name)
    new <- read.csv(file)
    if (ncol(outcpm) == 0){
#      print("A")
      outcpm <- new[,c(1,2,4)]
      outcounts <- new[,c(1,2,3)]
    } else if (nrow(new) > nrow(outcpm)) {
#      print("B")
      oldcpm <- data.frame(outcpm[,c(3:ncol(outcpm))])
      colnames(oldcpm) <- colnames(outcpm)[3:ncol(outcpm)]
      oldcounts <- data.frame(outcounts[,c(3:ncol(outcounts))])
      colnames(oldcounts) <- colnames(outcounts)[3:ncol(outcounts)]
      row_diff <- nrow(new) - nrow(oldcpm)
      outcpm <- new[,c(1:2)]
      outcounts <- new[,c(1:2)]
      add_on <- data.frame(matrix(rep(0,times = ncol(oldcpm) * row_diff), nrow = row_diff, ncol = ncol(oldcpm)))
      colnames(add_on) <- colnames(oldcpm)
      oldcpm <- rbind(oldcpm, add_on)
      oldcounts <- rbind(oldcounts, add_on)
      outcpm <- cbind(outcpm, oldcpm, new[,4])
      outcounts <- cbind(outcounts, oldcounts, new[,3])
    } else if (nrow(new) < nrow(outcpm)) {
#      print ("C")
      row_diff <- nrow(outcpm) - nrow(new)
      outcpm <- cbind(outcpm, c(new[,4], rep(0, times = row_diff)))
      outcounts <- cbind(outcounts, c(new[,3], rep(0, times = row_diff)))
    } else {
#      print("D")
      outcpm <- cbind(outcpm, new[,4])
      outcounts <- cbind(outcounts, new[,3])
    }
    colnames(outcpm)[ncol(outcpm)] <- name
    colnames(outcounts)[ncol(outcounts)] <- name
  }
}
if (blank != "" && blank %in% colnames(outcpm)){
  outcpm[,3:ncol(outcpm)] <- outcpm[,3:ncol(outcpm)] - outcpm[,which(colnames(outcpm) == blank)]
  outcpm[,-c(1,2)][outcpm[, -c(1,2)] < 0] <- 0
  outcounts[,3:ncol(outcounts)] <- outcounts[,3:ncol(outcounts)] - outcounts[,which(colnames(outcounts) == blank)]
  outcounts[,-c(1,2)][outcounts[, -c(1,2)] < 0] <- 0
} else if (blank != ""){
  print("Could not find specified blank")
}


outfreqs <- cbind(outcounts[,c(1,2)], data.frame(prop.table(as.matrix(outcounts[,-c(1,2)]), 2)))
outvolfrac <- outcounts[,c(1,2)]
for(col in 3:ncol(outcounts)){
  outvolfrac <- cbind(outvolfrac, volumetricFraction(outcounts,1,col))
}
colnames(outvolfrac) <- colnames(outcounts)
colnames(outfreqs) <- colnames(outcounts)

write.table(outcpm, paste(outbase, "cpm.csv", sep="."), row.names = FALSE, sep=",")
write.table(outcounts, paste(outbase, "counts.csv", sep="."), row.names = FALSE, sep=",")
write.table(outfreqs, paste(outbase, "freqs.csv", sep="."), row.names = FALSE, sep=",")
write.table(outvolfrac, paste(outbase, "volumetricfraction.csv", sep="."), row.names = FALSE, sep=",")


