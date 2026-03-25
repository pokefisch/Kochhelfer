import asyncio

from fastapi import FastAPI, WebSocket
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
        return recipe_data  # Return the fetched recipe data

# @app.get("/fetch")