# Scrape ASX 30 Day Interbank Cash Rate Futures Implied Yield Target from website
install.packages(c("reticulate", "data.table", "ggplot2", "rmarkdown", "readrba"))

library(data.table)
library(reticulate)

# Set the timezone so files save with correct date
Sys.setenv(TZ = "Australia/Sydney")

py_install(c("selenium", "pandas", "bs4", "lxml"))
py <- py_run_file("R/scraper.py")

cr_futures <- setDT(py$cr_futures)

setnames(cr_futures, 
         c("Expiry Date", "Previous Settlement", "Previous Settlement Time"), 
         c("date", "cash_rate", "scrape_date"))

cr_futures <- cr_futures[, .(date, cash_rate, scrape_date)]

print(cr_futures)
str(cr_futures)

cr_futures[, cash_rate := gsub("^(.*)As of \\d+/\\d+/\\d+", "\\1", cash_rate)]
cr_futures[, cash_rate := trimws(cash_rate)]
cr_futures[, scrape_date := gsub("As of (\\d+/\\d+/\\d+)", "\\1", scrape_date)]
cr_futures[, date := as.IDate(paste0("01 ", date), format = "%d %b %y")]
cr_futures[, scrape_date := as.IDate(scrape_date, format = "%d/%m/%y")]
cr_futures[, cash_rate := 100 - as.numeric(cash_rate)]
cr_futures[, cash_rate := round(cash_rate, 2)]
cr_futures <- cr_futures[!is.na(cash_rate)]

# Write a CSV of today's data
fwrite(cr_futures, file.path("daily-data", paste0("scraped_cash_rate_", Sys.Date(), ".csv")))
fwrite(cr_futures, file.path("latest-data", paste0("scraped_cash_rate_latest.csv")))

# Load existing data, combine with latest data
all_data <- fread(file.path("combined-data", "all_data.csv"))
all_data <- rbindlist(list(all_data, cr_futures))

# Remove duplicated scrape dates
all_data <- unique(all_data, by = c("date", "scrape_date"))

# Automatically fix any gaps in the series from failed scrapes with last obs
# carried forward. Only do this for the past week to avoid changing historical
# data where the old series might not extend as far into the future
all_dates <- seq.Date(from = min(all_data$scrape_date), to = max(all_data$scrape_date), by = "1 day")
all_dates <- CJ(scrape_date = all_dates, date = all_data[scrape_date == max(scrape_date), date])
all_data <- all_data[all_dates, on = .(date, scrape_date)]
all_data <- all_data[!is.na(cash_rate) | scrape_date >= Sys.Date() - 7]
all_data[, cash_rate := nafill(cash_rate, "locf"), by = .(date)]

fwrite(all_data, file = file.path("combined-data", "all_data.csv"))
