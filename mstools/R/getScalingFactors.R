#' getScalingFactors
#'
#' Returns scaling factors for data frame containing whole counts and corresponding component (e.g. sonicated) counts.
#' @param df Data frame of binned counts per size bin.
#' @param sonication_indicator Character string in sample names used to designate component parts of whole
#' @keywords multisizer
#' @export
#' @examples
#'getScalingFactors(df)

getScalingFactors <- function(df, sonication_indicator = ".S"){
  outdata <- data.frame(sample = character(), scaling_factor = numeric())
  samples <- colnames(df)[-grep(sonication_indicator, colnames(df))][-1:-2]
  for (sample in samples){
    newdata <- data.frame(original_vol = df$volume_um3,
                          diameter = df$diameter_um, 
                          unsonicated = df[,which(colnames(df) == sample)], 
                          sonicated = df[,which(colnames(df) == paste(sample, sonication_indicator, sep=""))])
    factor <- vol_factor(sum(newdata$sonicated * newdata$original_vol),
                         newdata$diameter,
                         newdata$unsonicated,
                         start = 2.5,
                         end = 3,
                         increment = .0001)
    outdata <- rbind(outdata, data.frame(sample = sample, scaling_factor = factor))
  }
  return(outdata)
}
