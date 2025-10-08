from pymongo import MongoClient, errors
from datetime import datetime, timedelta
from bson import ObjectId
import certifi 

class DatabaseService:
    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(DatabaseService, cls).__new__(cls)
        return cls._instance

    def __init__(self, db_uri, db_name):
        if not hasattr(self, 'client'):
            try:
                self.client = MongoClient(
                    db_uri,
                    tls=True,
                    tlsCAFile=certifi.where(),
                    serverSelectionTimeoutMS=5000 
                )
                self.client.admin.command('ping')
                print("Conexión a MongoDB establecida.")
                self.db = self.client[db_name]
            except errors.ConnectionFailure as e:
                print(f"ERROR CRÍTICO: No se pudo conectar a MongoDB. Error: {e}")
                self.client = None
                self.db = None
                
    def save_reading(self, reading_data):
        # CORRECCIÓN: Comparamos con 'is None'
        if self.db is None: return
        data_to_save = reading_data.copy()
        data_to_save['saved_at'] = datetime.utcnow()
        self.db.air_readings.insert_one(data_to_save)

    def get_history(self, lat, lon, days=7):
        # CORRECCIÓN: Comparamos con 'is None'
        if self.db is None: return []
        start_date = datetime.utcnow() - timedelta(days=days)
        query = { "location": { "$geoWithin": { "$centerSphere": [[lon, lat], 1 / 6378.1] } }, "saved_at": {"$gte": start_date} }
        pipeline = [ {'$match': query}, {'$group': { '_id': {'$dateToString': {'format': '%Y-%m-%d', 'date': '$saved_at'}}, 'avg_aqi': {'$avg': '$aqi'} }}, {'$sort': {'_id': -1}}, {'$limit': days} ]
        results = list(self.db.air_readings.aggregate(pipeline))
        formatted_results = [ {"date": item['_id'], "aqi": round(item['avg_aqi'])} for item in results ]
        return formatted_results

    def get_saved_locations(self):
        # CORRECCIÓN: Comparamos con 'is None'
        if self.db is None: return []
        locations = list(self.db.saved_locations.find({}))
        for loc in locations:
            loc['_id'] = str(loc['_id'])
        return locations

    def add_saved_location(self, location_data):
        # CORRECCIÓN: Comparamos con 'is None'
        if self.db is None: return
        query = {"name": location_data["name"]}
        self.db.saved_locations.update_one(query, {"$set": location_data}, upsert=True)

    def delete_saved_location(self, location_id):
        # CORRECCIÓN: Comparamos con 'is None'
        if self.db is None: return
        self.db.saved_locations.delete_one({"_id": ObjectId(location_id)})

