###############################################################################
#
#            covertest() - a simple way to improve vegetation coverage estimates
# 
#            Script: Roman Link (rlink@gwdg.de)	
#
###############################################################################


#  covertest() ----------------------------------------------------------------
covertest <- function(delta = 5, n = 30, range = c(0,100)){
  # this function generates an n x n sample from a multivariate normal
  # distribution with a gaussian autocorrelation function with autocorrelation
  # parameter delta, then prints a classified version of that raster
  # based on a quantile of the random sample that itself is sampled from the 
  # percentile range specified by "range".
  
  # the original and classified raster, the true coverage percentage and
  # the autocorrelation parameter are silently returned.
  
  # the higher delta, the more autocorrelated the simulated vegetation cover;
  # for low values the outcome approximates random noise
  
  # warning: high values of n lead to high computation times. 
  
  # the raster package has to be installed to use this function
  require(raster)
  
  # create grid for sampling
  grid <- expand.grid(1:n, 1:n)
  
  # create distance matrix
  distance <- as.matrix(dist(grid))
  
  # Generate random variable from mvrnorm function of the MASS package
  sample <- MASS::mvrnorm(1, rep(0, nrow(distance)), exp(-(distance / delta) ^ 2))
  
  # convert simulated random variable to raster object
  sample_grid <- rasterFromXYZ(cbind(grid[, 1:2] - 0.5, sample))
  
  # get random proportion in the desired range
  prop <- runif(1, range[1]/100, range[2]/100)
  
  # get values in the sample grid that are larger than the desired quantile
  out <- sample_grid < quantile(sample_grid, prop)
  
  # plot output raster
  raster::plot(out)
  
  # prepare structured output
  output <- structure(
    list(classified = out, 
         raw        = sample_grid,
         truecov    = mean(values(out)),
         delta      = delta),
    class = "covertest"
  )
  # return structured output as an S3 object of class coversim
  return(output)
}

# print method for class covertest ---------------------------------------------
print.covertest <- function(object){
  dims <- dim(object[[1]])
  cat("Simulated coverage proportion for a", dims[1], "x",  dims[2], "raster\n\n")
  cat("Autocorrelation parameter delta =", object$delta, "\n\n")
  cat("True coverage percentage:", round(100 * object$truecov, 1), "%\n")
}
