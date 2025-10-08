import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")
    MONGO_URI = os.getenv("MONGO_URI")
    
    # Le decimos que busque la variable REDIS_URL que Render nos da.
    # Si no la encuentra (en local), usa la URL por defecto para docker-compose.
    REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379")
    
    MONGO_DB_NAME = "air_quality_db"