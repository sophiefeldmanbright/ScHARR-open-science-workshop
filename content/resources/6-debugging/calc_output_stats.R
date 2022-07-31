
#
calc_LE <- function(pop) {
  c(1,1,0) %*% pop
}

#
calc_LYs <- function(LE, oDr, ncycles) {
  LE * 1/(1 + oDr)^(1:n_cycles - 1)
}
