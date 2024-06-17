from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
import pandas as pd
from bs4 import BeautifulSoup
import lxml
from io import StringIO
import os
from datetime import datetime

chrome_options = Options()
options = [
  "--headless",
  "--disable-gpu",
  "--window-size=1920,1200",
  "--ignore-certificate-errors",
  "--disable-extensions",
  "--no-sandbox",
  "--disable-dev-shm-usage"
]
for option in options:
  chrome_options.add_argument(option)

driver = webdriver.Chrome(service=Service(), options=chrome_options)

# Run this in a loop until the table loads because sometimes it doesn't
not_empty = False
i = 0

while not_empty == False:
  # Navigate to the URL
  url = 'https://www.asx.com.au/markets/trade-our-derivatives-market/derivatives-market-prices/short-term-derivatives'
  driver.get(url)

  # Extract the page source
  pg_source = driver.page_source
  
  # Parse the HTML using BeautifulSoup
  soup = BeautifulSoup(pg_source, 'html.parser')
  
  # Find the table containing the data
  table = soup.find('table')
  
  i += 1
  print("Iteration", i)
  print(type(table).__name__)
  
  cr_futures = pd.DataFrame()
  
  if type(table).__name__ != "NoneType":
    # Read the table data into a pandas DataFrame
    cr_futures = pd.read_html(StringIO(str(table)))[0]
  
  # Terminate the loop if we get a table with data in it
  if cr_futures.index.size > 0:
    not_empty = True
    
  # Terminate the loop if it runs too many times
  if i > 100:
    not_empty = True

driver.quit()

# Keep only useful columns
cr_futures = cr_futures[['Expiry Date', 'Previous Settlement', 'Previous Settlement Time']]

# Rename columns
cr_futures = cr_futures.rename(columns={'Expiry Date': 'date', 'Previous Settlement': 'cash_rate', 'Previous Settlement Time': 'scrape_date'})

# Clean up the data
cr_futures['cash_rate'] = cr_futures['cash_rate'].str.replace(r'^(.*)As of \d+/\d+/\d+', r'\1', regex=True).str.strip()
cr_futures['scrape_date'] = cr_futures['scrape_date'].str.replace(r'As of (\d+/\d+/\d+)', r'\1', regex=True)
cr_futures['date'] = pd.to_datetime(cr_futures['date'].apply(lambda x: f"01 {x}"), format="%d %b %y")
cr_futures['scrape_date'] = pd.to_datetime(cr_futures['scrape_date'], format="%d/%m/%y")
cr_futures['cash_rate'] = 100 - pd.to_numeric(cr_futures['cash_rate'])
cr_futures['cash_rate'] = cr_futures['cash_rate'].round(2)
cr_futures = cr_futures.dropna(subset=['cash_rate'])

## Save to file

# Get today's date in YYYY-MM-DD format
today_date = datetime.today().strftime('%Y-%m-%d')

# Create file paths
daily_data_path = os.path.join("daily-data", f"scraped_cash_rate_{today_date}.csv")
latest_data_path = os.path.join("latest-data", "scraped_cash_rate_latest.csv")

# Write the DataFrame to CSV files
cr_futures.to_csv(daily_data_path, index=False)
cr_futures.to_csv(latest_data_path, index=False)
