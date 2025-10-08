import redis
import json

class CacheService:
    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(CacheService, cls).__new__(cls)
        return cls._instance

    # Modificamos el constructor para que acepte una URL completa
    def __init__(self, redis_url='redis://redis:6379'):
        if not hasattr(self, 'client'):
            try:
                # Usamos .from_url() que es la forma moderna de conectarse.
                self.client = redis.from_url(
                    redis_url, 
                    decode_responses=True,
                    socket_connect_timeout=5
                )
                # Hacemos ping para verificar la conexión al iniciar.
                self.client.ping()
                print("Conexión a Redis establecida.")
            except redis.exceptions.ConnectionError as e:
                print(f"ERROR: No se pudo conectar a Redis - {e}")
                self.client = None

    def get(self, key):
        if self.client:
            return self.client.get(key)
        return None

    def set(self, key, value, ttl_seconds):
        if self.client:
            self.client.setex(key, ttl_seconds, value)

