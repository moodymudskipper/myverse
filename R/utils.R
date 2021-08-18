msg <- function(..., startup = FALSE) {
  if (startup) {
    if (!isTRUE(getOption("myverse.quiet"))) {
      packageStartupMessage(text_col(...))
    }
  } else {
    message(text_col(...))
  }
}

text_col <- function(x) {
  # If RStudio not available, messages already printed in black
  if (!rstudioapi::isAvailable()) {
    return(x)
  }

  if (!rstudioapi::hasFun("getThemeInfo")) {
    return(x)
  }

  theme <- rstudioapi::getThemeInfo()

  if (isTRUE(theme$dark)) crayon::white(x) else crayon::black(x)

}

#' List all packages in the myverse
#'
#' @param include_self Include tidyverse in the list?
#' @param cluster Name of the cluster to consider, by default if `getOption("myverse.pkgs")`
#'   is a vector it's taken as is, and if it's a list, the first element
#'   (presumably a vector) is taken.
#' @export
#' @examples
#' myverse_packages()
myverse_packages <- function(include_self = TRUE, cluster = NULL) {
  pkgs <- getOption("myverse.pkgs")
  if(is.null(cluster)) {
    if(is.list(pkgs)) pkgs <- pkgs[[1]]
  } else {
    if(is.list(pkgs)) {
      pkgs <- pkgs[[cluster]]
    } else {
      stop("`getOption(\"myverse.pkgs\")` should be a character vector or a list of character vectors")
    }
  }

  if (include_self) {
    pkgs <- c(pkgs, "myverse")
  }

  pkgs
}


invert <- function(x) {
  if (length(x) == 0) return()
  stacked <- utils::stack(x)
  tapply(as.character(stacked$ind), stacked$values, list)
}


style_grey <- function(level, ...) {
  crayon::style(
    paste0(...),
    crayon::make_style(grDevices::grey(level), grey = TRUE)
  )
}
