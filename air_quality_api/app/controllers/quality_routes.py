from flask import Blueprint, request, jsonify
import json
from config import Config
from ..services.weather_service import WeatherService
from ..services.cache_service import CacheService
from ..services.database_service import DatabaseService

quality_bp = Blueprint('quality', __name__)

# --- Inicialización de Servicios ---
weather_service = WeatherService(api_key=Config.OPENWEATHER_API_KEY)
cache_service = CacheService(host=Config.REDIS_HOST)
db_service = DatabaseService(db_uri=Config.MONGO_URI, db_name=Config.MONGO_DB_NAME)


@quality_bp.route('/air_quality', methods=['GET'])
def get_air_quality_data():
    lat = request.args.get('lat', type=float)
    lon = request.args.get('lon', type=float)

    if lat is None or lon is None:
        return jsonify({"error": "Faltan los parámetros 'lat' y 'lon'"}), 400

    cache_key = f"air_quality:{round(lat, 4)}:{round(lon, 4)}"
    
    cached_data = cache_service.get(cache_key)
    if cached_data:
        return jsonify(json.loads(cached_data)), 200

    try:
        data = weather_service.get_air_quality(lat, lon)
        if not data:
            return jsonify({"error": "No se pudieron obtener los datos"}), 500
        
        db_service.save_reading(data)
        cache_service.set(cache_key, json.dumps(data), ttl_seconds=900)

        return jsonify(data), 200
    except Exception as e:
        print(f"Error al obtener datos de la API: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500

@quality_bp.route('/history', methods=['GET'])
def get_history_data(): # <--- Nombre de función único
    lat = request.args.get('lat', type=float)
    lon = request.args.get('lon', type=float)

    if lat is None or lon is None:
        return jsonify({"error": "Faltan los parámetros 'lat' y 'lon'"}), 400
    
    try:
        history = db_service.get_history(lat, lon)
        return jsonify(history), 200
    except Exception as e:
        print(f"Error al obtener historial: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500

@quality_bp.route('/locations', methods=['GET'])
def get_saved_locations(): # <--- Nombre de función único
    try:
        locations = db_service.get_saved_locations()
        return jsonify(locations), 200
    except Exception as e:
        print(f"Error al obtener ubicaciones guardadas: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500

@quality_bp.route('/locations', methods=['POST'])
def add_saved_location(): # <--- Nombre de función único
    data = request.get_json()
    if not data or 'name' not in data or 'latitude' not in data or 'longitude' not in data:
        return jsonify({"error": "Datos incompletos"}), 400
    
    try:
        db_service.add_saved_location(data)
        return jsonify({"status": "success"}), 201
    except Exception as e:
        print(f"Error al guardar ubicación: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500

@quality_bp.route('/locations/<location_id>', methods=['DELETE'])
def delete_saved_location(location_id): # <--- Nombre de función único
    try:
        db_service.delete_saved_location(location_id)
        return jsonify({"status": "success"}), 200
    except Exception as e:
        print(f"Error al eliminar ubicación: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500