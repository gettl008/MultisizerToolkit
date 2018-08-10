#' estimateVolumeFactors
#'
#' This function returns the estimated value of n in 4/3*pi*r^n that minimizes the difference between calculated total volume and real total volume (as estimated via sonicated samples).
#' @param total_vol Known total volume per ml in sample. Can be obtained from sonicated sample measurments.
#' @param input Data frame with two columns, the first with diameter bins, the second with counts per ml.
#' @param start Low end to begin searching for optimal factor
#' @param end High end of range to search for optimal factor
#' @param increment Amount to increment when conducting search for optimal factor
#' @param df Return data frame of volume factor estimates and differences from actual volume instead of best fit volume factor
#' @keywords multisizer
#' @export
#' @examples
#' estimateVolumeFactors(input, total_vol)

estimateVolumeFactors <- function(input, real_vol, start = 2, end = 3, increment = .01, df = FALSE){
  diff.df <- data.frame(x = numeric(), diff = numeric())
  n <- start
  while(n <= end){
    voldiff <- sum((4/3*pi*(diam/2)^n) * cpm) - real_vol
    newdata <- data.frame(x = n, diff = voldiff)
    diff.df <- rbind(diff.df, newdata)
    n <- n + increment
  }
  if (! df){
    return(diff.df$x[which(abs(diff.df$diff) == min(abs(diff.df$diff)))])
  } else {
    return(diff.df)
  }
}
