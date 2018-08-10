#' extendDiameterRange
#'
#' This function adds extra rows to a data frame not containing the multisizers extended diameter range.
#' @param main_df Data frame of counts containing extended range of diameter values
#' @param short_df Data frame you wish to add extended range rows to
#' @keywords multisizer
#' @export
#' @examples
#' extendDiameterRange(main_df, short_df)


extendDiameterRange <- function(main_df, short_df){
  newrows <- nrow(main_df) - nrow(short_df)
  add_data <- data.frame(matrix(0, nrow=newrows, ncol=ncol(short_df)))
  colnames(add_data) <- colnames(short_df)
  return(rbind(short_df, add_data))
}