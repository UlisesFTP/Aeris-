import google.generativeai as genai
import hashlib
import json
import os

class GeminiService:
    def __init__(self, api_key):
        """
        Inicializa el servicio de Gemini con API key.
       """
        if not api_key:
            raise ValueError("La clave de API de Gemini no puede estar vacía.")
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-2.5-flash-lite')
        
        # Cache service for Gemini responses (uses Upstash Redis)
        from .cache_service import CacheService
        self.cache_service = CacheService()
    
    def _get_cache_key(self, prompt):
        """Generate cache key from prompt hash"""
        prompt_hash = hashlib.md5(prompt.encode()).hexdigest()
        return f"gemini:{prompt_hash}"
    
    def get_health_advice(self, weather_summary, aqi_data, language='es'):
        """
        Genera consejos de salud personalizados usando Gemini.
        Uses caching to avoid redundant API calls for identical prompts.
        """
        try:
            if language == 'en':
                prompt = f"""
                Act as an environmental health expert. Generate a personalized and direct recommendation (maximum 3 lines).
                
                Required format:
                [Risk Level]: [Advice]
                
                Examples:
                Low: Enjoy the outdoors without worries.
                High: Wear a mask and avoid going outside.
                
                Current data:
                Weather: {weather_summary}
                AQI: {aqi_data.get('aqi')}
                Components: {aqi_data.get('components')}
                """
            else:  # Spanish
                prompt = f"""
                Actúa como un experto en salud ambiental. Genera un consejo personalizado y directo (máximo 3 renglones).
                
                Formato obligatorio:
                [Nivel de Riesgo]: [Consejo]
                
                Ejemplos:
                Bajo: Disfruta del aire libre sin preocupaciones.
                Alto: Usa mascarilla y evita salir.
                
                Datos actuales:
                Clima: {weather_summary}
                AQI: {aqi_data.get('aqi')}
                Componentes: {aqi_data.get('components')}
                """
            
            # Check cache first
            cache_key = self._get_cache_key(prompt)
            cached_response = self.cache_service.get(cache_key)
            if cached_response:
                print(f"Cache HIT for Gemini health advice")
                return cached_response.decode('utf-8') if isinstance(cached_response, bytes) else cached_response
            
            # Call Gemini API
            response = self.model.generate_content(prompt)
            advice = response.text.strip()
            
            # Cache response for 1 hour (advice doesn't change frequently)
            self.cache_service.set(cache_key,  advice, ttl_seconds=3600)
            print(f"Cache MISS for Gemini health advice - cached for 1 hour")
            
            return advice
        except Exception as e:
            print(f"Error al llamar a Gemini: {e}")
            if language == 'en':
                return "Could not generate personalized advice at this time. Stay safe."
            else:
                return "No se pudo generar un consejo personalizado en este momento. Mantente seguro."
    
    def get_weather_advice(self, weather_data, language='es'):
        """
        Genera consejos personalizados para el clima usando Gemini.
        Uses caching to avoid redundant API calls for identical prompts.
        """
        try:
            temp = weather_data.get('temp')
            condition = weather_data.get('condition')
            min_temp = weather_data.get('min_temp')
            max_temp = weather_data.get('max_temp')
            
            if language == 'en':
                prompt = f"""
                Act as a meteorology expert. Generate personalized weather advice (maximum 3 lines).
                
                Required format:
                🌡️ [Temperature]: [Advice]
                
                Examples:
                🌡️ Hot (32°C): Stay hydrated and use sunscreen.
                🌡️ Cold (5°C): Dress warmly and wear layers.
                
                Current data:
                Temperature: {temp}°C
                Condition: {condition}
                Min: {min_temp}°C
                Max: {max_temp}°C
                """
            else:  # Spanish
                prompt = f"""
                Actúa como un experto en meteorología. Genera un consejo personalizado sobre el clima (máximo 3 renglones).
                
                Formato obligatorio:
                🌡️ [Temperatura]: [Consejo]
                
                Ejemplos:
                🌡️ Caluroso (32°C): Mantente hidratado y usa protector solar.
                🌡️ Frío (5°C): Abrígate bien y lleva capas de ropa.
                
                Datos actuales:
                Temperatura: {temp}°C
                Condición: {condition}
                Mínima: {min_temp}°C
                Máxima: {max_temp}°C
                """
            
            # Check cache first
            cache_key = self._get_cache_key(prompt)
            cached_response = self.cache_service.get(cache_key)
            if cached_response:
                print(f"Cache HIT for Gemini weather advice")
                return cached_response.decode('utf-8') if isinstance(cached_response, bytes) else cached_response
            
            # Call Gemini API
            response = self.model.generate_content(prompt)
            advice = response.text.strip()
            
            # Cache response for 1 hour
            self.cache_service.set(cache_key, advice, ttl_seconds=3600)
            print(f"Cache MISS for Gemini weather advice - cached for 1 hour")
            
            return advice
        except Exception as e:
            print(f"Error al llamar a Gemini para consejo del clima: {e}")
            if language == 'en':
                return "Could not generate weather advice at this time."
            else:
                return "No se pudo generar un consejo del clima en este momento."
