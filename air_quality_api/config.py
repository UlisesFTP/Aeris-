import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")
    
    MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017/")
    MONGO_DB_NAME = "air_quality_db"
    
    # Lee el host de Redis. 'redis' es el nombre del servicio en docker-compose.
    REDIS_HOST = os.getenv("REDIS_HOST", "redis")
    REDIS_PORT = 6379
