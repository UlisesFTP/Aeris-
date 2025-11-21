import google.generativeai as genai
import os

class GeminiService:
    def __init__(self, api_key):
        if not api_key:
            raise ValueError("La clave de API de Gemini no puede estar vacía.")
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-2.5-flash-lite')

    def get_health_advice(self, weather_summary, aqi_data):
        """
        Genera consejos de salud personalizados usando Gemini.
        """
        try:
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
            
            response = self.model.generate_content(prompt)
            return response.text.strip()
        except Exception as e:
            print(f"Error al llamar a Gemini: {e}")
            return "No se pudo generar un consejo personalizado en este momento. Mantente seguro."
    
    def get_weather_advice(self, weather_data):
        """
        Genera consejos personalizados para el clima usando Gemini.
        """
        try:
            temp = weather_data.get('temp')
            condition = weather_data.get('condition')
            min_temp = weather_data.get('min_temp')
            max_temp = weather_data.get('max_temp')
            
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
            
            response = self.model.generate_content(prompt)
            return response.text.strip()
        except Exception as e:
            print(f"Error al llamar a Gemini para consejo del clima: {e}")
            return "No se pudo generar un consejo del clima en este momento."
