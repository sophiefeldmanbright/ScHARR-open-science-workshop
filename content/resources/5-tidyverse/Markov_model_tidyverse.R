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

# transition matrix variables
tpProg <- 0.01
tpDcm <- 0.15
tpDn <- 0.0138
effect <- 0.5

# cost of staying in state

# # convert from matrix to long format
state_c_matrix_m <-
  matrix(c(cAsymp, cProg, 0,
           cAsymp + cDrug, cProg, 0),
         byrow = TRUE,
         nrow = n_treatments,
         dimnames = list(t_names,
                         s_names))
state_c_matrix <-
  state_c_matrix_m |>
  as.data.frame() |>
  rownames_to_column(var = "treatment") |>
  tidyr::pivot_longer(cols = Asymptomatic_disease:Dead,
                      names_to = "state",
                      values_to = "val")

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
# transition probabilities

p_matrix_a <- array(data = 0,
                  dim = c(n_states, n_states, n_treatments),
                  dimnames = list(from = s_names,
                                  to = s_names,
                                  t_names))

## assume doesn't depend on cycle
p_matrix_a["Asymptomatic_disease", "Asymptomatic_disease", "without_drug"] <- 1 - tpProg - tpDn
p_matrix_a["Asymptomatic_disease", "Progressive_disease", "without_drug"] <- tpProg
p_matrix_a["Asymptomatic_disease", "Dead", "without_drug"] <- tpDn

p_matrix_a["Progressive_disease", "Dead", "without_drug"] <- tpDcm + tpDn
p_matrix_a["Progressive_disease", "Progressive_disease", "without_drug"] <- 1 - tpDcm - tpDn
p_matrix_a["Dead", "Dead", "without_drug"] <- 1

# Matrix containing transition probabilities for with_drug
p_matrix_a["Asymptomatic_disease", "Progressive_disease", "with_drug"] <- tpProg*(1 - effect)
p_matrix_a["Asymptomatic_disease", "Dead", "with_drug"] <- tpDn
p_matrix_a["Asymptomatic_disease", "Asymptomatic_disease", "with_drug"] <- 1 - tpProg*(1 - effect) - tpDn
p_matrix_a["Progressive_disease", "Dead", "with_drug"] <- tpDcm + tpDn
p_matrix_a["Progressive_disease", "Progressive_disease", "with_drug"] <- 1 - tpDcm - tpDn
p_matrix_a["Dead", "Dead", "with_drug"] <- 1

# # convert from array to long format
p_matrix <-
  reshape2::melt(p_matrix_a,
                 varnames = c("from", "to", "treatment"),
                 value.name = "val")


# Store population output for each cycle 

# state populations
pop <- 
  data.frame(treatment = rep(t_names, each = n_cycles*n_states),
             cycle = rep(1:n_cycles, each = n_states),
             state = s_names,
             val = NA) %>% 
  as_tibble() |> 
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
  as_tibble() |> 
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


###########################
# run population model

for (j in 2:n_cycles) {
  
    pop <- 
      dplyr::full_join(pop, p_matrix,
                       by = c("treatment" = "treatment",
                              "state" = "from")) |>
      filter(cycle == j - 1) |> 
      mutate(prop = val.x*val.y) |>
      group_by(treatment, cycle, to) |>
      summarise(val = sum(prop), .groups = "keep") |> 
      mutate(cycle = j) |> 
      rename(state = to) |> 
      full_join(pop, by = c("treatment", "cycle", "state")) |> 
      mutate(val = coalesce(val.x, val.y)) |>
      select(-val.x, -val.y)
}


