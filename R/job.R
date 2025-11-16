# Scrape ASX 30 Day Interbank Cash Rate Futures Implied Yield Target from website
install.packages(c("reticulate", "data.table", "ggplot2", "rmarkdown", "readrba", "ggrepel"))

library(data.table)
library(reticulate)

# Set the timezone so files save with correct date
Sys.setenv(TZ = "Australia/Sydney")

# Run Python script to scrape the data and save results to csv
py_require(
  packages = c(
    "selenium",
    "pandas",
    # bs4 is the import name, but PyPI package is beautifulsoup4:
    "beautifulsoup4",
    "lxml"
  ),
  python_version = "3.11"  # or whatever you want
)
py <- py_run_file("R/scraper.py")

# Load existing data, combine with latest data
cr_futures <- fread(file.path("latest-data", "scraped_cash_rate_latest.csv"))
all_data <- fread(file.path("combined-data", "all_data.csv"))
all_data <- rbindlist(list(all_data, cr_futures))

# Remove duplicated scrape dates
all_data <- unique(all_data, by = c("date", "scrape_date"))

# Automatically fix any gaps in the series from failed scrapes with last obs
# carried forward. Only do this for the past week to avoid changing historical
# data where the old series might not extend as far into the future
all_dates <- seq.Date(from = min(all_data$scrape_date), to = max(all_data$scrape_date), by = "1 day")
all_dates <- CJ(scrape_date = all_dates, date = unique(all_data$date))
all_data <- all_data[all_dates, on = .(date, scrape_date)]
all_data <- all_data[!is.na(cash_rate) | scrape_date >= Sys.Date() - 7]
all_data[, cash_rate := nafill(cash_rate, "locf"), by = .(date)]

fwrite(all_data, file = file.path("combined-data", "all_data.csv"))