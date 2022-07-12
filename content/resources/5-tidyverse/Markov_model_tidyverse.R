###########################
# Markov model: tidyverse #
###########################

library(dplyr)
library(purrr)
library(tibble)


##########################
# model set-up

t_names <- c("without_drug", "with_drug")
n_treatments <- length(t_names)

s_names  <- c("Asymptomatic_disease", "Progressive_disease", "Dead")
n_states <- length(s_names)

n_pop <- 1000

n_cycles <- 46
Initial_age <- 55

cAsymp <- 500
cDeath <- 1000
cDrug <- 1000
cProg <- 3000
uAsymp <- 0.95
uProg <- 0.75
oDr <- 0.06
cDr <- 0.06
tpDcm <- 0.15

# cost of staying in state
state_c_matrix <-
  data.frame(treatment = rep(t_names, each = n_states),
             state = s_names,
             val = c(cAsymp, cProg, 0,
                     cAsymp + cDrug, cProg, 0))

# qaly when staying in state
state_q_matrix <-
  data.frame(treatment = rep(t_names, each = n_states),
             state = s_names,
             val = c(uAsymp, uProg, 0,
                     uAsymp, uProg, 0))

# cost of moving to a state
# same for both treatments
trans_c_matrix <-
  data.frame(treatment = rep(s_names, each = n_states),
             state = s_names,
             val = c(0, 0, 0,
                     0, 0, cDeath,
                     0, 0, 0))


################################
# Transition probabilities

p_matrix <- 
  data.frame(treatment = rep(t_names, each = n_states*n_states),
             from = rep(s_names, each = n_states),
             to = s_names,
             val = 0)

# Store population output for each cycle 

# state populations
pop <- 
  data.frame(treatment = rep(t_names, each = n_cycles*n_states),
             cycle = rep(1:n_cycles, each = n_states),
             state = s_names,
             val = NA) %>% 
  mutate(val = 
           case_when(cycle == 1 & state == "Asymptomatic_disease" ~ n_pop,
                     cycle == 1 & state == "Progressive_disease" ~ 0,
                     cycle == 1 & state == "Dead" ~ 0,
                     TRUE ~ NA_real_))

# _arrived_ state populations
trans <-
  data.frame(treatment = rep(t_names, each = n_cycles*n_states),
             cycle = rep(1:n_cycles, each = n_states),
             state = s_names,
             val = NA) %>% 
  mutate(val = ifelse(cycle == 1, 0, NA))

# Sum costs and QALYs for each cycle at a time for each drug 

cycle_empty_array <-
  data.frame(treatment = rep(t_names, each = n_cycles),
             cycle = 1:n_cycles,
             val = NA)


cycle_state_costs <- cycle_trans_costs <- cycle_empty_array
cycle_costs <- cycle_QALYs <- cycle_empty_array
LE <- LYs <- cycle_empty_array    # life-expectancy; life-years
cycle_QALE <- cycle_empty_array   # qaly-adjusted life-years

total_costs <- setNames(c(NA, NA), t_names)
total_QALYs <- setNames(c(NA, NA), t_names)


#####TODO: convert to dplyr below...

###########################
# Run model

for (i in 1:n_treatments) {
  
  age <- Initial_age
  
  for (j in 2:n_cycles) {
    
    p_matrix <- p_matrix_cycle(p_matrix, age, j - 1)
    
    pop[, cycle = j, treatment = i] <-
      pop[, cycle = j - 1, treatment = i] %*% p_matrix[, , treatment = i]
    
    trans[, cycle = j, treatment = i] <-
      pop[, cycle = j - 1, treatment = i] %*% (trans_c_matrix * p_matrix[, , treatment = i])
    
    age <- age + 1
  }
  
  cycle_state_costs[i, ] <-
    (state_c_matrix[treatment = i, ] %*% pop[, , treatment = i]) * 1/(1 + cDr)^(1:n_cycles - 1)
  
  # discounting at _previous_ cycle
  cycle_trans_costs[i, ] <-
    (c(1,1,1) %*% trans[, , treatment = i]) * 1/(1 + cDr)^(1:n_cycles - 2)
  
  cycle_costs[i, ] <- cycle_state_costs[i, ] + cycle_trans_costs[i, ]
  
  LE[i, ] <- c(1,1,0) %*% pop[, , treatment = i]
  
  LYs[i, ] <- LE[i, ] * 1/(1 + oDr)^(1:n_cycles - 1)
  
  cycle_QALE[i, ] <-
    state_q_matrix[treatment = i, ] %*% pop[, , treatment = i]
  
  cycle_QALYs[i, ] <- cycle_QALE[i, ] * 1/(1 + oDr)^(1:n_cycles - 1)
  
  total_costs[i] <- sum(cycle_costs[treatment = i, -1])
  total_QALYs[i] <- sum(cycle_QALYs[treatment = i, -1])
}

#####################
## Plot results

# Incremental costs and QALYs of with_drug vs to without_drug
c_incr <- total_costs["with_drug"] - total_costs["without_drug"]
q_incr <- total_QALYs["with_drug"] - total_QALYs["without_drug"]

# Incremental cost effectiveness ratio 
ICER <- c_incr/q_incr

plot(x = q_incr/n_pop, y = c_incr/n_pop,
     xlim = c(0, 1100/n_pop),
     ylim = c(0, 10e6/n_pop),
     pch = 16, cex = 1.5,
     xlab = "QALY difference",
     ylab = "Cost difference (?)",
     frame.plot = FALSE)
abline(a = 0, b = 30000) # Willingness-to-pay threshold

