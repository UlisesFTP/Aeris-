from flask import Blueprint, request, jsonify
import json
import requests
import sys # Importamos sys para forzar el flush de los logs
from config import Config
from ..services.weather_service import WeatherService
from ..services.cache_service import CacheService
from ..services.database_service import DatabaseService

from ..services.gemini_service import GeminiService

quality_bp = Blueprint('quality', __name__)

weather_service = WeatherService(api_key=Config.OPENWEATHER_API_KEY)
cache_service = CacheService(redis_url=Config.REDIS_URL)
db_service = DatabaseService(db_uri=Config.MONGO_URI, db_name=Config.MONGO_DB_NAME)
gemini_service = GeminiService(api_key=Config.GEMINI_API_KEY)

# Un helper para un mejor logging que funciona bien con Docker
def log_and_flush(message):
    print(message, file=sys.stderr)
    sys.stderr.flush()

@quality_bp.route('/air_quality', methods=['GET'])
def get_air_quality_data():
    try:
        lat = request.args.get('lat', type=float)
        lon = request.args.get('lon', type=float)
        if lat is None or lon is None:
            return jsonify({"error": "Faltan los parámetros 'lat' y 'lon'"}), 400

        cache_key = f"air_quality:{round(lat, 4)}:{round(lon, 4)}"
        cached_data = cache_service.get(cache_key)
        if cached_data:
            return jsonify(json.loads(cached_data)), 200

        data = weather_service.get_air_quality(lat, lon)
        if not data:
            return jsonify({"error": "No se pudieron obtener los datos de la API externa"}), 502
        
        db_service.save_reading(data)
        cache_service.set(cache_key, json.dumps(data), ttl_seconds=900)
        return jsonify(data), 200
    except Exception as e:
        log_and_flush(f"ERROR en /air_quality: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500

@quality_bp.route('/history', methods=['GET'])
def get_history_data():
    try:
        lat = request.args.get('lat', type=float)
        lon = request.args.get('lon', type=float)
        days = request.args.get('days', default=7, type=int)
        
        if lat is None or lon is None:
            return jsonify({"error": "Faltan los parámetros 'lat' y 'lon'"}), 400
        
        # Round coordinates to 2 decimal places for better cache hit rate (~1km precision)
        lat_rounded = round(lat, 2)
        lon_rounded = round(lon, 2)
        
        # Try cache first
        cache_key = f"history:{lat_rounded}:{lon_rounded}:{days}"
        cached_data = cache_service.get(cache_key)
        if cached_data:
            log_and_flush(f"Cache HIT for history: {cache_key}")
            return jsonify(json.loads(cached_data)), 200
        
        log_and_flush(f"Cache MISS for history: {cache_key}, fetching from API...")
        
        # Fetch from OpenWeather API
        history = weather_service.get_air_quality_history(lat_rounded, lon_rounded, days)
        
        if history:
            # Cache for 6 hours (historical data doesn't change)
            cache_service.set(cache_key, json.dumps(history), ttl_seconds=21600)
            log_and_flush(f"Cached {len(history)} historical data points")
            return jsonify(history), 200
        else:
            # Return empty array if no data available
            return jsonify([]), 200
            
    except Exception as e:
        log_and_flush(f"ERROR en /history: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500

@quality_bp.route('/locations', methods=['GET'])
def get_saved_locations():
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({"error": "user_id required"}), 400
    
    try:
        locations = db_service.get_saved_locations(user_id)
        return jsonify(locations), 200
    except Exception as e:
        log_and_flush(f"ERROR en GET /locations: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500

@quality_bp.route('/locations', methods=['POST'])
def add_saved_location():
    data = request.get_json()
    user_id = data.get('user_id')
    
    if not user_id:
        return jsonify({"error": "user_id required"}), 400
    
    if not data or 'name' not in data or 'latitude' not in data or 'longitude' not in data:
        return jsonify({"error": "Datos incompletos"}), 400
    
    try:
        db_service.add_saved_location(data, user_id)
        return jsonify({"status": "success"}), 201
    except Exception as e:
        log_and_flush(f"ERROR en POST /locations: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500

@quality_bp.route('/locations/<location_id>', methods=['DELETE'])
def delete_saved_location(location_id):
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({"error": "user_id required"}), 400
    
    try:
        success = db_service.delete_saved_location(location_id, user_id)
        if success:
            return jsonify({"status": "success"}), 200
        else:
            return jsonify({"error": "Location not found or unauthorized"}), 404
    except Exception as e:
        log_and_flush(f"ERROR en DELETE /locations/{location_id}: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500


@quality_bp.route('/weather', methods=['GET'])
def get_weather_data():
    try:
        lat = request.args.get('lat', type=float)
        lon = request.args.get('lon', type=float)
        if lat is None or lon is None:
            return jsonify({"error": "Faltan los parámetros 'lat' y 'lon'"}), 400

        current_weather = weather_service.get_current_weather(lat, lon)
        forecast = weather_service.get_forecast(lat, lon)

        return jsonify({
            "current": current_weather,
            "forecast": forecast
        }), 200
    except Exception as e:
        log_and_flush(f"ERROR en /weather: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500

@quality_bp.route('/advice', methods=['POST'])
def get_health_advice():
    try:
        data = request.get_json()
        if not data or 'weather' not in data or 'aqi' not in data:
            return jsonify({"error": "Datos incompletos"}), 400
            
        advice = gemini_service.get_health_advice(data['weather'], data['aqi'])
        return jsonify({"advice": advice}), 200
    except Exception as e:
        log_and_flush(f"ERROR en /advice: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500

# --- LOCATION VISIT TRACKING ---
@quality_bp.route('/locations/visit', methods=['POST'])
def record_location_visit():
    """Record when a user searches/visits a location"""
    data = request.get_json()
    user_id = data.get('user_id')
    
    if not user_id:
        return jsonify({"error": "user_id required"}), 400
    
    lat = data.get('latitude')
    lon = data.get('longitude')
    location_name = data.get('location_name')
    
    if lat is None or lon is None or not location_name:
        return jsonify({"error": "Missing required fields"}), 400
    
    try:
        db_service.record_location_visit(user_id, lat, lon, location_name)
        return jsonify({"status": "success"}), 201
    except Exception as e:
        log_and_flush(f"ERROR en POST /locations/visit: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500

@quality_bp.route('/locations/history', methods=['GET'])
def get_location_history():
    """Get user's location visit history with time filter"""
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({"error": "user_id required"}), 400
    
    days = request.args.get('days', default=7, type=int)
    
    try:
        history = db_service.get_location_history(user_id, days)
        return jsonify(history), 200
    except Exception as e:
        log_and_flush(f"ERROR en GET /locations/history: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500

@quality_bp.route('/search', methods=['GET'])
def search_locations():
    """Proxy for Nominatim search to avoid CORS issues on frontend"""
    query = request.args.get('q')
    if not query:
        return jsonify({"error": "Query required"}), 400
    
    try:
        # Call Nominatim API
        headers = {'User-Agent': 'AuraClimaApp/1.0'}
        response = requests.get(
            f'https://nominatim.openstreetmap.org/search?format=json&q={query}&limit=5',
            headers=headers,
            timeout=10
        )
        
        if response.status_code == 200:
            return jsonify(response.json()), 200
        else:
            return jsonify({"error": "Failed to fetch from Nominatim"}), 502
            
    except Exception as e:
        log_and_flush(f"ERROR en /search: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500
