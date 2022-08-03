# Exercises: Clean code

This practical will introduce you to the idea of clean code and provide
practise in apply its principles.

## Judging clean code

Open up the file `unclean.R` from the workshop folder 2-clean code. Skim
through the code and identify what you thing could be improved or what
looks similar to how you would normally write code.

Now, going through each of these clean code principle below highlight
lines of code that you think could be ‘cleaner’.

-   Reproducability
    -   Code that may work on ones person computer but not on another or
        not work in the future.
-   Naming
    -   Ambiguous names: is is clear what things are?
    -   Can a name mean more than one thing?
    -   Is the name consistent?
    -   Is there any unnecessary information?
-   Spacing
    -   What are the spacing conventions?
    -   Is the code easy to read?

## Lintr

Lint, or a linter, is a static code analysis tool used to flag
programming errors, bugs, stylistic errors and suspicious constructs.

We will use the `lintr` package to lint this code.

``` r
# install if needed
library(lintr)

lint("unclean.R")
```

A new tab will open in the *Console* part of the screen with a list of
issue found by `lintr`. See if you agree.

This is just one suggested style guide. A popular style is provided by
tidyverse <http://style.tidyverse.org/>. There is no definitive style
but code should be consistent.

RStudio also has some features to prettify your code.

In *Code \> Reformat Lines* (short cut *Ctrl+I*) or *Code \> Reformat
Code* (short cut *Ctrl+Shift+A*) you can quickly clean some code. This
is useful if you’ve inherited someone else’s code and want to quickly
improve its style so that you can understand whats going on.
