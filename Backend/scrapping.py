import re
from curl_cffi import requests
from recipe_scrapers import scrape_html

def parse_ingredient(raw_string: str) -> dict:
    # Splits a raw ingredient string into amount, unit, and name.
    
    # UPGRADE: Added the '/' inside the first brackets so it catches "1/2" or "3/4"
    match = re.match(r'^([\d.,/]+)\s*([a-zA-ZäöüÄÖÜß()]+)?\s+(.*)', raw_string.strip())
    
    if match:
        amount_str = match.group(1).replace(',', '.')
        
        # Safely handle fractions if they exist
        if '/' in amount_str:
            parts = amount_str.split('/')
            if len(parts) == 2 and parts[1].isdigit():
                try:
                    amount = float(parts[0]) / float(parts[1])
                except (ValueError, ZeroDivisionError):
                    amount = 0.0
            else:
                amount = 0.0
        else:
            try:
                amount = float(amount_str)
            except ValueError:
                amount = 0.0
                
        unit = match.group(2) if match.group(2) else ""
        name = match.group(3).strip()
        
        return {"name": name, "amount": amount, "unit": unit}
    else:
        return {"name": raw_string.strip(), "amount": 0.0, "unit": ""}

def safe_extract(scraper_method, default=None):
    try:
        return scraper_method()
    except Exception as e:
        print(f"Error occurred while fetching {scraper_method.__name__}: {e}")
        return default

# Our new data cleaner!
def clean_serving_size(raw_string: str) -> int:
    # Extracts the first integer from a string, defaults to 1 if none found.
    if not raw_string:
        return 1
    match = re.search(r'\d+', str(raw_string))
    if match:
        return int(match.group())
    return 1

def fetch(url):
    print(f"Fetching {url} with Chrome impersonation...")
    
    response = requests.get(url, impersonate="chrome")
    
    if response.status_code != 200:
        print(f"Still blocked! Status code: {response.status_code}")
        return {} # Return empty dict on failure

    scraper = scrape_html(html=response.text, org_url=url)
    raw_data = safe_extract(scraper.to_json, default={})

    # --- THE DATA CLEANING PIPELINE ---
    # We create a new, clean dictionary that perfectly matches your Flutter RecipeModel!
    
    # Grab the raw serving string (from yields or nutrients)
    raw_ingredients = raw_data.get("ingredients", [])
    parsed_ingredients = [parse_ingredient(ing) for ing in raw_ingredients]

    raw_serving = raw_data.get("yields") or raw_data.get("nutrients", {}).get("servingSize", "1")
    
    clean_recipe_data = {
        "title": raw_data.get("title", "Unbekanntes Rezept"),
        
        # Format the time nicely for the UI (e.g., turns 40 into "40 Min")
        "prep_time_minutes": raw_data.get("total_time", 0),
        
        # Rename 'image' to match Flutter's 'image_url' expectation
        "image_url": raw_data.get("image", ""),
        
        # Pass the ingredients list exactly as is
        "ingredients": parsed_ingredients,
        
        # Run our regex cleaner to get a pure integer!
        "servings": clean_serving_size(raw_serving),
        
        # Let's also pass the instructions list so you can build that part of the UI later!
        "instructions": raw_data.get("instructions_list", [])
    }

    return clean_recipe_data