import requests
import os
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
import pybreaker

class WeatherService:
    # Circuit breaker for OpenWeather API
    circuit_breaker = pybreaker.CircuitBreaker(
        fail_max=5,  # Open circuit after 5 failures
        reset_timeout=60  # Stay open for 60 seconds (correct parameter name)
    )
    
    def __init__(self, api_key):
        """
        El constructor ahora requiere la clave de la API.
        """
        if not api_key:
            raise ValueError("La clave de API de OpenWeather no puede estar vacía.")
        self.api_key = api_key
        self.base_url = "https://api.openweathermap.org/data/2.5"
        
        # Connection pooling with requests.Session
        self.session = requests.Session()
        adapter = requests.adapters.HTTPAdapter(
            pool_connections=10,
            pool_maxsize=20,
            max_retries=0  # We handle retries with tenacity
        )
        self.session.mount('https://', adapter)
        self.session.mount('http://', adapter)

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=1, max=10),
        retry=retry_if_exception_type((requests.exceptions.RequestException, requests.exceptions.Timeout))
    )
    @circuit_breaker
    def get_air_quality(self, lat, lon):
        """
        Obtiene los datos de calidad del aire de la API de OpenWeatherMap.
        Includes retry logic with exponential backoff and circuit breaker.
        """
        params = {
            'lat': lat,
            'lon': lon,
            'appid': self.api_key
        }
        try:
            response = self.session.get(
                f"{self.base_url}/air_pollution", 
                params=params, 
                timeout=10
            )
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

        except pybreaker.CircuitBreakerError:
            print("Circuit breaker is OPEN - OpenWeather API is unavailable")
            return {"error": "Service temporarily unavailable"}
        except requests.exceptions.RequestException as e:
            print(f"Error al llamar a la API de OpenWeather (Air Quality): {e}")
            return {"error": f"No se pudo conectar a la API de OpenWeather: {e}"}

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=1, max=10),
        retry=retry_if_exception_type((requests.exceptions.RequestException, requests.exceptions.Timeout))
    )
    @circuit_breaker
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
            response = self.session.get(
                "https://api.openweathermap.org/data/2.5/weather", 
                params=params, 
                timeout=10
            )
            response.raise_for_status()
            data = response.json()
            
            return {
                "temp": data['main']['temp'],
                "condition": data['weather'][0]['description'],
                "icon": data['weather'][0]['icon']
            }
        except pybreaker.CircuitBreakerError:
            print("Circuit breaker is OPEN - OpenWeather API is unavailable")
            return None
        except Exception as e:
            print(f"Error getting weather: {e}")
            return None

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=1, max=10),
        retry=retry_if_exception_type((requests.exceptions.RequestException, requests.exceptions.Timeout))
    )
    @circuit_breaker
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
            response = self.session.get(
                f"https://api.openweathermap.org/data/2.5/forecast", 
                params=params, 
                timeout=10
            )
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
            
        except pybreaker.CircuitBreakerError:
            print("Circuit breaker is OPEN - OpenWeather API is unavailable")
            return []
        except Exception as e:
            print(f"Error getting forecast: {e}")
            return []

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=1, max=10),
        retry=retry_if_exception_type((requests.exceptions.RequestException, requests.exceptions.Timeout))
    )
    @circuit_breaker
    def get_air_quality_history(self, lat, lon, days=7):
        """
        Fetches historical air quality data for the past N days.
        OpenWeather API provides historical data using Unix timestamps.
        """
        import time
        from datetime import datetime, timedelta
        
        # Calculate timestamps for the past N days
        end_time = int(time.time())
        start_time = int((datetime.now() - timedelta(days=days)).timestamp())
        
        params = {
            'lat': lat,
            'lon': lon,
            'start': start_time,
            'end': end_time,
            'appid': self.api_key
        }
        
        try:
            response = self.session.get(
                f"{self.base_url}/air_pollution/history",
                params=params,
                timeout=10
            )
            response.raise_for_status()
            data = response.json()
            
            # Process and format the historical data
            history = []
            for item in data.get('list', []):
                history.append({
                    'date': datetime.fromtimestamp(item['dt']).isoformat(),
                    'aqi': item['main']['aqi'],
                    'components': item['components']
                })
            
            return history
            
        except pybreaker.CircuitBreakerError:
            print("Circuit breaker is OPEN - OpenWeather API is unavailable")
            return []
        except Exception as e:
            print(f"Error fetching air quality history: {e}")
            return []

