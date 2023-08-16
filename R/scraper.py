from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.chrome import ChromeType
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
import pandas as pd
from bs4 import BeautifulSoup
import lxml

chrome_service = Service(ChromeDriverManager(chrome_type=ChromeType.CHROMIUM).install())

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

driver = webdriver.Chrome(service=chrome_service, options=chrome_options)
# driver.implicitly_wait(0) # seconds

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
    cr_futures = pd.read_html(str(table))[0]
  
  # Terminate the loop if we get a table with data in it
  if cr_futures.index.size > 0:
    not_empty = True
    
  # Terminate the loop if it runs too many times
  if i > 100:
    not_empty = True
