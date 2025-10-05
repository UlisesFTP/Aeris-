from pymongo import MongoClient, GEOSPHERE, DESCENDING
from config import Config
from datetime import datetime
import json
from bson import json_util

class DatabaseService:
    _instance = None

    def __new__(cls):
        if not cls._instance:
            cls._instance = super(DatabaseService, cls).__new__(cls)
            try:
                cls.client = MongoClient(Config.MONGO_URI, serverSelectionTimeoutMS=5000)
                cls.db = cls.client[Config.MONGO_DB_NAME]
                # Crear índice geoespacial si no existe
                cls.db.air_readings.create_index([("location", GEOSPHERE)])
                print("Conexión a MongoDB establecida.")
            except Exception as e:
                print(f"Error al conectar con MongoDB: {e}")
                cls._instance = None
        return cls._instance

    def save_reading(self, reading_data):
        if not self._instance: return None
        data_to_save = reading_data.copy()
        data_to_save['location'] = {
            'type': 'Point',
            'coordinates': [data_to_save['coordinates']['lon'], data_to_save['coordinates']['lat']]
        }
        data_to_save['saved_at'] = datetime.utcnow()
        try:
            return self.db.air_readings.insert_one(data_to_save)
        except Exception as e:
            print(f"Error al guardar en la DB: {e}")
            return None
    
    def get_readings_near(self, lat, lon, max_dist_meters=1000):
        """Busca lecturas históricas cerca de una coordenada."""
        if not self._instance: return []
        try:
            readings = self.db.air_readings.find({
                "location": {
                    "$near": {
                        "$geometry": {"type": "Point", "coordinates": [lon, lat]},
                        "$maxDistance": max_dist_meters
                    }
                }
            }).limit(50).sort("saved_at", DESCENDING)
            
            # Convertir cursor de BSON a una lista JSON-safe
            return json.loads(json_util.dumps(readings))
        except Exception as e:
            print(f"Error al buscar historial en la DB: {e}")
            return []
