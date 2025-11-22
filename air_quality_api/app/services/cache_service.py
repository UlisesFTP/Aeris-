from upstash_redis import Redis

class CacheService:
    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(CacheService, cls).__new__(cls)
        return cls._instance

    def __init__(self):
        if not hasattr(self, 'client'):
            try:
                # Use Upstash Redis from environment variables
                # Expects UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN in .env
                self.client = Redis.from_env()
                
                # Test connection with a simple operation
                self.client.set("__health_check__", "ok", ex=10)
                print("Conexión a Upstash Redis establecida.")
            except Exception as e:
                print(f"ERROR: No se pudo conectar a Upstash Redis - {e}")
                self.client = None

    def get(self, key):
        if self.client:
            try:
                return self.client.get(key)
            except Exception as e:
                print(f"Error getting key {key} from Redis: {e}")
                return None
        return None

    def set(self, key, value, ttl_seconds):
        if self.client:
            try:
                self.client.setex(key, ttl_seconds, value)
            except Exception as e:
                print(f"Error setting key {key} in Redis: {e}")

