import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import StaleElementReferenceException
from bs4 import BeautifulSoup
import pandas as pd
import time

login_email = 'your-email'
login_password = 'your-password'

# open chromedriver
chrome_options = Options()
chrome_options.add_argument("--headless=new")  # Use the new headless mode
chrome_options.add_argument("--disable-gpu")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")

driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
time.sleep(2)

# navigate to login page
driver.get('https://database.coffeeinstitute.org/login')
time.sleep(3)

# submit login credentials
username = driver.find_element('name', "username")
password = driver.find_element('name', "password")
time.sleep(2)

username.send_keys(login_email)
password.send_keys(login_password)
driver.find_element('class name', "submit").click()
time.sleep(2)

# navigate to coffees page, then to robusta page containing links to all quality reports
driver.get('https://database.coffeeinstitute.org/coffees')  # Using direct URL for faster navigation
time.sleep(10)
driver.find_element('link text', 'Robusta Coffees').click()
time.sleep(3)

# these values can be changed if this breaks midway through collecting data to pick up close to where you left off
page = 0
coffeenum = 0

while True:
    print(f'page {page}')

    # 50 rows in these tables * 7 columns per row = 350 cells. Every 7th cell clicks through to that coffee's data page
    for i in range(1, 400, 8):
        time.sleep(2)

        # paginate back to the desired page number
        # don't think there's a way around this - the back() option goes too far back
        # some page numbers aren't available in the ui, but 'next' always is unless you've reached the end
        for p_num in range(page):
            try:
                page_buttons = WebDriverWait(driver, 10).until(
                    EC.presence_of_all_elements_located((By.CLASS_NAME, 'paginate_button'))
                )
                next_button = page_buttons[-1]  # Select the 'next' button
                next_button.click()  # Click the 'next' button
                time.sleep(1)
            except StaleElementReferenceException:
                print("Stale element reference. Retrying...")
                continue
            except Exception as e:
                print(f"Error during pagination: {e}")
                break

        # select the cell to click through to the next coffee-data page
        time.sleep(2)  # Increase time buffer to prevent errors
        try:
            test_page = driver.find_elements('xpath', '//td')[i]
            test_page.click()
        except Exception as e:
            print(f"Error clicking coffee cell: {e}")
            continue

        time.sleep(2)
        print('rows: ')
        print(len(driver.find_elements('xpath', "//tr")))
        tables = driver.find_elements(By.TAG_NAME, "table")

        # loop over all coffee reports on the page, processing each one and writing to csv
        print('tables: ')
        print(len(tables))
        j = 0
        for tab in tables:
            try:
                t = BeautifulSoup(tab.get_attribute('outerHTML'), "html.parser")
                df = pd.read_html(str(t))
                name = f'coffee_{coffeenum}_table_{j}.csv'
                df[0].to_csv(name)
                print(name)
            except Exception as e:
                print(f'ERROR: {name} failed. Exception: {e}')
            j += 1

        # go back to page with all other coffee results
        driver.get('https://database.coffeeinstitute.org/coffees/robusta')
        time.sleep(2)
        coffeenum += 1

    page += 1
    if page == 6:
        break

# close the driver
driver.close()