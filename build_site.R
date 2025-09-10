#!/usr/bin/env Rscript

if (!requireNamespace("quarto", quietly = TRUE)) {
  install.packages("quarto")
}
library(quarto)

# Make script work whether run with source() or Rscript
script_path <- if (!is.null(sys.frame(1)$ofile)) {
  normalizePath(sys.frame(1)$ofile)  # when called via source()
} else {
  # when run via Rscript
  ca <- commandArgs(trailingOnly = FALSE)
  normalizePath(sub("^--file=", "", ca[grep("^--file=", ca)][1]))
}
setwd(dirname(script_path))

# Sanity check that the Quarto binary exists
stopifnot(quarto::quarto_binary_sitrep())

# Decide what to render: a project or a single file
# Option 1: Render a project (requires _quarto.yml in getwd())
if (file.exists("_quarto.yml") || file.exists("_quarto.yaml")) {
  system2(quarto::quarto_path(), c("render", "."), wait = TRUE)
} else if (file.exists("index.qmd")) {
  # Option 2: Render a single file
  system2(quarto::quarto_path(), c("render", "index.qmd"), wait = TRUE)
} else {
  stop("Neither _quarto.yml nor index.qmd found in the working directory.")
}

# Only add docs if it exists (project render with output-dir: docs)
if (dir.exists("docs")) {
  system2("git", c("add", "docs"))
}