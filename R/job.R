# Scrape ASX 30 Day Interbank Cash Rate Futures Implied Yield Target from website

library(data.table)
library(rvest)
library(RSelenium)

# Set the timezone so files save with correct date
Sys.setenv(TZ = "Australia/Sydney")

rD <- rsDriver(browser = "chrome")

# Assign the client to an object
remDr <- rD[["client"]]

remDr$navigate("https://www.asx.com.au/markets/trade-our-derivatives-market/derivatives-market-prices/short-term-derivatives")
pg_source <- remDr$getPageSource()[[1]]

cr_futures <-
  read_html(pg_source) |> 
  html_elements(xpath = "/html/body/div[1]/div/div[3]/div/div[1]/div/div/section/section/div[2]/div/div[4]/div[1]/table") |> 
  html_table()

cr_futures <- setDT(cr_futures[[1]])

setnames(cr_futures, c("Expiry Date", "Previous Settlement", "Previous Settlement Time"), c("date", "cash_rate", "scrape_date"))

cr_futures <- cr_futures[, .(date, cash_rate, scrape_date)]

cr_futures[, cash_rate := gsub("^(.*)As of \\d+/\\d+/\\d+", "\\1", cash_rate)]
cr_futures[, cash_rate := trimws(cash_rate)]
cr_futures[, scrape_date := gsub("As of (\\d+/\\d+/\\d+)", "\\1", scrape_date)]
cr_futures[, date := as.IDate(paste0("01 ", date), format = "%d %b %y")]
cr_futures[, scrape_date := as.IDate(scrape_date, format = "%d/%m/%y")]
cr_futures[, cash_rate := 100 - as.numeric(cash_rate)]

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
