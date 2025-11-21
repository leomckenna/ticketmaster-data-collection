# Install remotes if not already installed
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = "http://cran.us.r-project.org")
}

# Install specific versions
remotes::install_version("caret", version = "7.0.1", repos = "http://cran.us.r-project.org")
remotes::install_version("tidyverse", version = "2.0.0", repos = "http://cran.us.r-project.org")