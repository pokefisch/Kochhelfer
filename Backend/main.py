import scrapping
import communication
import db_manager
import uvicorn
from fastapi import FastAPI


def main():
    savedRecipe = dict();
    db_manager.initialize_database()



if __name__ == "__main__":
    main()
    uvicorn.run("communication:app", host="0.0.0.0", port=8000, reload=True)