import requests
import os

class WeatherService:
    def __init__(self, api_key):
        """
        El constructor ahora requiere la clave de la API.
        """
        if not api_key:
            raise ValueError("La clave de API de OpenWeather no puede estar vacía.")
        self.api_key = api_key
        self.base_url = "https://api.openweathermap.org/data/2.5"

    def get_air_quality(self, lat, lon):
        """
        Obtiene los datos de calidad del aire de la API de OpenWeatherMap.
        """
        params = {
            'lat': lat,
            'lon': lon,
            'appid': self.api_key
        }
        try:
            response = requests.get(f"{self.base_url}/air_pollution", params=params, timeout=10)
            response.raise_for_status()
            
            raw_data = response.json()
            if not raw_data or 'list' not in raw_data or not raw_data['list']:
                return {"error": "Respuesta inesperada de la API de OpenWeather"}

            data_point = raw_data['list'][0]
            
            clean_data = {
                "coordinates": raw_data.get('coord', {'lat': lat, 'lon': lon}),
                "aqi": data_point.get('main', {}).get('aqi'),
                "components": data_point.get('components', {})
            }
            return clean_data

        except requests.exceptions.RequestException as e:
            print(f"Error al llamar a la API de OpenWeather (Air Quality): {e}")
            return {"error": f"No se pudo conectar a la API de OpenWeather: {e}"}

    def get_current_weather(self, lat, lon):
        """
        Obtiene el clima actual.
        """
        params = {
            'lat': lat,
            'lon': lon,
            'appid': self.api_key,
            'units': 'metric',
            'lang': 'es'
        }
        try:
            response = requests.get(f"https://api.openweathermap.org/data/2.5/weather", params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            return {
                "temp": data['main']['temp'],
                "condition": data['weather'][0]['description'],
                "icon": data['weather'][0]['icon']
            }
        except Exception as e:
            print(f"Error getting weather: {e}")
            return None

    def get_forecast(self, lat, lon):
        """
        Obtiene el pronóstico de 5 días.
        """
        params = {
            'lat': lat,
            'lon': lon,
            'appid': self.api_key,
            'units': 'metric',
            'lang': 'es'
        }
        try:
            response = requests.get(f"https://api.openweathermap.org/data/2.5/forecast", params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            # Procesar para obtener un resumen diario (aprox)
            daily_forecast = {}
            for item in data['list']:
                date = item['dt_txt'].split(' ')[0]
                if date not in daily_forecast:
                    daily_forecast[date] = {
                        "min_temp": item['main']['temp_min'],
                        "max_temp": item['main']['temp_max'],
                        "icon": item['weather'][0]['icon'],
                        "condition": item['weather'][0]['main']
                    }
                else:
                    daily_forecast[date]["min_temp"] = min(daily_forecast[date]["min_temp"], item['main']['temp_min'])
                    daily_forecast[date]["max_temp"] = max(daily_forecast[date]["max_temp"], item['main']['temp_max'])
            
            # Convertir a lista y tomar los próximos 5 días
            forecast_list = []
            for date, info in daily_forecast.items():
                forecast_list.append({
                    "date": date,
                    **info
                })
            
            return forecast_list[:5]
            
        except Exception as e:
            print(f"Error getting forecast: {e}")
            return []
