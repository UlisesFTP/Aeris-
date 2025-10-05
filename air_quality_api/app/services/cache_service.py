import redis
import json
from config import Config

class CacheService:
    def __init__(self):
        try:
            self.client = redis.Redis(
                host=Config.REDIS_HOST,
                port=Config.REDIS_PORT,
                db=0,
                decode_responses=True,
                socket_connect_timeout=2
            )
            self.client.ping()
            print("Conexión a Redis establecida.")
        except redis.exceptions.ConnectionError as e:
            print(f"Error al conectar con Redis: {e}")
            self.client = None

    def get(self, key):
        if not self.client: return None
        value = self.client.get(key)
        return json.loads(value) if value else None

    def set(self, key, value, ttl_seconds=900): # 15 minutos
        if not self.client: return
        self.client.setex(key, ttl_seconds, json.dumps(value))
