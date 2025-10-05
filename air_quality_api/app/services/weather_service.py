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
        self.base_url = "https://api.openweathermap.org/data/2.5/air_pollution"

    def get_air_quality(self, lat, lon):
        """
        Obtiene los datos de calidad del aire de la API de OpenWeatherMap.
        """
        params = {
            'lat': lat,
            'lon': lon,
            'appid': self.api_key # Usa la clave guardada en la instancia
        }
        try:
            response = requests.get(self.base_url, params=params, timeout=10)
            response.raise_for_status() # Lanza un error si la respuesta no es 2xx
            
            raw_data = response.json()
            if not raw_data or 'list' not in raw_data or not raw_data['list']:
                return {"error": "Respuesta inesperada de la API de OpenWeather"}

            data_point = raw_data['list'][0]
            
            # Formatear la respuesta a nuestro modelo de datos simple
            clean_data = {
                "coordinates": raw_data.get('coord', {'lat': lat, 'lon': lon}),
                "aqi": data_point.get('main', {}).get('aqi'),
                "components": data_point.get('components', {})
            }
            return clean_data

        except requests.exceptions.RequestException as e:
            print(f"Error al llamar a la API de OpenWeather: {e}")
            return {"error": f"No se pudo conectar a la API de OpenWeather: {e}"}
