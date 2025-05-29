# -*- coding: utf-8 -*-
"""
Created on Thu May 29 08:49:06 2025

@author: eboal
"""

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
import pandas as pd
import time
import json

# Optional: run Chrome in headless mode
# options = Options()
# options.add_argument("--headless")
# driver = webdriver.Chrome(options=options)

# Set up the driver
driver = webdriver.Chrome()

# Visit the Innovation page
base_url = "https://www.bbc.com/innovation"
driver.get(base_url)

# Let the page load
time.sleep(3)

# Scroll a bit to load more content if needed
driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
time.sleep(2)

# Find all article links on the page
article_links = driver.find_elements(By.CSS_SELECTOR, "a[href*='/news/articles/']")
links = []
for link in article_links:
    href = link.get_attribute("href")
    if href and href not in links:
        links.append(href)

# Prepare list for article data
article_data = []

# Loop through each article link
for url in links:
    try:
        driver.get(url)
        time.sleep(2)

        # Extract headline
        try:
            headline = driver.find_element(By.TAG_NAME, "h1").text.strip()
        except:
            headline = "No headline found"

        # Extract paragraphs
        try:
            paragraphs = driver.find_elements(By.CSS_SELECTOR, "main p")
            full_text = " ".join([p.text for p in paragraphs if p.text.strip()])
        except:
            full_text = "No article text found"

        # Extract image
        try:
            image_element = driver.find_element(By.CSS_SELECTOR, "main img")
            image_url = image_element.get_attribute("src")
        except:
            image_url = "No image found"

        # Add article info
        article_data.append({
            "Headline": headline,
            "URL": url,
            "Summary": full_text,
            "Image": image_url
        })

        # Optional: print progress
        print(f"Scraped: {headline}")
        
        # Go back to the main page
        driver.back()
        time.sleep(2)
    except Exception as e:
        print(f"Error scraping {url}: {e}")
        continue

# Close driver
driver.quit()

# Save data to CSV and JSON
df = pd.DataFrame(article_data)
df.to_csv("bbc_innovation.csv", index=False)

with open("bbc_innovation_articles.json", "w", encoding="utf-8") as f:
    json.dump(article_data, f, ensure_ascii=False, indent=2)

print(f"Scraped {len(article_data)} articles successfully.")
