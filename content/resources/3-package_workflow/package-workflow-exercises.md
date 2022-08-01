# Exercises: R Project workflow

## Create a project

We are going to create an R project from scratch and then practise the
“lather, rinse, repeat” workflow.

First things first, we need to name our package. There are three formal
requirements:

-   The name can only consist of letters, numbers, and periods, i.e., ..
-   It must start with a letter.
-   It cannot end with a period.

**Choose a name by first checking with the [available
package](https://cran.r-project.org/web/packages/available/index.html).**

``` r
# install if required
library(available)

# choose your own name e.g.
available("HTAmodel")
```

**Explore what names can and can’t be used for packages**

## Package creation

There’s more than one way of creating a package in R. To start we will
use the `usethis` package.

``` r
usethis::create_package(path = "HTAmodel")
```

An extension to `create_package()` exists called
`create_tidy_package()`.

**Have a look and see what the difference is between these two using the
help document.**

An alternative to making a full blown R package is to make an R
*project*. You can do this as follows

``` r
usethis::create_project(path = "HTAproject")
```

**Create an R project and see what the difference between a project and
package is by looking at the folder structure. When do you think using
one over the other is a good idea?**

An alternative may to create an R package is via the RStudio menus and
the new project Wizard

*File \> New Project \> Existing or New Directory\> R Package*

**Try this out**

You can now launch your new R project by double-clicking on the `.Rproj`
file or selecting it in the *File \> Open Project* drop down menu in
RStudio.

(N.B. You can set up a launcher app to find `.Rproj` files too to make
things even more efficient (e.g [Alfred in
macOS](https://www.alfredapp.com/)).)

When you open a `.Rproj` this will open the package with the working
directly of you package folder. You can set the package options to
automatically load data or open scripts for you. It can also save your
history and other things when you exit. I prefer to turn all of this off
so that the session starts from scratch each time and it is more
reproducable.

Got to *Tools \> Project Options \>* to see the different options
available.

These can be set individually for each package or as default for all
packages.

## Package development

The key package for creating packages is `usethis` and for package
development it is `devtools`. In particular

``` r
devtools::load_all()
```

`load_all()` roughly simulates what happens when a package is installed
and loaded with library() except it is your own package during the
development stage. This is really useful for seeing the effect of
incremental changes on your code e.g. you can pick up errors early.

You can mimics what it would be like if someone else were to load your
package.

There are 3 ways to use `load_all`. Try out each one:

-   Keyboard shortcut: *Cmd+Shift+L* (macOS), *Ctrl+Shift+L* (Windows,
    Linux)
-   Build pane’s *More* … menu
-   Drop down menu *Build \> Load All*

To test this out we will make some changes to your skeleton package.

**Copy the `ce_markov.R` file from the exercises package-workflow folder
into the `R/` folder of your package and run `load_all()`**

The `R/` folder is where all of your package functions should live. Now
open the `ce_markov.R` file to and we will automatically create some
documentation using the roxygen syntax. We can do this by using the drop
down menu

*Code \> Insert Roxygen Skeleton*

The keyboard short cut for this is *Ctrl_Alt+Shift+R*

This will create a basic function documentation (more on this later!).
Now we want to create the help file documentation using the roxygen code
we’ve just created. This is done with the

``` r
devtools::document()
```

Alternatively, you can use the drop down menu

*Build \> Document*

or the short cut keys

*Ctrl + Shift + D*

If you now look in the *Files* pane in RStudio you will see a new folder
called `man`. This contains the automatically generated help file
documents in `.Rd` format. If you open up `ce_markov.Rd` you will see
what this type of file looks like. Notice that it says *do not edit by
hand*. If you did then this would only get written over when you run
`load_all()` again.

Every time you run `load_all()` R will check the function for you. Every
time you run `document()` R will update the function documentation for
you.

You can see the help documenation in the *Help* panel by typing

``` r
?ce_markov
```

**Practise changing the roxygen in the function script and running
through the workflow.**

**You could also create a new function and do the same steps.**
