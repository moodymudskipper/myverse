#' Update myverse packages
#'
#' This will check to see if all myverse packages (and optionally, their
#' dependencies) are up-to-date, and will install after an interactive
#' confirmation.
#'
#' @inheritParams myverse_deps
#' @inheritParams myverse_packages
#' @export
#' @examples
#' \dontrun{
#' tidyverse_update()
#' }
myverse_update <- function(recursive = FALSE, repos = getOption("repos"), cluster = NULL) {

  deps <- myverse_deps(recursive, repos, cluster)
  behind <- subset(deps, behind)

  if (nrow(behind) == 0) {
    cli::cat_line("All tidyverse packages up-to-date")
    return(invisible(NULL))
  }

  cli::cat_line("The following packages are out of date:")
  cli::cat_line()
  cli::cat_bullet(format(behind$package), " (", behind$local, " -> ", behind$cran, ")")

  cli::cat_line()
  cli::cat_line("Start a clean R session then run:")

  pkg_str <- paste0(deparse(behind$package), collapse = "\n")
  cli::cat_line("install.packages(", pkg_str, ")")

  invisible(NULL)
}

#' Get a situation report on the myverse
#'
#' This function gives a quick overview of the versions of R and RStudio as
#' well as all myverse packages. It's primarily designed to help you get
#' a quick idea of what's going on when you're helping someone else debug
#' a problem.
#'
#' @inheritParams myverse_packages
#' @export
myverse_sitrep <- function(cluster = NULL) {
  cli::cat_rule("R & RStudio")
  if (rstudioapi::isAvailable()) {
    cli::cat_bullet("RStudio: ", rstudioapi::getVersion())
  }
  cli::cat_bullet("R: ", getRversion())

  deps <- myverse_deps(cluster)
  package_pad <- format(deps$package)
  packages <- ifelse(
    deps$behind,
    paste0(cli::col_yellow(cli::style_bold(package_pad)), " (", deps$local, " < ", deps$cran, ")"),
    paste0(package_pad, " (", deps$cran, ")")
  )

  cli::cat_rule("packages")
  cli::cat_bullet(packages)
}

#' List all tidyverse dependencies
#'
#' @param recursive If \code{TRUE}, will also list all dependencies of
#'   tidyverse packages.
#' @param repos The repositories to use to check for updates.
#'   Defaults to \code{getOption("repos")}.
#' @inheritParams myverse_packages
#' @export
myverse_deps <- function(recursive = FALSE, repos = getOption("repos"), cluster = NULL) {
  pkgs <- utils::available.packages(repos = repos)
  deps <- lapply(myverse_packages(FALSE, cluster), tools::package_dependencies, pkgs, recursive = recursive)

  pkg_deps <- unique(sort(unlist(deps)))

  base_pkgs <- c(
    "base", "compiler", "datasets", "graphics", "grDevices", "grid",
    "methods", "parallel", "splines", "stats", "stats4", "tools", "tcltk",
    "utils"
  )
  pkg_deps <- setdiff(pkg_deps, base_pkgs)

  tool_pkgs <- c("cli", "crayon", "rstudioapi")
  pkg_deps <- setdiff(pkg_deps, tool_pkgs)

  cran_version <- lapply(pkgs[pkg_deps, "Version"], base::package_version)
  local_version <- lapply(pkg_deps, packageVersion)

  behind <- mapply(`>`, cran_version, local_version)

  data.frame(
    package = pkg_deps,
    cran = sapply(cran_version, as.character),
    local = sapply(local_version, as.character),
    behind = behind
  )
}

packageVersion <- function(pkg) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    utils::packageVersion(pkg)
  } else {
    0
  }
}
