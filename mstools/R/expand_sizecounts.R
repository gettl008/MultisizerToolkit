#' expand_sizecounts
#'
#' This function expands counts into a format that allows you to plot distributions.
#' @param counts Data frame of binned counts per size bin. First two columns should correspond to volume and diameter bins. The final columns should correspond to sample counts. 
#' @param vol_col Column in data frame containing volume data
#' @param diam_col Column in data frame containing diameter data
#' @keywords multisizer
#' @export
#' @examples
#' expand_sizecounts(counts)

expand_sizecounts <- function(counts, vol_col=1, diam_col=2){
  counts.expanded <- data.frame(sample = character(), volume_um3 = numeric(), diameter_um = numeric())
  for(x in 3:ncol(counts)){
    colvals <- round(counts[,x])
    expanded <- data.frame(sample = rep(colnames(counts)[x], sum(colvals)),
                           volume_um3 = rep(counts[[vol_col]], colvals),
                           diameter_um = rep(counts[[diam_col]], colvals))
    counts.expanded <- rbind(counts.expanded, expanded)
  }
  return(counts.expanded)
}