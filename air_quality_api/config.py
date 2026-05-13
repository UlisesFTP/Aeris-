import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")

    # Redis cache (Upstash in production, local redis in docker-compose)
    REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379")