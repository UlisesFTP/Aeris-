from flask import Blueprint, request, jsonify
import json
import requests
import sys
from config import Config
from ..services.weather_service import WeatherService
from ..services.cache_service import CacheService

quality_bp = Blueprint('quality', __name__)

weather_service = WeatherService(api_key=Config.OPENWEATHER_API_KEY)
cache_service = CacheService()


# Placeholder limiter object (will be replaced by app initialization)
class _LimiterPlaceholder:
    _limiter = None


limiter = _LimiterPlaceholder()


def log_and_flush(message):
    print(message, file=sys.stderr)
    sys.stderr.flush()


# ─── Air Quality ───────────────────────────────────────────────────────────────

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

        # Cache 15 min — no se escribe nada en DB
        cache_service.set(cache_key, json.dumps(data), ttl_seconds=900)
        return jsonify(data), 200
    except Exception as e:
        log_and_flush(f"ERROR en /air_quality: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500


# ─── Historical AQI (OpenWeather, no DB) ──────────────────────────────────────

@quality_bp.route('/history', methods=['GET'])
def get_history_data():
    try:
        lat = request.args.get('lat', type=float)
        lon = request.args.get('lon', type=float)
        days = request.args.get('days', default=7, type=int)

        if lat is None or lon is None:
            return jsonify({"error": "Faltan los parámetros 'lat' y 'lon'"}), 400

        lat_rounded = round(lat, 2)
        lon_rounded = round(lon, 2)

        cache_key = f"history:{lat_rounded}:{lon_rounded}:{days}"
        cached_data = cache_service.get(cache_key)
        if cached_data:
            log_and_flush(f"Cache HIT for history: {cache_key}")
            return jsonify(json.loads(cached_data)), 200

        log_and_flush(f"Cache MISS for history: {cache_key}, fetching from API...")
        history = weather_service.get_air_quality_history(lat_rounded, lon_rounded, days)

        if history:
            # Cache 6 h — el historial no cambia frecuentemente
            cache_service.set(cache_key, json.dumps(history), ttl_seconds=21600)
            log_and_flush(f"Cached {len(history)} historical data points")
            return jsonify(history), 200
        else:
            return jsonify([]), 200

    except Exception as e:
        log_and_flush(f"ERROR en /history: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500


# ─── Weather + Forecast ────────────────────────────────────────────────────────

@quality_bp.route('/weather', methods=['GET'])
def get_weather_data():
    try:
        lat = request.args.get('lat', type=float)
        lon = request.args.get('lon', type=float)
        lang = request.args.get('lang', default='es', type=str)

        if lat is None or lon is None:
            return jsonify({"error": "Faltan los parámetros 'lat' y 'lon'"}), 400

        lat_r = round(lat, 2)
        lon_r = round(lon, 2)
        cache_key = f"weather:{lat_r}:{lon_r}:{lang}"
        cached_data = cache_service.get(cache_key)
        if cached_data:
            log_and_flush(f"Cache HIT for weather: {cache_key}")
            return jsonify(json.loads(cached_data)), 200

        import concurrent.futures
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
            future_current = executor.submit(weather_service.get_current_weather, lat, lon, lang)
            future_forecast = executor.submit(weather_service.get_forecast, lat, lon, lang)
            current_weather = future_current.result(timeout=15)
            forecast = future_forecast.result(timeout=15)

        result = {"current": current_weather, "forecast": forecast}
        cache_service.set(cache_key, json.dumps(result), ttl_seconds=1800)  # 30 min
        return jsonify(result), 200
    except Exception as e:
        log_and_flush(f"ERROR en /weather: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500


# ─── Location Search (Nominatim proxy) ────────────────────────────────────────

@quality_bp.route('/search', methods=['GET'])
def search_locations():
    query = request.args.get('q')
    if not query:
        return jsonify({"error": "Query required"}), 400

    try:
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
