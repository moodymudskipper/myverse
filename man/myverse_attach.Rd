% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/attach.R
\name{myverse_attach}
\alias{myverse_attach}
\title{Attach a Cluster of Packages}
\usage{
myverse_attach(cluster = NULL)
}
\arguments{
\item{cluster}{Name of the cluster to consider, by default if `getOption("myverse.pkgs")`
is a vector it's taken as is, and if it's a list, the first element
(presumably a vector) is taken.}
}
\value{
`NULL` invisibly, called for side effects
}
\description{
Attach a Cluster of Packages
}
