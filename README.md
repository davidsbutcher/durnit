durnit
================

This R package provides a single function, `durnit`, which takes an
input and an output directory as arguments. All Rmd files in the input
directory (or its subdirectories) are knitted to the output directory
using `rmarkdown::render` and the output format specified in each file’s
YAML frontmatter. On subsequent runs only new or modified Rmd files are
knitted.

## Installation

Install the development (and only) version from GitHub:

``` r
remotes::install_github(davidsbutcher/durnit)
```

## Usage

The package contains a single function, `durnit`, whose name is intended
to evoke the phrase “directory knit”. It accepts two arguments, which
specify the directory to search for Rmd files and the directory to save
output to:

``` r
durnit(input_dir, output_dir)
```

All Rmd files in the input directory are rendered to the output
directory using `rmarkdown::render` with the output format taken from
the YAML frontmatter. Directory structure in the input directory is
maintained, e.g. `inputdir/notebook/June-2019/lcms.Rmd` will be saved to
`outputdir/notebook/June-2019/lcms.html`.

The output directory is also checked for a file called `rmdsnapshot.rds`
containing information (time of last modification, MD5 sum, etc.) on any
Rmd files already knitted using `durnit`. If it doesn’t exist, it is
created. If it does exist, a new snapshot is compared to the existing
one and only new or modified Rmd files are knitted. The new snapshot
replaces the existing one.

## Motivation

This function was originally designed to assist in the keeping of an
electronic lab notebook as a collection of Rmd files, but could be
useful for any collection of Rmd files which need to knitted without
doing them one at a time. It is also optimized to allow it to be run
regularly (e.g. using `taskscheduleR`) to keep the output documents
up-to-date.

If you want the output document to contain the time it was last knitted,
you can use the following code, which requires `rprojroot`:

``` r
format(file.info(rprojroot::thisfile_knit())$mtime, '%B %d, %Y')
```

    ## [1] "October 08, 2019"

## To-Do List

  - Make it possible to exclude directories by name
  - Add option to not save an Rmd snapshot
  - Provide the option to knit all Rmds to a single directory, i.e. do
    not maintain subdirectory structure
  - Provide the option to delete all output files which do not
    correspond to a file in the new Rmd snapshot, e.g. deleted files
  - Add option for parallel processing by integrating `furrr` functions

## Dependencies

This package imports functions from `purrr`, `magrittr`, `rmarkdown`,
and `fs`.

## License

Creative Commons CC0
