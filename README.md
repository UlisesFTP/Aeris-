# AppContaminacion

## Descripción

AppContaminacion es una aplicación de monitoreo de la calidad del aire en tiempo real. Proporciona datos actualizados, pronósticos y alertas para ayudar a los usuarios a mantenerse informados sobre la contaminación del aire en su área.

La aplicación consta de dos componentes principales:
1.  **API de Calidad del Aire (`air_quality_api`)**: Un servicio de backend que recopila, procesa y sirve datos sobre la calidad del aire.
2.  **Aplicación Flutter (`air_quality_flutter`)**: Una aplicación móvil multiplataforma (iOS/Android) que presenta los datos a los usuarios de una manera intuitiva.

## Arquitectura

-   **Backend**: La API está construida con **Python** y el micro-framework **Flask**. Se conecta a una base de datos **MongoDB** para almacenar lecturas de calidad del aire y utiliza **Redis** para el almacenamiento en caché de datos para un acceso más rápido.
-   **Frontend**: La aplicación móvil está desarrollada con **Dart** y el framework **Flutter**, lo que permite una única base de código para las aplicaciones de iOS y Android.

## Características

-   **Mapa Interactivo**: Visualiza estaciones de monitoreo de calidad del aire en un mapa.
-   **Datos en Tiempo Real**: Obtén lecturas de calidad del aire en tiempo real para tu ubicación actual.
-   **Historial de Datos**: Revisa gráficos con datos históricos para observar tendencias.
-   **Alertas y Notificaciones**: Recibe notificaciones push sobre cambios importantes en la calidad del aire.
-   **Manejo de Ubicación**: Utiliza el GPS del dispositivo para proporcionar datos relevantes para la ubicación del usuario.

## Tech Stack

**Backend (`air_quality_api`)**
-   Python 3
-   Flask
-   Gunicorn
-   MongoDB (con `pymongo`)
-   Redis
-   Docker

**Frontend (`air_quality_flutter`)**
-   Dart
-   Flutter
-   Provider (para gestión de estado)
-   Http (para comunicación con la API)
-   Geolocator & FlutterMap (para mapas y ubicación)
-   Firebase Messaging & Flutter Local Notifications (para alertas)
-   FL Chart (para gráficos históricos)

## Configuración y Puesta en Marcha

### Backend (`air_quality_api`)

1.  **Navega al directorio**:
    ```bash
    cd air_quality_api
    ```
2.  **Crea un entorno virtual**:
    ```bash
    python -m venv .venv
    source .venv/bin/activate  # En Windows usa `.venv\Scripts\activate`
    ```
3.  **Instala las dependencias**:
    ```bash
    pip install -r requirements.txt
    ```
4.  **Configura las variables de entorno**:
    -   Crea un archivo `.env` en la raíz de `air_quality_api`.
    -   Añade las configuraciones necesarias (e.g., `MONGO_URI`, `REDIS_URL`, etc.).
5.  **Ejecuta la aplicación**:
    ```bash
    gunicorn --bind 0.0.0.0:5000 main:app
    ```
    Alternativamente, puedes usar Docker:
    ```bash
    docker-compose up --build
    ```

### Frontend (`air_quality_flutter`)

1.  **Navega al directorio**:
    ```bash
    cd air_quality_flutter
    ```
2.  **Obtén las dependencias de Flutter**:
    ```bash
    flutter pub get
    ```
3.  **Configura Firebase**:
    -   Asegúrate de tener el archivo `google-services.json` en `android/app/`.
    -   Configura las credenciales de Firebase para iOS según la documentación oficial.
4.  **Ejecuta la aplicación**:
    ```bash
    flutter run
    ```

## Estructura del Proyecto

```
AppContaminacion/
├── air_quality_api/        # Código fuente del backend (Python/Flask)
│   ├── app/                # Lógica principal de la aplicación
│   ├── requirements.txt    # Dependencias de Python
│   ├── Dockerfile
│   └── ...
├── air_quality_flutter/    # Código fuente del frontend (Flutter/Dart)
│   ├── lib/                # Lógica principal de la aplicación Flutter
│   │   ├── screens/        # Pantallas de la UI
│   │   ├── api/            # Servicios para conectar con el backend
│   │   └── ...
│   ├── pubspec.yaml        # Dependencias de Dart/Flutter
│   └── ...
└── README.md               # Este archivo
```
