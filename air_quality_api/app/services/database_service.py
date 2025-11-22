from pymongo import MongoClient, errors
from datetime import datetime, timedelta
from bson import ObjectId
import certifi
import threading 

class DatabaseService:
    _instance = None
    _lock = threading.Lock()  # Thread-safe singleton initialization

    def __new__(cls, *args, **kwargs):
        # Double-checked locking pattern for thread safety
        if not cls._instance:
            with cls._lock:
                if not cls._instance:
                    cls._instance = super(DatabaseService, cls).__new__(cls)
        return cls._instance

    def __init__(self, db_uri, db_name):
        # Only initialize once
        if not hasattr(self, 'client'):
            with self._lock:
                if not hasattr(self, 'client'):
                    try:
                        self.client = MongoClient(
                            db_uri,
                            tls=True,
                            tlsCAFile=certifi.where(),
                            serverSelectionTimeoutMS=5000,
                            # Connection pool configuration for production
                            maxPoolSize=50,  # Maximum connections in pool
                            minPoolSize=10,   # Minimum connections to maintain
                            maxIdleTimeMS=45000,  # Close idle connections after 45s
                            retryWrites=True,  # Automatically retry failed writes
                            retryReads=True,   # Automatically retry failed reads
                        )
                        self.client.admin.command('ping')
                        print("Conexión a MongoDB establecida con pool de conexiones.")
                        self.db = self.client[db_name]
                    except errors.ConnectionFailure as e:
                        print(f"ERROR CRÍTICO: No se pudo conectar a MongoDB. Error: {e}")
                        self.client = None
                        self.db = None
                
    def save_reading(self, reading_data):
        if self.db is None: return
        data_to_save = reading_data.copy()
        data_to_save['saved_at'] = datetime.utcnow()
        self.db.air_readings.insert_one(data_to_save)

    def get_history(self, lat, lon, days=7):
        if self.db is None: return []
        start_date = datetime.utcnow() - timedelta(days=days)
        query = { "location": { "$geoWithin": { "$centerSphere": [[lon, lat], 1 / 6378.1] } }, "saved_at": {"$gte": start_date} }
        pipeline = [ {'$match': query}, {'$group': { '_id': {'$dateToString': {'format': '%Y-%m-%d', 'date': '$saved_at'}}, 'avg_aqi': {'$avg': '$aqi'} }}, {'$sort': {'_id': -1}}, {'$limit': days} ]
        results = list(self.db.air_readings.aggregate(pipeline))
        formatted_results = [ {"date": item['_id'], "aqi": round(item['avg_aqi'])} for item in results ]
        return formatted_results

    def get_saved_locations(self, user_id):
        """Get saved locations for a specific user"""
        if self.db is None: return []
        query = {"user_id": user_id}
        locations = list(self.db.saved_locations.find(query))
        for loc in locations:
            loc['_id'] = str(loc['_id'])
        return locations

    def add_saved_location(self, location_data, user_id):
        """Add or update a saved location with user ownership"""
        if self.db is None: return
        location_data['user_id'] = user_id
        location_data['updated_at'] = datetime.utcnow()
        # Query by name AND user_id to prevent overwriting other users' locations
        query = {"name": location_data["name"], "user_id": user_id}
        self.db.saved_locations.update_one(query, {"$set": location_data}, upsert=True)

    def delete_saved_location(self, location_id, user_id):
        """Delete a saved location only if it belongs to the user"""
        if self.db is None: return False
        # Verify ownership before deleting
        query = {"_id": ObjectId(location_id), "user_id": user_id}
        result = self.db.saved_locations.delete_one(query)
        return result.deleted_count > 0

    def record_location_visit(self, user_id, lat, lon, location_name):
        """Record a location visit/search by the user"""
        if self.db is None: return
        visit_data = {
            "user_id": user_id,
            "latitude": lat,
            "longitude": lon,
            "location_name": location_name,
            "visited_at": datetime.utcnow()
        }
        self.db.location_visits.insert_one(visit_data)

    def get_location_history(self, user_id, days=7):
        """Get location visit history for user, grouped by location"""
        if self.db is None: return []
        
        start_date = datetime.utcnow() - timedelta(days=days)
        pipeline = [
            {
                "$match": {
                    "user_id": user_id,
                    "visited_at": {"$gte": start_date}
                }
            },
            {
                "$group": {
                    "_id": {
                        "name": "$location_name",
                        "lat": "$latitude",
                        "lon": "$longitude"
                    },
                    "last_visit": {"$max": "$visited_at"},
                    "visit_count": {"$sum": 1}
                }
            },
            {
                "$sort": {"last_visit": -1}
            },
            {
                "$limit": 50
            }
        ]
        
        results = list(self.db.location_visits.aggregate(pipeline))
        
        formatted_results = [
            {
                "location_name": item['_id']['name'],
                "latitude": item['_id']['lat'],
                "longitude": item['_id']['lon'],
                "visited_at": item['last_visit'].isoformat(),
                "search_count": item['visit_count']
            }
            for item in results
        ]
        
        return formatted_results
