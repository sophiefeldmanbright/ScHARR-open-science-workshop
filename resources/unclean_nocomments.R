#########
# temp2 #
#########

setwd("C:/Documents and Settings/Public/")

names <- c("without_drug", "with_drug")

n_treatments <- length(names)

sNames  <- c('Asymptomatic_disease', 'Progressive_disease', "Dead")

n_states <- length(s_names)
n_pop <- 1000
x <- 46

Initial_age <- 55

cAsymp <- 500; cDeath <- 1000; cDrug <- 1000; cProg<-3000; uAsymp<-0.95; uProg <- .75; oDr <- .06; cDr <- 0.06; tpDcm<-0.15

c_matrix_state <-
  matrix(c(cAsymp, cProg, 0,
           cAsymp + cDrug, cProg, 0),
         byrow = TRUE,
         nrow = n_treatments,
         dimnames = list(names,
                         s_names))

state_q_matrix <-
  matrix(c(uAsymp, uProg, 0,
           uAsymp, uProg, 0),
         byrow = T,
         nrow = n_treatments,
         dimnames = list(names,
                         s_names))

trans_c_matrix =
  matrix(c(0, 0, 0,
           0, 0, cDeath,
           0, 0, 0),
         byrow = TRUE,
         nrow = n_states,
         dimna = list(from = s_names,
                      to = s_names))

n_stat <- length(s_names)
