import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import StaleElementReferenceException, TimeoutException
from bs4 import BeautifulSoup
import pandas as pd
import time

login_email = 'doerschtessa@gmail.com'
login_password = 'Denali05061999!!'

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

# navigate to coffees page, then to arabicas page containing links to all quality reports
driver.get('https://database.coffeeinstitute.org/coffees')  # Using direct URL for faster navigation
time.sleep(10)

# Debugging: Let's check if we can find any pagination button
try:
    page_buttons = driver.find_elements(By.CLASS_NAME, 'paginate_button')
    if len(page_buttons) == 0:
        print("No pagination buttons found, trying an alternative method...")
    else:
        print(f"Found {len(page_buttons)} pagination buttons.")
except Exception as e:
    print(f"Error finding pagination buttons: {e}")

# Navigate to 'Robusta Coffees' page
driver.find_element('link text', 'Robusta Coffees').click()
time.sleep(3)

coffeenum = 0

# Retry mechanism to locate pagination buttons reliably
try:
    print("Waiting for pagination buttons to load...")
    page_buttons = WebDriverWait(driver, 30).until(  # Increased timeout to 30 seconds
        EC.presence_of_all_elements_located((By.CLASS_NAME, 'paginate_button'))
    )
    print(f"Found {len(page_buttons) - 1} pages.")  # Excluding 'next' button
    total_pages = len(page_buttons) - 1  # Subtract 1 because the last button is usually for 'next'
except TimeoutException:
    print("Timeout while waiting for pagination buttons. Check if the page loaded correctly.")
    driver.quit()
    exit()

# Loop over the total number of pages dynamically
for page in range(total_pages):
    print(f"Processing page {page + 1} of {total_pages}")

    # Click on the "next" button until you reach the desired page
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

    # Now process the coffee rows on the page
    for i in range(1, 400, 8):  # Adjust the range as needed for your table structure
        time.sleep(2)  # Add a buffer before clicking the coffee cell
        try:
            test_page = driver.find_elements('xpath', '//td')[i]
            test_page.click()
        except Exception as e:
            print(f"Error clicking coffee cell: {e}")
            continue

        time.sleep(2)  # Wait for the coffee page to load
        print('rows: ')
        print(len(driver.find_elements('xpath', "//tr")))

        tables = driver.find_elements(By.TAG_NAME, "table")
        print('tables: ')
        print(len(tables))

        # Loop over all tables and save them
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

        # Go back to the main coffee list page after processing each coffee's report
        driver.get('https://database.coffeeinstitute.org/coffees/arabica')
        time.sleep(2)
        coffeenum += 1

    # Once all pages are processed, break out of the loop
    if page == total_pages - 1:
        break

# Close the driver
driver.close()