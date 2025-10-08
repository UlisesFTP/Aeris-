# Usamos una imagen base explícita y estable (Debian Bullseye)
FROM python:3.11-bullseye

# Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /app

# --- PASO CLAVE FINAL: Instalar herramientas de compilación y librerías SSL ---
# Esto proporciona al entorno las herramientas necesarias para que pymongo
# compile sus dependencias de seguridad y se conecte a MongoDB Atlas.
RUN apt-get update && apt-get install -y ca-certificates build-essential libssl-dev

# Copiamos el archivo de dependencias
COPY requirements.txt .

# Instalamos las dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiamos el resto del código de la aplicación
COPY . .

# Exponemos el puerto que usará Flask
EXPOSE 5000

# El comando que se ejecutará para iniciar la aplicación
CMD ["flask", "run", "--host=0.0.0.0"]