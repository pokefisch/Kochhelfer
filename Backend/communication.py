import asyncio
from pdb import main
from typing import Optional

from fastapi import FastAPI, WebSocket
import db_manager
from pydantic_model.rezept_url_body import rezept_url_body
import scrapping


app = FastAPI()

# @app.websocket("/ws/fetch")
# async def websocket_fetch_endpoint(websocket : WebSocket):
#    await websocket.accept()
#    try:
#         await asyncio.sleep(0.1)  # Simulate some processing delay
#         data = await websocket.receive_json()
#         url = data.get("url")
#         recipe_data = scrapping.fetch(url)
#         await asyncio.sleep(0.1)  # Simulate some processing delay
#         await websocket.send_json(recipe_data)

#    except Exception as e:
#         print(f"Error in WebSocket connection: {e}")
#    finally:
#         await websocket.close()

@app.post("/send_url")
def receive_url_endpoint(body: rezept_url_body):
        recipe_data = scrapping.fetch(body.url)  # Call the fetch function with the received URL
        main.savedRecipe = recipe_data  # Store the fetched recipe data in the global variable
        return recipe_data  # Return the fetched recipe data

@app.post("/save_recipe")
def save_recipe_endpoint():
        if not main.savedRecipe:
            return {"message": "No recipe data to save!"}
        try:
            db_manager.save_recipe_to_db(main.savedRecipe)
            return True, {"message": "Recipe data saved successfully!"}
        except Exception as e:
            print(f"Error saving recipe data: {e}")
            return False, {"message": "Failed to save recipe data!"}

@app.get("/categories")
def get_categories_endpoint():
        return db_manager.get_all_categories()

@app.get("/search_recipes")
def search_recipes_endpoint(query: Optional[str] = None, category: Optional[str] = None):
        return db_manager.search_recipes(query, category)