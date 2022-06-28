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
  magick::image_crop(full_image, geometry = geometry_area(width = 870 * 3.1,
                                              height = 38 * 3.1,
                                              x_off = 168 * 3.1,
                                              y_off = 650 * 3.1))
table_image <- image_quantize(table_image, colorspace = "gray")
table_image <- image_transparent(table_image, color = "white", fuzz = 48)

# Extract the characters from the image
strings <- ocr(table_image)
strings <- str_split(strings, pattern = "\n")
strings <- unlist(strings)

strings <- strings[strings != ""]

string_list <- lapply(strings, function(x) unlist(str_split(x, " ")))

new_data <- as.data.table(string_list, col.names = c("date", "cash_rate"))
new_data[, scrape_date := Sys.Date()]
new_data[, date := as.Date(paste0("01-", date), "%d-%b-%y")]

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
fwrite(new_data, file.path("daily-data",
                              paste0("scraped_cash_rate_", Sys.Date(), ".csv")),
          row.names = FALSE)
fwrite(new_data, file.path("latest-data",
                              paste0("scraped_cash_rate_latest.csv")),
          row.names = FALSE)

# Load all existing data, combine with latest data
all_data <- list.files(file.path("daily-data"), pattern = ".csv", full.names = TRUE)
all_data <- lapply(all_data, function(x) fread(x, colClasses = c("Date", "numeric", "Date")))
all_data <- rbindlist(all_data)

# Remove duplicated scrape dates
all_data <- unique(all_data, by = c("date", "scrape_date"))

fwrite(all_data, file = file.path("combined-data", "all_data.csv"))
