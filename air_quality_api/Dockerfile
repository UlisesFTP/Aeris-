# Usa una imagen base de Python delgada
FROM python:3.11-slim

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia el archivo de dependencias
COPY requirements.txt .

# Instala las dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Copia el resto del código de la aplicación
COPY . .

# Expone el puerto que Flask usará
EXPOSE 5000

# El comando para correr la aplicación. 'host=0.0.0.0' es crucial para que sea accesible desde fuera del contenedor.
CMD ["flask", "run", "--host=0.0.0.0"]
