from flask import Blueprint, request, jsonify
from config import Config # <-- Importa la configuración
from ..services.weather_service import WeatherService
from ..services.database_service import DatabaseService
from ..services.cache_service import CacheService

quality_bp = Blueprint('quality', __name__)

# Instanciar servicios, pasando la configuración necesaria
# <-- Pasa la API key al crear el servicio
weather_service = WeatherService(api_key=Config.OPENWEATHER_API_KEY)
database_service = DatabaseService()
cache_service = CacheService()

@quality_bp.route('/air_quality', methods=['GET'])
def get_air_quality_data():
    lat = request.args.get('lat', type=float)
    lon = request.args.get('lon', type=float)
    if lat is None or lon is None:
        return jsonify({"error": "Faltan los parámetros 'lat' y 'lon'"}), 400

    cache_key = f"air_quality:{round(lat, 4)}:{round(lon, 4)}"

    try:
        cached_data = cache_service.get(cache_key)
        if cached_data:
            print(f"CACHE HIT para {cache_key}")
            return jsonify(cached_data)

        print(f"CACHE MISS para {cache_key}")
        api_data = weather_service.get_air_quality(lat, lon)
        if "error" in api_data:
             return jsonify(api_data), 500

        database_service.save_reading(api_data)
        cache_service.set(cache_key, api_data)

        return jsonify(api_data)
    except Exception as e:
        print(f"Ocurrió un error en el servidor: {e}")
        try:
            api_data = weather_service.get_air_quality(lat, lon)
            return jsonify(api_data)
        except:
             return jsonify({"error": "Ocurrió un error en el servidor"}), 500

@quality_bp.route('/air_quality/history', methods=['GET'])
def get_air_quality_history():
    lat = request.args.get('lat', type=float)
    lon = request.args.get('lon', type=float)
    if lat is None or lon is None:
        return jsonify({"error": "Faltan los parámetros 'lat' y 'lon'"}), 400
    
    try:
        history_data = database_service.get_readings_near(lat, lon)
        return jsonify(history_data)
    except Exception as e:
        print(f"Error al obtener historial: {e}")
        return jsonify({"error": "Ocurrió un error al obtener el historial"}), 500