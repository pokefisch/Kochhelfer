import sqlite3

database = "recipes.db"
create_table_query = """
CREATE TABLE IF NOT EXISTS recipes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    link TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    duration INT,
    portions INT,
    image TEXT
);

CREATE TABLE IF NOT EXISTS ingredients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS recipe_ingredients (
    recipe_id INTEGER,
    ingredient_id INTEGER,
    quantity TEXT,
    unit TEXT,
    PRIMARY KEY (recipe_id, ingredient_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id)
);

CREATE TABLE IF NOT EXISTS tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS recipe_tags (
    recipe_id INTEGER,
    tag_id INTEGER,
    PRIMARY KEY (recipe_id, tag_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id),
    FOREIGN KEY (tag_id) REFERENCES tags(id)
);

CREATE TABLE IF NOT EXISTS equipment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS recipe_equipment (
    recipe_id INTEGER,
    equipment_id INTEGER,
    PRIMARY KEY (recipe_id, equipment_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id),
    FOREIGN KEY (equipment_id) REFERENCES equipment(id)
);

CREATE TABLE IF NOT EXISTS recipe_instructions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_id INTEGER,
    step_number INTEGER,
    instruction TEXT NOT NULL,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id)
);


"""
def initialize_database():
    try:
        with sqlite3.connect("recipes.db") as conn:
            print(f"Connected to SQLite database with Version {sqlite3.sqlite_version}!")
            cursor = conn.cursor()
            cursor.executescript(create_table_query)
            print("Database and table created successfully!")

    except sqlite3.OperationalError as e:
        print(f"An error occurred while creating the database: {e}")

def save_recipe_to_db(recipe_data):
    print(f"Saving recipe to database: {recipe_data['title']}")
    if not recipe_data: return
    
    try:
        with sqlite3.connect("recipes.db") as conn:
            cursor = conn.cursor()
            
            # 1. Insert Recipe
            cursor.execute("""
                INSERT OR REPLACE INTO recipes (link, title, duration, portions, image)
                VALUES (?, ?, ?, ?, ?)
            """, (
                recipe_data["link"], recipe_data["title"], 
                recipe_data["duration"], recipe_data["servings"], recipe_data["image"]
            ))
            recipe_id = cursor.lastrowid

            # 2. Ingredients
            for ing in recipe_data["ingredients"]:
                cursor.execute("INSERT OR IGNORE INTO ingredients (name) VALUES (?)", (ing["name"],))
                cursor.execute("""
                    INSERT OR REPLACE INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit)
                    VALUES (?, (SELECT id FROM ingredients WHERE name = ?), ?, ?)
                """, (recipe_id, ing["name"], ing["amount"], ing["unit"]))

            # 3. Tags
            for tag in recipe_data["tags"]:
                cursor.execute("INSERT OR IGNORE INTO tags (name) VALUES (?)", (tag,))
                cursor.execute("INSERT OR IGNORE INTO recipe_tags (recipe_id, tag_id) VALUES (?, (SELECT id FROM tags WHERE name = ?))", (recipe_id, tag))

            # 4. Instructions
            for i, step in enumerate(recipe_data["instructions"], 1):
                cursor.execute("INSERT INTO recipe_instructions (recipe_id, step_number, instruction) VALUES (?, ?, ?)", (recipe_id, i, step))

            # 5. Equipment
            for eq in recipe_data.get("equipment", []):
                cursor.execute("INSERT OR IGNORE INTO equipment (name) VALUES (?)", (eq,))
                cursor.execute("INSERT OR IGNORE INTO recipe_equipment (recipe_id, equipment_id) VALUES (?, (SELECT id FROM equipment WHERE name = ?))", (recipe_id, eq))    
            conn.commit()
    except Exception as e:
        print(f"Database Error: {e}")

def fetch_all_tags():
    try:
        with sqlite3.connect("recipes.db") as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT name, id FROM tags")
            return [(row[0], row[1]) for row in cursor.fetchall()]
    except Exception as e:
        print(f"Database Error: {e}")
        return []
    
def fetch_all_ingredients():
    try:
        with sqlite3.connect("recipes.db") as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT name, id FROM ingredients")
            return [(row[0], row[1]) for row in cursor.fetchall()]
    except Exception as e:
        print(f"Database Error: {e}")
        return []
    
def fetch_for_ingredients(ingredient_ids):
    try:
        with sqlite3.connect("recipes.db") as conn:
            cursor = conn.cursor()
            query = f"""
                SELECT r.*
                FROM recipes r
                JOIN recipe_ingredients ri ON r.id = ri.recipe_id
                WHERE ri.ingredient_id IN ({','.join('?' for _ in ingredient_ids)})
                GROUP BY r.id
            """
            cursor.execute(query, ingredient_ids)
            return cursor.fetchall()
    except Exception as e:
        print(f"Database Error: {e}")
        return []
    
