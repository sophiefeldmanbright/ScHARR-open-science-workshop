# Debugging in R

## Introduction

In this practical we will introduce and practise basic debugging in R
and RStudio. We will use the cost-effectiveness Markov model code to
demonstrate this.

Open up the scripts `debugging_script.R` run it.

We want to use the ‘broken’ functions for this practical so we will
first source the files `ce_markov_debug1.R` and `p_matrix_cycle.R` by
running

``` r
source("ce_markov_debug1.R")
source("p_matrix_cycle.R")
```

Make sure this point to the correct folder for you.

This is the main script from which to run the analysis which calls our
functions. You should get the following error

    Error in cycle_state_costs[i, ] <- (state_c_matrix[treatment = i, ] %*%  : 
      number of items to replace is not a multiple of replacement length

Lets investigate…

## Using `debug()`

The functions `browser()` and `debug()` are simple to use and very
powerful at identifying the source of an error.

`debug()` works by telling R to enter the debugger at the first line
whenever a given function is called.

``` r
debug(ce_markov)
```

This breakpoint on the first line will remain until you remove it with

``` r
undebug(ce_markov)
```

Sometimes you just want to run the debugger a single time and so instead
use

``` r
debugonce(ce_markov)
```

Now run

``` r
ce_res <- ce_markov(start_pop = c(n_pop, 0, 0),
                    p_matrix,
                    state_c_matrix,
                    trans_c_matrix,
                    state_q_matrix)
```

The GUI will show you the `ce_markov()` script with the body of the
function highlighted. A green arrow on the left hand side will point at
the first line of the code. This indicated where the debugger has
stopped at and hasn’t executed any of the lines below it.

Execute the next line of code by either pressing `n` or `Enter` or *F10*
or clicking on the *Next* button.

Notice in the Environment pane that the values are for those passed to
the function.

If you ‘step through’ the code by pressing *Next* a few more times you
will see the Environment variable being up dated as the highlighted code
moved down line by line.

When you get to the `for (j in 2:n_cycles)` loop you’ll notice that
pressing *Next* takes you around every iteration. If you want to fast
forward and leave the loop having run all iterations in one step then
you can “step out” of the loop with *Shift+F7*.

**Which line does the error occur at?**

The `debug()` function is pretty cool because it can also show you the
insides of other people’s functions.

For example, try

``` r
debugonce(mean)
mean(c(1,2,"three"))
```

This will send you to the `mean.default` method

``` r
function (x, trim = 0, na.rm = FALSE, ...) 
{
  if (!is.numeric(x) && !is.complex(x) && !is.logical(x)) {
    warning("argument is not numeric or logical: returning NA")
    return(NA_real_)
  }
  if (isTRUE(na.rm)) 
    x <- x[!is.na(x)]
  if (!is.numeric(trim) || length(trim) != 1L) 
    stop("'trim' must be numeric of length one")
  n <- length(x)
  if (trim > 0 && n) {
    if (is.complex(x)) 
      stop("trimmed means are not defined for complex data")
    if (anyNA(x)) 
      return(NA_real_)
    if (trim >= 0.5) 
      return(stats::median(x, na.rm = FALSE))
    lo <- floor(n * trim) + 1
    hi <- n + 1 - lo
    x <- sort.int(x, partial = unique(c(lo, hi)))[lo:hi]
  }
  .Internal(mean(x))
}
```

**Have a look inside some other functions in the same way.**

## Using `browser()`

Every time you use `debug()` it starts at the first line of the
function. Now that we have identified where the error is thrown, or if
you had an idea beforehand anyway, you don’t want to step through all
the code to get to the interesting bit. In this case you can use the
browser()\` function.

Simply write `browser()` on the line where you want the break point to
be. Include `browser()` in a sensible place in `ce_markov()` and rerun
the function. Once the break point has been activated you can step
through the code in the same way as before. Don’t forget to re-source
the function to tell R that you have included new code.

#### Editor break points

A further way that you can include break points is interactively by left
clicking the margin of the Editor pane to the left of the row numbers.
You’ll see that a red dot appears and this is equivalent to the
`browser()` function at this line.

You can have multiple break points through out the code and when you
continue running the code after one break point (pressing `c` or
*Shift+F5*) then the code execution stops at the next one.

**Try using multiple break points, setting them via the Editor**

#### Stepping *in to* functions

Run `ce_markov()` again with `debugonce()`. We may have a suspicion that
`p_matrix_cycle` is responsible for something going wrong. We could add
multiple break point as above with one inside of `p_matrix_cycle`.
Alternatively, when we get to this line of code in `ce_markov()` we can
“step in to” the function pressing `s` or *Shift+F4*. This is like
taking us one layer down into the code.

**Try this stepping in to `p_matrix_cycle` from `ce_markov`. You can
also step in to base R functions.**

## Conditional break points

As was the case against using `debug()` we don’t want to be stepping
through loads of code to get to the point where the error occurs or
where we think that the problem originated in the code.

We can further refine our use of break points by only entering the
debugger when a certain condition is met. This is commonly when a loop
is at a certain (large number) of iterations.

It will look something like this

``` r
if <CONDITIONAL STATEMENT> browser()
```

**Include a conditional breakpoint in the `ce_markov()` function for
when the number of cycles is over 20**

## But where is the bug?

If we go back to the original error message

    Error in cycle_state_costs[i, ] <- (state_c_matrix[treatment = i, ] %*%  : 
      number of items to replace is not a multiple of replacement length

This is telling us that the dimensions of `cycle_state_costs` and the
result of the right hand side don’t match.

Let us first see what these dimensions are. Add a break point just
before this line and then type

``` r
dim(state_c_matrix[treatment = i, ] %*% pop[, , treatment = i])
dim(cycle_state_costs[i, ])
cycle_state_costs[i, ]
```

It appears that the object of length 2 is being assigned 46 entries. If
we look at the full matrix

``` r
cycle_state_costs
```

we see that this has 46 rows which is a remarkable coincidence. We can
hypothesise that the rows and columns have gotten mixed up somewhere
along the way earlier in the code and the error is thrown later on when
we try to use these objects.

If we search for `cycle_state_costs` we see that it is initiated with
`cycle_empty_array`. This is the culprit. We can see that the `dim`
argument has the order cycle, treatment but the `dimnames` argument has
the order treatment, cycle. Swapping `dim = c(n_treat, n_cycles)` should
fix the error. This is a relatively easy bug to fix because we can spot
the inconsistency in the code. Some bugs can be particularly difficult
to catch but using the debugger to hone in and probe inside of the code
can be invaluable.
