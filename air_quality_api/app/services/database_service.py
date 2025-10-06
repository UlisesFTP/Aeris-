from pymongo import MongoClient
from datetime import datetime, timedelta
from bson import ObjectId

class DatabaseService:
    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(DatabaseService, cls).__new__(cls)
        return cls._instance

    def __init__(self, db_uri, db_name):
        if not hasattr(self, 'client'):
            self.client = MongoClient(db_uri)
            self.db = self.client[db_name]
            print("Conexión a MongoDB establecida.")

    def save_reading(self, reading_data):
        # CORRECCIÓN: Hacemos una copia para no modificar el diccionario original.
        # Esto evita el error de serialización de datetime en la caché.
        data_to_save = reading_data.copy()
        data_to_save['saved_at'] = datetime.utcnow()
        self.db.air_readings.insert_one(data_to_save)

    def get_history(self, lat, lon, days=7):
        """Busca en un radio pequeño y agrupa los resultados por día."""
        start_date = datetime.utcnow() - timedelta(days=days)
        
        # CORRECCIÓN: Usamos $geoWithin, que es compatible con aggregation.
        # Esto requiere un índice '2dsphere' en el campo 'location'.
        query = {
            "location": {
                "$geoWithin": {
                    # Radio de 1km (1 / 6378.1)
                    "$centerSphere": [[lon, lat], 1 / 6378.1]  
                }
            },
            "saved_at": {"$gte": start_date}
        }
        
        pipeline = [
            {'$match': query},
            {'$group': {
                '_id': {'$dateToString': {'format': '%Y-%m-%d', 'date': '$saved_at'}},
                'avg_aqi': {'$avg': '$aqi'}
            }},
            {'$sort': {'_id': -1}},
            {'$limit': days}
        ]
        
        results = list(self.db.air_readings.aggregate(pipeline))
        
        formatted_results = [
            {
                "date": item['_id'],
                "aqi": round(item['avg_aqi'])
            } for item in results
        ]
        return formatted_results

    def get_saved_locations(self):
        locations = list(self.db.saved_locations.find({}))
        for loc in locations:
            loc['_id'] = str(loc['_id'])
        return locations

    def add_saved_location(self, location_data):
        query = {"name": location_data["name"]}
        self.db.saved_locations.update_one(query, {"$set": location_data}, upsert=True)

    def delete_saved_location(self, location_id):
        self.db.saved_locations.delete_one({"_id": ObjectId(location_id)})

