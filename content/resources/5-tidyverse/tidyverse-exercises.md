Exercises: Introduction to dplyr
================

## Introduction

The dplyr package provides simple “verbs”, functions that correspond to
the most common data manipulation tasks, to help you translate your
thoughts into code.

These verbs can be organised into three categories based on the
component of the dataset that they work with:

-   Rows:
    -   `filter()` chooses rows based on column values.
    -   `slice()` chooses rows based on location.
    -   `arrange()` changes the order of the rows.
-   Columns:
    -   `select()` changes whether or not a column is included.
    -   `rename()` changes the name of columns.
    -   `mutate()` changes the values of columns and creates new
        columns.
    -   `relocate()` changes the order of the columns.
-   Groups of rows:
    -   `summarise()` collapses a group into a single row.

In this practical we are going to use these by refactoring the 3-state
Markov model. The available functions and what they can do is still in
active development and we will only be touching on what possible here.
You can keep up to date on the tidyverse webpages.

## Cost and QALYs input matrices

Open up the `Markov_model_original.R` script. This is a simplified
version of the whole script which just simulated the population counts.

The original cost-effectiveness Markov model uses R matrices and arrays
so we are first going to convert these to long format. Remember that
this is in contrast to wide format where a column represents a variable
value. In long format all values are by row.

For example, `state_c_matrix` was a 2 by 3 matrix of costs. We will
append `_m` here just to make it clear in this parctical this is a
matrix. In general you won’t want to do this.

``` r
state_c_matrix_m <-
  matrix(c(cAsymp, cProg, 0,
           cAsymp + cDrug, cProg, 0),
         byrow = TRUE,
         nrow = n_treatments,
         dimnames = list(t_names,
                         s_names))
```

The first thing to do is convert to data frame (or tibble). dplyr
operations won’t work on matrices.

``` r
state_c_matrix <-
  state_c_matrix_m |>
  as.data.frame()
```

This will appear the same as before but you can check using `class()` or
`str()`

``` r
class(state_c_matrix)
str(state_c_matrix)
```

Previously treatment was a row name but now we wish to have treatment as
its own column. dplyr has a function specifically for dealing with this.

``` r
state_c_matrix <-
  state_c_matrix_m |>
  as.data.frame() |>
  rownames_to_column(var = "treatment")
```

Finally, we are in a position to *pivot* from the wide format to long
format. `pivot_wider()` and `pivot_longer()` are relatively new
functions, renamed because people would get confused with the previous
names. This is also called *casting* and *melting* in the reshape2
package. The tidyr package also has `gather` and `spread`. Try them out
in your work and see which you prefer.

``` r
state_c_matrix <-
  state_c_matrix_m |>
  as.data.frame() |>
  rownames_to_column(var = "treatment") |>
  tidyr::pivot_longer(cols = Asymptomatic_disease:Dead,
                      names_to = "state",
                      values_to = "val")
```

**Can you do the same conversion from wide to long format for
`state_q_matrix` and `trans_c_matrix`?**

Of course, you don’t have to go in this round about way to get the input
data. You could specify the data frame directly with

``` r
state_c_matrix <-
  data.frame(treatment = rep(t_names, each = n_states),
             state = s_names,
             val = c(cAsymp, cProg, 0,
                     cAsymp + cDrug, cProg, 0))
```

## Transition probabilities array

The original probabilities were contained in an array. Again, we’ll
append `_a` just to be super clear this is the array version.

``` r
p_matrix_a <- array(data = 0,
                  dim = c(n_states, n_states, n_treatments),
                  dimnames = list(from = s_names,
                                  to = s_names,
                                  t_names))
```

Now its less clear how to “lengthen” this object. For this we will use
the `metl()` function in the reshape2 package (this is named a oddly a
bit like ggplot2. There is a reshape package but no one uses it!).

There are different `melt` arguments depending on if its a matrix, data
frame or array. Have a look at the help documentation to see the
differences. In our case we have

``` r
p_matrix <-
  reshape2::melt(p_matrix_a,
                 varnames = c("from", "to", "treatment"),
                 value.name = "val")
```

## Population array

The population array `pop` is slightly different to the other array
because nearly all of the values are empty except for at time 1.

Therefore, we will create a data frame with all empty values and then
substitute in the extra values. So firstly simpy create the data frame
as follows

``` r
pop <- 
  data.frame(treatment = rep(t_names, each = n_cycles*n_states),
             cycle = rep(1:n_cycles, each = n_states),
             state = s_names,
             val = NA)
```

Now, we will use the `case_when()` function. This is an extension to the
ubiquitous `ifelse` function. `case_when` is originally taken from SQL
where this sort of operation is very common. It allows us to make
multiple `ifelse` logical statements with the need to keep nesting them,
which can quickly become very untidy, hard to read and error prone.

The syntax is to first give the logical statement and if it is true then
insert the value after the `~`. If none of the statements are true then
it is good practice to put `TRUE ~` at the end to catch all.

``` r
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
```

Now we are prepared to run the population simulation. The original
Markov model relied on matrix multiplication and dot products which is
not so easy now that we’ve converted the code into a tidy data format.

The first thing to do is combine the population data frame `pop` and
transition probability matrix `p_matrix`. We can do this using the
*join* operators in dplyr. Joins are a way to match rows according to
their entries in specified columns. This is a large field, again very
important in SQL when using relational databases. I recommend checking
out the help documentation. The base R version `merge` does lots of the
same things as `*_join`.

The joined data frame looks like the following. We also `filter` the
data frame for one particular cycle and take the product of the state
populations and transition probabilities from that state.

``` r
dplyr::full_join(pop, p_matrix,
                 by = c("treatment" = "treatment",
                        "state" = "from")) |>
  filter(cycle == j - 1) |> 
  mutate(prop = val.x*val.y) 
```

Now we wish to sum up the total number of transitions in to a state. To
do this we need to specify which groups of rows to do this by using the
`group_by()` function. So we don’t include the `from` column in this
list so all from states to a particular `to` state are aggregated. How
they are aggregated is specified by `summarise()` which in this case is
`sum` but this could be any statistic plugged in here.

``` r
dplyr::full_join(pop, p_matrix,
                 by = c("treatment" = "treatment",
                        "state" = "from")) |>
  filter(cycle == j - 1) |> 
  mutate(prop = val.x*val.y) |>
  group_by(treatment, cycle, to) |>
  summarise(val = sum(prop), .groups = "keep") 
```

Finally, we need to insert these newly calculated population values in
to the `pop` data frame. We can do this with another `full_join`. The
join doesn’t overwrite the `val` column though, even though they’re
called the same thing. It creates two new columns called `val.x` and
`val.y`. However, we do want the new population `val` to be inserted
into the current list. This is something called *coalescing* and again
is something from SQL. Generally speaking, coalesce returns the first
non-empty value from a set of available values so in our case it
replaces empty `val` with values from the `val.y` column. To clean up we
just remove the `val.x` and `val.y` columns using `select` and a
negative sign in front of the names.

``` r
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
```

Clearly, this is not as elegant as the original code and is a good
example of when certain approaches are appropriate for certain jobs. The
full solutions for these exercise is in the file
`Markov_model_tidyverse.R`. Try running the whole thing and
understanding all of the new elements.
