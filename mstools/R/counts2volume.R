#' counts2volume
#'
#' This function translates counts total volume (rather than counts) contained within each diameter bin.
#' @param input Data frame. First column should be diameter bins. The remaining columns will be treated as counts to be transformed.
#' @param scaling_factor Factor used to estimate volume from diameters. n in 4/3*pi*r^n.
#' @param fractions Return volumetric fraction within each bin rather than volume per bin
#' @keywords multisizer
#' @export
#' @examples
#' counts2volume(input, scaling_factor)

counts2volume <- function(input, scaling_factor, fractions = FALSE){
  output <- input
  temp_vol <- 4/3*pi*input[,1]^scaling_factor
  for (sample_column in 2:ncol(input)){
    output[,sample_column] <- temp_vol * input[,sample_column]
    if ( fractions){
      output[,sample_column] <- output[,sample_column]/colSums(output[,sample_column])
    }
  }
  return(output)
}

