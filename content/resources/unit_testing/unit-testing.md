In this document we will learn how to use unit testing in R with the
testthat package.

### Setting up unit testing

You will need to have already set up a package containing functions to
test (in the `R/` folder). See the Workflow practical for how to do this
if you haven’t yet. In the same way that a package can be set up using
the `usethis` package helper functions we can also easily set up the
unit testing framework with this package.

From inside of your package run

``` r
usethis::use_testthat()
```

This does three things:

-   Creates a `tests/testthat directory`

-   Adds testthat to the `Suggests` field in the `DESCRIPTION`

-   Creates a file `tests/testthat.R` that runs all your tests when you
    execute `devtools::check()`

### First unit test

We will write some tests for the `p_matrix_cycle()` function which
created a transition probability matrix. Make sure that this function is
included in your package and you have run `load_all()`. To create our
first test file write

``` r
usethis::use_test("p_matrix_cycle")
```

Here, we name this file the same as our function name. This creates a
new file under `tests/ testthat` named `test-p_matrix_cycle.R`, and the
file pre-populates with an example test that we can replace.

For our first unit test, we create an object that contains the expected
results of an example function execution, and then we assess the
correctness of the output using the `testthat::expect_*` functions.

We name the overall test chunk `assess_p_matrix_cycle` - you can name
this whatever would be useful for you to read in a testing log. We first
need to provide some input values for the test.

``` r
t_names <- c("without_drug", "with_drug")
n_treatments <- length(t_names)

s_names  <- c("Asymptomatic_disease", "Progressive_disease", "Dead")
n_states <- length(s_names)

p_matrix <- array(data = 0,
                  dim = c(n_states, n_states, n_treatments),
                  dimnames = list(from = s_names,
                                  to = s_names,
                                  t_names))
# transition matrix variables
tpProg <- 0.01
tpDcm <- 0.15
tpDn <- 0.0138
effect <- 0.5
```

In this test, we evaluate if the function returns the correct type of
object, in this case, a double

``` r
test_that("assess_p_matrix_cycle", {
  res <- p_matrix_cycle(p_matrix, age = 50, cycle = 1)
  expect_type(res, "double")
})
```

There are two ways to execute the test.

-   The *Run Tests* button on the top right hand side of the testing
    script executes the tests in this script only (not all tests in the
    package), and executes this in a fresh R environment.

-   Submitting `devtools::test()` (or *Ctrl + Shift + T*) executes all
    tests in the package in your global environment.

#### Testing for errors

Next, let us test what happens when we change the ages argument. What
would we expect to happen for the following ages? It clearly makes no
sense to have someone aged -1 or 1000 years old so what should the code
do if this is the case? Error with a helpful message? Use a default
value instead and give a warning message?

``` r
test_that("assess_p_matrix_cycle", {
  res <- p_matrix_cycle(p_matrix, age = -1, cycle = 1)
  # expect_error(res)?
  # expect_warning(res)?
  # expect_message(res)?
  
  res <- p_matrix_cycle(p_matrix, age = 1000, cycle = 1)
  expect_type(res, "double")
})
```

In fact you’ll see that the function just carries on regardless without
indicating to us that anything is wrong and instead has `NA` values for
some of the probabilities. This is more obvious in the above case but
see what happens for aged 20 years old individuals.

``` r
test_that("assess_p_matrix_cycle", {
  res <- p_matrix_cycle(p_matrix, age = 20, cycle = 1)
  expect_type(res, "double")
})
```

**Why is this?**

The ages look up table only starts at 34 years old so a 20 year old is
treated the same as 1000 year old.

Let’s add in some code to `p_matrix_cycle` to catch this.

Include the following to the first line and then `load_all()` the
package.

``` r
if (age < 34) stop("age must be at between 34 and 100")
```

Now if we rerun the tests we can check that a 20 year old throws an
error and what the error message is.

``` r
test_that("assess_p_matrix_cycle", {
  res <- p_matrix_cycle(p_matrix, age = 20, cycle = 1)
  expect_error(res, regexp = "age must be at between 34 and 100")
})
```

#### Test for probabilities

`p_matrix_cycle` returns a probability matrix so let us now test that
they are indeed probabilities.

-   The first criteria is that all probabilities sum to one.

`p_matrix_cycle` returns a three dimensional array so we need to sum
across the columns to give the total probability of transitioning from a
state. The base R `apply` function can do this if we provide the
‘margins’ i.e. the dimensions to apply the function over. This should
return a matrix of all ones which we can simplify with the `c()` command
so that we can compare with what we expect.

``` r
test_that("probabilities", {
  res <- p_matrix_cycle(p_matrix, age = 40, cycle = 1)
  
  sum_from <- apply(res, MARGIN = c(1,3), sum)
  
  expect_equal(c(sum_from), rep(1, times = 6))
})
```

-   The second criteria is that each probability is between zero and
    one.

We can take advantage of how R vectorises things. If we make a logical
conditional statement on the array then R applies this element-wise so
that each probability is individually assessed and the format of the
original array is maintained. This means that if we execute `res <= 1` R
returns a 3 by 3 by 2 array of `TRUE` or `FALSE` entries. We can now
simply test if `all` of the entries are true.

``` r
test_that("probabilities", {
  res <- p_matrix_cycle(p_matrix, age = 40, cycle = 1)
  
  expect_true(all(res<=1))
  expect_true(all(res>=0))
})
```

**Notice that we could have alternatively used the same approach with
`all()` for the total probabilities summing to one. Can you see how?**

There are many more `expect_*` functions to try and you can even make
your own custom ones. Unit testing is a bit of an art and it is not
necessary to test absolutely everything although it is also not uncommon
for the unit tests to be many times longer than the code they are
testing!
