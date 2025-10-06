from flask import Blueprint, request, jsonify, current_app
from json import ObjectId # Importante para manejar los IDs de MongoDB
import json
from ..services.weather_service import WeatherService
from ..services.cache_service import CacheService
from ..services.database_service import DatabaseService

quality_bp = Blueprint('quality', __name__)

# Se inicializan los servicios dentro del contexto de la aplicación
@quality_bp.before_app_first_request
def init_services():
    global weather_service, cache_service, db_service
    weather_service = WeatherService(current_app.config['OPENWEATHER_API_KEY'])
    cache_service = CacheService(host=current_app.config['REDIS_HOST'])
    db_service = DatabaseService(
        db_uri=current_app.config['MONGO_URI'],
        db_name=current_app.config['MONGO_DB_NAME']
    )

# --- ENDPOINTS EXISTENTES ---
@quality_bp.route('/air_quality', methods=['GET'])
def get_air_quality_data():
    # ... (este código no cambia)
    lat = request.args.get('lat', type=float)
    lon = request.args.get('lon', type=float)

    if lat is None or lon is None:
        return jsonify({"error": "Faltan los parámetros 'lat' y 'lon'"}), 400

    cache_key = f"air_quality:{lat}:{lon}"
    cached_data = cache_service.get(cache_key)

    if cached_data:
        return jsonify(json.loads(cached_data)), 200

    try:
        data = weather_service.get_air_quality(lat, lon)
        if data:
            db_service.save_reading(data)
            cache_service.set(cache_key, json.dumps(data, default=str), ttl_seconds=900)
            return jsonify(data), 200
        else:
            return jsonify({"error": "No se pudieron obtener los datos"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# --- NUEVOS ENDPOINTS PARA UBICACIONES GUARDADAS ---

@quality_bp.route('/locations', methods=['POST'])
def add_location():
    """ Guarda una nueva ubicación para un usuario (simulado) """
    data = request.get_json()
    if not data or 'name' not in data or 'latitude' not in data or 'longitude' not in data:
        return jsonify({"error": "Faltan datos"}), 400
    
    # En una app real, aquí usarías un user_id
    location_id = db_service.save_user_location(data)
    return jsonify({"message": "Ubicación guardada", "id": str(location_id)}), 201

@quality_bp.route('/locations', methods=['GET'])
def get_locations():
    """ Obtiene las ubicaciones guardadas de un usuario (simulado) """
    locations = db_service.get_user_locations()
    return jsonify(locations), 200

@quality_bp.route('/locations/<location_id>', methods=['DELETE'])
def delete_location(location_id):
    """ Elimina una ubicación guardada """
    try:
        db_service.delete_user_location(location_id)
        return jsonify({"message": "Ubicación eliminada"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

