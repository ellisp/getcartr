#' @title Create a warping function to apply to Spatial* and Spatial*DataFrame objects
#' @description
#' Create a cartogram transform given a \code{SpatialPolygons*} object and a variable
#' The returned value is a function that performs the transform.
#'
#' @param spdf A \code{SpatialPolygonsDataFrame}
#' @param v The variable providing the values - typically population counts
#' @param extend The extent beyond the limits of the \code{SpatialPolygonsDataFrame} to estimate the warping as a proportion of span 
#' @param res The resolution of the grid for the warping - default 128
#' @param index Index of data item to be used for cartogram - only used if \code{v} is missing
#' @param thresh Lowest density value allowed - will replace pixels with \code{max(value,thresh*mean(value))} - 0.1 works well 
#' @param blur Degree of Gaussian blur to apply to density grid,  prior to computing the cartogram transform 
#' @param prec The precision when carrying out interpolation, in units of the warping grid - 0.5 works well
#' @param gapdens The density to assign to gaps between the polygons - relative to average density. 
#' @return a function taking a \code{Spatial*} or \code{Spatial*DataFrame} object,  returning a warped version of the object
#' 
#' @references A Diffusion-based method for producing density equalizing maps, Michael T. Gastner and M. E. J. Newman, Proc. Natl. Acad. Sci. USA 101, 7499-7504 (2004)
#' @family transformers
#' @keywords cartogram
#' @export
#' @examples
#' 
#' # Make a cartogram for Newhaven census blocks
#' require(GISTools)
#' data(newhaven)
#' to.carto <- carto.transform(blocks,blocks$POP1990,thresh=0.1)
#' # Create the transform function
#' # Plot the blocks carto
#' plot(to.carto(blocks))
#' # Add roads,  transformed to cartogram space
#' plot(to.carto(roads),add=TRUE,col='lightgrey')
#' # Add forced entry residential burglaries, transformed to cartogram space
#' plot(to.carto(burgres.f),add=TRUE,col='red',pch=16)
#' 
#' 
#' 
carto.transform <- function(spdf,v,extend=0.05,res=128,index=1,thresh=0.1,blur=0,prec=0.5,gapdens=1) {
  poly <- quick.carto(spdf,v,extend,res,index,thresh,blur,prec,gapdens)
  result <- function(obj) {
    if (grepl("SpatialPolygons",class(obj))) return(warp.polys(obj,poly,prec=prec))
    if (grepl("SpatialPoints",class(obj))) return(warp.points(obj,poly))
    if (grepl("SpatialLines",class(obj))) return(warp.lines(obj,poly,prec))
    stop("Could not identify object to be warped as class Spatial*")
  }
  return(result)
}   
