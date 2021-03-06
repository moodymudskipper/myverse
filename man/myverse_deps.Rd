% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/update.R
\name{myverse_deps}
\alias{myverse_deps}
\title{List all tidyverse dependencies}
\usage{
myverse_deps(recursive = FALSE, repos = getOption("repos"), cluster = NULL)
}
\arguments{
\item{recursive}{If \code{TRUE}, will also list all dependencies of
tidyverse packages.}

\item{repos}{The repositories to use to check for updates.
Defaults to \code{getOption("repos")}.}

\item{cluster}{Name of the cluster to consider, by default if `getOption("myverse.pkgs")`
is a vector it's taken as is, and if it's a list, the first element
(presumably a vector) is taken.}
}
\description{
List all tidyverse dependencies
}
