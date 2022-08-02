# Scrape ASX 30 Day Interbank Cash Rate Futures Implied Yield Target from PDF

library(data.table)
library(stringr)
library(tesseract)
library(magick)

# Set the timezone so files save with correct date
Sys.setenv(TZ = "Australia/Sydney")

# Download PDF from the ASX
pdf_url <- "https://www.asx.com.au/data/trt/ib_expectation_curve_graph.pdf"
pdf_path <- tempfile(fileext = ".pdf")
download.file(pdf_url, pdf_path, mode = "wb")

# Note that the table in the PDF appears to be part of an image, rather than a
# normal PDF table. This means we need to use optical character recognition to
# extract it

# Read the PDF as an image, crop it, and remove gridlines
full_image <- image_read_pdf(pdf_path)

table_image <- 
  magick::image_crop(full_image, geometry = geometry_area(
    width = 880 * 3.1,
    height = 38 * 3.1,
    x_off = 175 * 3.1,
    y_off = 642 * 3.1
    ))
table_image <- image_quantize(table_image, colorspace = "gray")
table_image <- image_transparent(table_image, color = "white", fuzz = 55)

# Extract the characters from the image
strings <- ocr(table_image)
strings <- str_split(strings, pattern = "\n")
strings <- unlist(strings)

strings <- strings[strings != ""]

string_list <- lapply(strings, function(x) unlist(str_split(x, " ")))

print(string_list)

new_data <- as.data.frame(string_list, col.names = c("date", "cash_rate"))
setDT(new_data)[, scrape_date := Sys.Date()]
new_data[, date := as.IDate(paste0("01-", date), "%d-%b-%y")][, scrape_date := as.IDate(scrape_date)]

# The decimal point is not always picked up; add it in
# Note we are assuming all future cash rates are <10%
new_data[, cash_rate := ifelse(
  str_sub(cash_rate, 2, 2) == ".",
  cash_rate,
  paste0(
    str_sub(cash_rate, 1, 1),
    ".",
    str_sub(cash_rate, 2L, -1L)
  )
)]

new_data[, cash_rate := as.numeric(cash_rate)]

# Write a CSV of today's data
fwrite(new_data, file.path("daily-data", paste0("scraped_cash_rate_", Sys.Date(), ".csv")))
fwrite(new_data, file.path("latest-data", paste0("scraped_cash_rate_latest.csv")))

# Load existing data, combine with latest data
all_data <- fread(file.path("combined-data", "all_data.csv"))
all_data <- rbindlist(list(all_data, new_data))

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
