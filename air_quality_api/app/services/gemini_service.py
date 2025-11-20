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
            Actúa como un experto en salud ambiental. Genera un consejo breve y personalizado , se serio y directo (máximo 2 frases) basado en las siguientes condiciones:
            
            Clima: {weather_summary}
            Calidad del Aire (AQI): {aqi_data.get('aqi')}
            Componentes: {aqi_data.get('components')}
            
            El consejo debe ser práctico y directo. Usa un tono directo, serio y facil de entender pero informativo.
            Si la calidad del aire es mala, enfatiza la protección.
            Si es buena, anima a disfrutar el aire libre.
            """
            
            response = self.model.generate_content(prompt)
            return response.text.strip()
        except Exception as e:
            print(f"Error al llamar a Gemini: {e}")
            return "No se pudo generar un consejo personalizado en este momento. Mantente seguro."
