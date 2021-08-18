#' Conflicts between the myverse packages and other packages
#'
#' This function lists all the conflicts between packages in the myverse
#' and other packages that you have loaded.
#'
#' There are four conflicts that are deliberately ignored: \code{intersect},
#' \code{union}, \code{setequal}, and \code{setdiff} from dplyr. These functions
#' make the base equivalents generic, so shouldn't negatively affect any
#' existing code.
#' @inheritParams myverse_packages
#' @export
#' @examples
#' myverse_conflicts()
myverse_conflicts <- function(cluster = NULL) {
  envs <- grep("^package:", search(), value = TRUE)
  envs <- setNames(envs, envs)
  objs <- invert(lapply(envs, ls_env))

  conflicts <- Filter(function(.x) length(.x) > 1, objs)

  tidy_names <- paste0("package:", myverse_packages(TRUE, cluster))
  conflicts <- Filter(function(.x) any(.x %in% tidy_names), conflicts)

  conflict_funs <- Map(confirm_conflict, conflicts, names(conflicts))
  conflict_funs <- conflict_funs[!!lengths(conflict_funs)]

  structure(conflict_funs, class = "myverse_conflicts")
}

myverse_conflict_message <- function(x) {
  if (length(x) == 0) return("")

  header <- cli::rule(
    left = crayon::bold("Conflicts"),
    right = "myverse_conflicts()"
  )

  pkgs <- lapply(x, function(x) gsub("^package:", "", x))
  others <- lapply(pkgs, `[`, -1)
  other_calls <- mapply(
    function(.x, .y) paste0(crayon::blue(.x), "::", .y, "()", collapse = ", "),
    others, names(others)
  )

  winner <- sapply(pkgs, `[`, 1)
  funs <- format(paste0(crayon::blue(winner), "::", crayon::green(paste0(names(x), "()"))))
  bullets <- paste0(
    crayon::red(cli::symbol$cross), " ", funs,
    " masks ", other_calls,
    collapse = "\n"
  )

  paste0(header, "\n", bullets)
}

#' @export
print.myverse_conflicts <- function(x, ..., startup = FALSE) {
  cli::cat_line(myverse_conflict_message(x))
}

confirm_conflict <- function(packages, name) {
  # Only look at functions
  objs <- lapply(packages, function(x) get(name, pos = x))
  objs <- Filter(is.function, objs)

  if (length(objs) <= 1)
    return()

  # Remove identical functions
  objs <- objs[!duplicated(objs)]
  packages <- packages[!duplicated(packages)]
  if (length(objs) == 1)
    return()

  packages
}

ls_env <- function(env) {
  x <- ls(pos = env)
  if (identical(env, "package:dplyr")) {
    x <- setdiff(x, c("intersect", "setdiff", "setequal", "union"))
  }
  x
}
