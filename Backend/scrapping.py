from curl_cffi import requests
from recipe_scrapers import scrape_html

def safe_extract(scraper_method, default=None):
    try:
        return scraper_method()
    except Exception as e:
        print(f"Error occurred while fetching {scraper_method.__name__}: {e}")
        return default

def fetch(url):
    
    print(f"Fetching {url} with Chrome impersonation...")
    
    # This automatically handles the User-Agent and matches Chrome's exact TLS fingerprint
    response = requests.get(url, impersonate="chrome")
    scraper = scrape_html(html=response.text, org_url=url)

    recipe_data = {
        "title": safe_extract(scraper.title),
        "keywords": safe_extract(scraper.keywords, default=[]),
        "total_time": safe_extract(scraper.total_time),
        "ingredients": safe_extract(scraper.ingredients, default=[]),
        "instructions": safe_extract(scraper.instructions),
        "image": safe_extract(scraper.image)
    }

    if response.status_code != 200:
        print(f"Still blocked! Status code: {response.status_code}")
        return

    # Hand the raw HTML over to the scraper
    print("--- RECIPE FOUND ---")
    print(f"Title: {scraper.title()}")
    for tag in scraper.keywords():
        print(f" - {tag}")
    print(f"Total Time: {scraper.total_time()} minutes")
    print("Ingredients:")
    for ingredient in scraper.ingredients():
        print(f" - {ingredient}")

    print(f"Instructions:\n{scraper.instructions()}")