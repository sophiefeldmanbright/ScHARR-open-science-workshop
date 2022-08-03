#########
# temp2 #
#########

install.packages("lintr")
library(lintr)

setwd("G:\\My Drive\\OPEN SCIENCE\\Summer camp\\Hackathon\\ScHARR-open-science-workshop\\content\\resources\\2-clean_code")

# No headings to explain what each section is doing.

names <- c("without_drug", "with_drug") # would be difficult to remember what these names are referring to.

n_treatments <- length(names) 

sNames  <- c('Asymptomatic_disease', 'Progressive_disease', "Dead")  # Uses a combination of double and single quotes - should choose one and be consistent. would be difficult to remember what these names are referring to.

n_states <- length(s_names)
n_pop <- 1000
x <- 46 # not clear what number this is referring to

Initial_age <- 55

cAsymp <- 500; cDeath <- 1000; cDrug <- 1000; cProg<-3000; uAsymp<-0.95; uProg <- .75; oDr <- .06; cDr <- 0.06; tpDcm<-0.15 
# inconsistant ways of writing the numbers e.g. 0.06 and .06
# inconsistant spacing between operators e.g. uAsymp<-0.95 and uProg < - .75
# Very related things can go together on one line but you may also want to have it as a column (instead of having the columns)

# no naming convention

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
         dimna = list(from = s_names, # uses s_names instead of sNames
                      to = s_names))

n_stat <- length(s_names)

# sNames is called camel case
# s_names is called snake case ... need to be consistent
# Commenting should add to the code.  It shouldn't be a substitute for good code!
# The commenting should explain why you are doing what you are doing.  
# Not just commenting saying 'load data' and then a function called load data.

# Can use lint("unclean.R") in the console to then check for errors.
