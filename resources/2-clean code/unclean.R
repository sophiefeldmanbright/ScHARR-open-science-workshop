#########
# temp2 #
#########

setwd("C:/Documents and Settings/Public/")
# not reproducable on another PC

names <- c("without_drug", "with_drug")
# not clear what it it
# same name as a base function

n_treatments <- length(names)

sNames  <- c('Asymptomatic_disease', 'Progressive_disease', "Dead")
# camel case, not snake case
# inconsistent speech marks

n_states <- length(s_names)
n_pop <- 1000
x <- 46
# totally uninformative name

Initial_age <- 55
# why starting with capital letter

cAsymp <- 500; cDeath <- 1000; cDrug <- 1000; cProg<-3000; uAsymp<-0.95; uProg <- .75; oDr <- .06; cDr <- 0.06; tpDcm<-0.15
# hard to read from left to right
# inconsistent; 0 before decimal or not
# inconsistent; spacing
# line over 80 characters

c_matrix_state <-
  matrix(c(cAsymp, cProg, 0,
           cAsymp + cDrug, cProg, 0),
         byrow = TRUE,
         nrow = n_treatments,
         dimnames = list(names,
                         s_names))
# not consistent name with other similar variables

state_q_matrix <-
  matrix(c(uAsymp, uProg, 0,
           uAsymp, uProg, 0),
         byrow = T,
         nrow = n_treatments,
         dimnames = list(names,
                         s_names))
# TRUE not used in full

trans_c_matrix =
  matrix(c(0, 0, 0,
           0, 0, cDeath,
           0, 0, 0),
         byrow = TRUE,
         nrow = n_states,
         dimna = list(from = s_names,
                      to = s_names))
# inconsistent; = not <-
# partial matching of argument name

n_stat <- length(s_names)
# same thing defined twice


