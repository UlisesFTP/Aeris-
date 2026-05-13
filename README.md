# Aeris — Air Quality Monitoring App

> **Nombre interno del proyecto:** `AppContaminacion`
> **Nombre público de la app:** `Aeris` (anteriormente "AuraClima")
> **Idioma principal del código:** Español (comentarios, variables, UI) con soporte i18n (es/en)

## Descripción General

Aeris es una aplicación móvil multiplataforma (Android/iOS) de monitoreo de calidad del aire y clima en tiempo real. Permite a los usuarios visualizar datos de contaminación en un mapa interactivo, recibir alertas inteligentes cuando la calidad del aire empeora, consultar pronósticos meteorológicos y revisar historial de datos AQI.

**El proyecto consta de dos componentes:**

| Componente | Directorio | Tecnología | Despliegue |
|---|---|---|---|
| **Backend API** | `air_quality_api/` | Python 3.11 + Flask | Docker / Render |
| **Frontend Móvil** | `air_quality_flutter/` | Dart + Flutter | Android APK / iOS |

---

## Arquitectura de Alto Nivel

```
┌─────────────────────────────────────────────────────────────────┐
│                        USUARIO (Móvil)                          │
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐   │
│  │   Mapa   │  │ Alertas  │  │Historial │  │  Ajustes     │   │
│  │ Screen   │  │ Screen   │  │ Screen   │  │  Screen      │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────────────┘   │
│       │              │             │                            │
│       └──────────┬───┴─────────────┘                            │
│                  │                                              │
│       ┌──────────▼──────────┐                                   │
│       │    AppState          │  ◄── Provider (ChangeNotifier)   │
│       │  (SharedPreferences) │      Estado 100% local           │
│       └──────────┬──────────┘                                   │
│                  │                                              │
│       ┌──────────▼──────────┐                                   │
│       │    ApiService        │  ◄── HTTP client (package:http)  │
│       └──────────┬──────────┘                                   │
└──────────────────┼──────────────────────────────────────────────┘
                   │ HTTPS
                   ▼
┌──────────────────────────────────────────────────────────────────┐
│                   BACKEND (Flask API)                             │
│                                                                  │
│  ┌────────────────┐  ┌─────────────────┐  ┌──────────────────┐  │
│  │ quality_routes │  │ WeatherService  │  │  CacheService    │  │
│  │  (Blueprint)   │──│ (OpenWeather)   │──│  (Upstash Redis) │  │
│  └────────────────┘  └─────────────────┘  └──────────────────┘  │
│                                                                  │
│  Middleware: Flask-Limiter (rate limit) + Marshmallow (validación)│
│  Resilencia: tenacity (retry) + pybreaker (circuit breaker)      │
└──────────────────────────────────────────────────────────────────┘
                   │
                   ▼
        ┌──────────────────┐
        │  OpenWeatherMap  │  ◄── API externa (datos AQI + clima)
        │       API        │
        └──────────────────┘
```

---

## Stack Tecnológico Completo

### Backend (`air_quality_api/`)

| Dependencia | Versión | Propósito |
|---|---|---|
| `Flask` | latest | Micro-framework web |
| `Flask-Cors` | latest | CORS para peticiones del móvil |
| `Flask-Limiter` | latest | Rate limiting (200/hora, 100/min) |
| `gunicorn` | latest | Servidor WSGI de producción |
| `requests` | latest | Cliente HTTP para OpenWeather API |
| `redis` / `upstash-redis` | latest | Caché (Upstash REST API en prod, Redis local en dev) |
| `marshmallow` | latest | Validación de requests (coordenadas) |
| `structlog` | latest | Logging estructurado |
| `python-dotenv` | latest | Variables de entorno desde `.env` |
| `tenacity` | latest | Retry con exponential backoff (3 intentos) |
| `pybreaker` | latest | Circuit breaker (5 fallos → abre 60s) |

### Frontend (`air_quality_flutter/`)

| Dependencia | Versión | Propósito |
|---|---|---|
| `flutter` | SDK ≥3.4.1 <4.0.0 | Framework UI |
| `provider` | ^6.1.2 | Gestión de estado (ChangeNotifier) |
| `http` | ^1.2.1 | Cliente HTTP para el backend |
| `flutter_map` | ^7.0.1 | Mapa interactivo (OpenStreetMap) |
| `flutter_map_cancellable_tile_provider` | ^3.0.2 | Tiles cancelables para el mapa |
| `latlong2` | ^0.9.1 | Coordenadas geográficas |
| `geolocator` | ^12.0.0 | GPS del dispositivo |
| `firebase_core` | ^3.1.1 | Firebase SDK base |
| `firebase_messaging` | ^15.0.2 | Push notifications (FCM) |
| `flutter_local_notifications` | ^17.2.1 | Notificaciones locales (2 canales) |
| `fl_chart` | ^0.68.0 | Gráficos de historial AQI |
| `shared_preferences` | ^2.2.3 | Persistencia local (tema, ubicaciones, alertas) |
| `workmanager` | ^0.9.0+3 | Tareas en background (cada 15 min) |
| `flutter_dotenv` | ^5.1.0 | Variables de entorno (`assets/.env`) |
| `url_launcher` | ^6.3.0 | Abrir URLs externas |
| `permission_handler` | ^11.0.0 | Gestión de permisos del dispositivo |
| `flutter_iconly` | ^1.0.2 | Iconos de la barra de navegación |
| `flutter_localizations` | SDK | Soporte i18n (es/en) |
| `intl` | any | Formateo de fechas/números |

**Dev Dependencies:** `flutter_lints`, `rename_app` (→ "Aeris"), `flutter_launcher_icons`

---

## Estructura de Archivos Detallada

### Raíz del Proyecto

```
AppContaminacion/
├── README.md                   ← Este archivo (contexto para IA)
├── Manual.md                   ← Manual de usuario de la app
├── index.html                  ← Landing page web (standalone)
├── air_quality_api/            ← Backend Python/Flask
└── air_quality_flutter/        ← Frontend Flutter/Dart
```

### Backend: `air_quality_api/`

```
air_quality_api/
├── main.py                     ← Entry point. create_app() + app.run(debug, port=5000)
├── config.py                   ← Config class: OPENWEATHER_API_KEY, REDIS_URL
├── requirements.txt            ← Dependencias Python
├── Dockerfile                  ← Python 3.11-bullseye, gunicorn CMD
├── docker-compose.yml          ← api (port 5000) + redis (port 6379)
├── gunicorn.conf.py            ← Workers: (2×cores)+1, gthread, 4 threads, timeout 60s
├── .env                        ← Variables: OPENWEATHER_API_KEY, UPSTASH_REDIS_*
│
└── app/
    ├── __init__.py              ← Flask app factory: create_app()
    │                              - CORS config (origins: *)
    │                              - Rate limiter init (Upstash Redis)
    │                              - Error handlers (400,404,429,500)
    │                              - /api/health endpoint
    │                              - /api/metrics endpoint
    │                              - Blueprint registration (quality_bp)
    │
    ├── controllers/
    │   └── quality_routes.py    ← Blueprint 'quality' con 4 endpoints:
    │                              GET /api/air_quality?lat=&lon=  (caché 15min)
    │                              GET /api/history?lat=&lon=&days= (caché 6h)
    │                              GET /api/weather?lat=&lon=&lang= (caché 30min)
    │                              GET /api/search?q=  (proxy a Nominatim)
    │
    ├── services/
    │   ├── weather_service.py   ← WeatherService class:
    │   │                          - get_air_quality(lat, lon) → {aqi, components}
    │   │                          - get_current_weather(lat, lon, lang) → {temp, condition, icon}
    │   │                          - get_forecast(lat, lon, lang) → [{date, min/max_temp, icon}] (5 días)
    │   │                          - get_air_quality_history(lat, lon, days) → [{date, aqi}]
    │   │                          Usa: requests.Session (connection pooling), tenacity retry, pybreaker
    │   │
    │   └── cache_service.py     ← CacheService (Singleton):
    │                              - Usa upstash_redis.Redis.from_env()
    │                              - get(key), set(key, value, ttl_seconds)
    │                              - Fallback graceful si Redis no disponible
    │
    └── middleware/
        ├── rate_limiter.py      ← Flask-Limiter con Upstash Redis (rediss://)
        │                          Default: 200/hora, 100/min por IP o user_id
        │                          Fallback: in-memory si Redis falla
        │
        └── request_validator.py ← Marshmallow schemas:
                                   - CoordinatesSchema (lat: -90..90, lon: -180..180)
                                   - validate_request() decorator
                                   - sanitize_string() helper
```

### Frontend: `air_quality_flutter/`

```
air_quality_flutter/
├── pubspec.yaml                ← Dependencias, assets, fonts, app name "Aeris"
├── firebase.json               ← Firebase project config (studio-2504054971-f332e)
├── l10n.yaml                   ← Config de localización (arb-dir: lib/l10n)
├── analysis_options.yaml       ← Reglas de lint
│
├── assets/
│   ├── .env                    ← API_URL (URL del backend desplegado)
│   ├── icon.png                ← Ícono de la app (876KB)
│   └── fonts/
│       ├── Product Sans Regular.ttf
│       └── Product Sans Bold.ttf
│
└── lib/
    ├── main.dart               ← Entry point de la app Flutter
    ├── theme.dart              ← Temas light/dark (monocromático B&W)
    ├── firebase_options.dart   ← Config Firebase generada automáticamente
    │
    ├── l10n/                   ← Internacionalización
    │   ├── app_es.arb          ← Strings en español
    │   ├── app_en.arb          ← Strings en inglés
    │   ├── app_localizations.dart       ← Clase generada
    │   ├── app_localizations_es.dart    ← Delegado español
    │   └── app_localizations_en.dart    ← Delegado inglés
    │
    ├── core/
    │   └── app_state.dart      ← AppState (ChangeNotifier) — Estado global
    │
    ├── models/
    │   └── models.dart         ← Todos los modelos de datos
    │
    ├── api/
    │   ├── api_service.dart         ← Cliente HTTP al backend Flask
    │   └── notifications_service.dart ← FCM + Local Notifications (2 canales)
    │
    ├── services/
    │   ├── background_service.dart      ← WorkManager (tarea periódica c/15min)
    │   ├── alert_monitoring_service.dart ← Monitoreo de alertas en foreground
    │   ├── local_advice_service.dart     ← Consejos de salud (tablas OMS/EPA, offline)
    │   └── message_service.dart         ← SnackBars estilizados (success/error/warning/info)
    │
    ├── screens/
    │   ├── welcome_screen.dart  ← Onboarding (se muestra 1 vez, SharedPrefs)
    │   ├── main_shell.dart      ← Shell con NavigationBar (4 tabs)
    │   ├── map_screen.dart      ← Pantalla principal: mapa + panel de datos
    │   ├── alerts_screen.dart   ← Config de alertas por ubicación
    │   ├── history_screen.dart  ← Historial de visitas + ubicaciones guardadas
    │   ├── settings_screen.dart ← Ajustes (tema, permisos, legal)
    │   └── legal_screen.dart    ← Info legal / licencias
    │
    └── widgets/
        ├── history_chart.dart        ← Gráfico AQI (fl_chart)
        ├── location_picker_dialog.dart ← Dialog para buscar y seleccionar ubicación
        └── option_tile.dart          ← Widget reutilizable para opciones tipo switch
```

---

## Modelos de Datos (`models.dart`)

| Modelo | Campos principales | Origen |
|---|---|---|
| `AirQualityData` | `aqi` (int 1-6), `components` (Map: pm2_5, pm10, o3...) | API `/air_quality` |
| `LocationSearchResult` | `displayName`, `latitude`, `longitude` | API `/search` (Nominatim) |
| `HistoricalDataPoint` | `date` (DateTime), `aqi` (int) | API `/history` |
| `WeatherData` | `temp` (double), `condition` (String), `icon` (String) | API `/weather` |
| `ForecastItem` | `date`, `minTemp`, `maxTemp`, `icon`, `condition` | API `/weather` |
| `SavedLocation` | `id`, `name`, `displayName`, `latitude`, `longitude` | SharedPreferences |
| `AlertLocation` | `id`, `name`, `lat`, `lon`, `displayName`, `enabled` | SharedPreferences |
| `LocationVisit` | `locationName`, `lat`, `lon`, `visitedAt`, `searchCount` | SharedPreferences |
| `HealthAdvice` | `advice` (String) | LocalAdviceService |
| `TimeFilter` (enum) | `day` (1), `week` (7), `month` (30) | Local |

### Escala AQI (OpenWeatherMap)
| Valor | Nivel | Color | Emoji |
|---|---|---|---|
| 1 | Bueno | 🟢 #4CAF50 | 🍃 |
| 2 | Regular | 🟡 #8BC34A | 🍃 |
| 3 | Moderado | 🟠 #FFEB3B | ⚠️ |
| 4 | Malo | 🔴 #FF9800 | 🚨 |
| 5 | Muy Malo | 🟣 #E53935 | 🚨 |
| 6 | Peligroso | ⚫ #6A1B9A | ☢️ |

---

## Estado de la App (`AppState` — Provider)

**Clase:** `AppState extends ChangeNotifier` en `core/app_state.dart`

Todo el estado es **100% local** (SharedPreferences). No hay base de datos remota para usuarios.

### Propiedades del estado:

| Propiedad | Tipo | Persistencia | Descripción |
|---|---|---|---|
| `isDarkMode` | `bool` | `SharedPreferences('isDarkMode')` | Tema oscuro por defecto |
| `notificationSettings` | `Map<String, bool>` | `SharedPreferences('notificationSettings')` | Flags: miUbicacion, casa, trabajo, useAiRecommendations |
| `savedLocations` | `Map<String, SavedLocation>` | `SharedPreferences('savedLocations')` | Ubicaciones favoritas del usuario |
| `recentLocations` | `List<SavedLocation>` | `SharedPreferences('recentLocations')` | Últimas 5 búsquedas |
| `alertLocations` | `Map<String, AlertLocation>` | `SharedPreferences('alertLocations')` | Ubicaciones monitoreadas (default: Casa, Trabajo) |
| `locationHistory` | `List<LocationVisit>` | `SharedPreferences('locationVisitHistory')` | Historial de visitas (máx 50) |
| `currentHistoryFilter` | `TimeFilter` | En memoria | Filtro temporal activo |
| `currentLanguageCode` | `String` | En memoria | Idioma detectado del sistema |

### Métodos clave:
- `toggleTheme()` — Alterna light/dark
- `saveLocation(name, lat, lon)` — Guarda ubicación favorita
- `removeSavedLocation(id)` — Elimina favorita
- `addRecentLocation(result)` — Añade a recientes (máx 5)
- `recordLocationVisit(lat, lon, name)` — Registra visita con contador
- `updateAlertLocation(id, lat, lon, name)` — Configura ubicación de alerta
- `toggleAlertLocation(id, enabled)` — Activa/desactiva alertas
- `checkAlertLocationsNow()` — Verifica AQI en ubicaciones de alerta
- `loadLocationHistory(filter)` — Carga historial filtrado por tiempo

---

## Endpoints de la API

Base URL configurada en `assets/.env` como `API_URL`.

| Método | Endpoint | Parámetros | Caché TTL | Descripción |
|---|---|---|---|---|
| GET | `/api/air_quality` | `lat`, `lon` (float) | 15 min | Calidad del aire actual (AQI + componentes) |
| GET | `/api/history` | `lat`, `lon` (float), `days` (int, default 7) | 6 horas | Historial AQI de los últimos N días |
| GET | `/api/weather` | `lat`, `lon` (float), `lang` (string, default 'es') | 30 min | Clima actual + pronóstico 5 días |
| GET | `/api/search` | `q` (string) | Sin caché | Búsqueda de ubicaciones (proxy a Nominatim) |
| GET | `/api/health` | — | — | Health check (verifica Redis) |
| GET | `/api/metrics` | — | — | Métricas del servicio |

### Flujo de datos de una petición:
```
Flutter ApiService → HTTPS → Flask quality_routes.py
  → CacheService.get(key)
    → HIT: return cached JSON
    → MISS: WeatherService → OpenWeather API (con retry + circuit breaker)
      → CacheService.set(key, data, ttl)
      → return JSON
```

---

## Sistema de Notificaciones

### Canales de Android

| Canal | ID | Importancia | Sonido | Propósito |
|---|---|---|---|---|
| **Estado del Clima** | `weather_status` | LOW | ❌ | Notificación persistente tipo Google Weather (ID fijo=42) |
| **Alertas de Calidad** | `air_quality_alerts` | HIGH | ✅ | Alertas intrusivas cuando AQI ≥ 4 |

### Background Service (WorkManager)

- **Frecuencia:** Cada 15 minutos (mínimo de Android)
- **Constantes:** `taskName = 'check_air_quality_changes'`
- **Intervalo mínimo entre alertas:** 2 horas por ubicación
- **Flujo:**
  1. Carga ubicaciones de alerta activas desde SharedPreferences
  2. Fetch paralelo: AQI + clima para cada ubicación
  3. Actualiza notificación persistente de estado (primera ubicación)
  4. Si AQI ≥ 4 y han pasado ≥2h → envía alerta intrusiva
  5. Persiste estado conocido en SharedPreferences

### FCM (Firebase Cloud Messaging)
- Handler de background: `firebaseBackgroundMessageHandler()` (top-level)
- Handler de foreground: listener en `NotificationService.initNotifications()`
- Ambos actualizan la notificación de estado

---

## Flujo de la Aplicación

### Inicio (`main.dart`)
```
1. WidgetsFlutterBinding.ensureInitialized()
2. dotenv.load('assets/.env')
3. Firebase.initializeApp()
4. Si NO es web:
   a. FirebaseMessaging.onBackgroundMessage(handler)
   b. NotificationService.initNotifications()
   c. Workmanager().initialize(callbackDispatcher)
   d. Registrar tarea periódica (15 min)
5. Leer SharedPreferences('showWelcome')
6. runApp con ChangeNotifierProvider<AppState>
7. MyApp decide: showWelcome ? WelcomeScreen : MainShell
```

### Navegación (MainShell)
```
MainShell (StatefulWidget)
├── Tab 0: MapScreen        ← Pantalla principal
├── Tab 1: AlertsScreen     ← Configuración de alertas
├── Tab 2: HistoryScreen    ← Historial y favoritos
└── Tab 3: SettingsScreen   ← Ajustes de la app

NavBar: Pill-style custom (_PillNavBar) con animaciones
- Active: pill oscura con icono + label
- Inactive: solo icono
- Iconos: flutter_iconly (IconlyLight/IconlyBold)
```

### MapScreen — Carga de datos en 2 fases
```
FASE 1 (Crítica — bloquea UI):
  Future.wait([getAirQuality(), getWeather()])
  → Muestra AQI + clima inmediatamente
  → Quita spinner

FASE 2 (Background — no bloquea):
  - LocalAdviceService.getAqiAdvice() → instantáneo, offline
  - LocalAdviceService.getWeatherAdvice() → instantáneo, offline
  - getHistory() → API call asíncrono
  - showNotification() → actualiza barra de estado (solo Android/iOS)
```

---

## Sistema de Temas (`theme.dart`)

**Diseño:** Monocromático blanco y negro con Material 3.

| Propiedad | Light | Dark |
|---|---|---|
| Primary | #000000 (negro) | #FFFFFF (blanco) |
| Surface | #FFFFFF | #1A1A1A |
| Scaffold BG | #FAFAFA | #0A0A0A |
| Bordes | #E5E5E5 | #333333 |
| Font | ProductSans | ProductSans |
| Card radius | 20px | 20px |
| Button radius | 14px | 14px |
| Input radius | 14px | 14px |

---

## Internacionalización (i18n)

- **Archivos ARB:** `lib/l10n/app_es.arb` (español), `lib/l10n/app_en.arb` (inglés)
- **Generación automática:** `flutter: generate: true` en `pubspec.yaml`
- **Clases generadas:** `AppLocalizations`, `AppLocalizationsEs`, `AppLocalizationsEn`
- **Detección de idioma:** Automática desde el sistema operativo (`didChangeLocales`)
- **Uso:** `AppLocalizations.of(context)!.navMap`
- **Idioma por defecto:** Español

---

## Variables de Entorno

### Backend (`air_quality_api/.env`)
```env
OPENWEATHER_API_KEY=<clave de OpenWeatherMap>
UPSTASH_REDIS_REST_URL=<URL REST de Upstash>
UPSTASH_REDIS_REST_TOKEN=<Token de Upstash>
UPSTASH_REDIS_ENDPOINT=<Endpoint Redis protocol de Upstash (para Flask-Limiter)>
```

### Frontend (`air_quality_flutter/assets/.env`)
```env
API_URL=https://<tu-dominio>/api
```

---

## Configuración y Desarrollo

### Backend

```bash
cd air_quality_api
python -m venv .venv
.venv\Scripts\activate          # Windows
pip install -r requirements.txt
# Crear .env con las variables necesarias
python main.py                  # Dev: localhost:5000
# O con Docker:
docker-compose up --build
```

### Frontend

```bash
cd air_quality_flutter
flutter pub get
# Configurar assets/.env con la URL del backend
# Configurar android/app/google-services.json (Firebase)
flutter run                     # Dev
flutter build apk --release     # Build Android
```

**APKs generados en:** `air_quality_flutter/build/app/outputs/flutter-apk/`

---

## Decisiones de Diseño Importantes

1. **Sin base de datos de usuarios:** Todo el estado del usuario (ubicaciones, preferencias, alertas) se guarda en SharedPreferences (local en el dispositivo). No hay autenticación ni backend de usuarios.

2. **Sin dependencias de IA:** Los consejos de salud se generan localmente con tablas estáticas basadas en estándares OMS/EPA (`LocalAdviceService`). No hay llamadas a APIs de IA.

3. **Caché agresivo:** El backend cachea todas las respuestas de OpenWeather en Redis/Upstash para reducir costos y latencia (15min AQI, 30min clima, 6h historial).

4. **Resiliencia del backend:** `tenacity` (retry exponential backoff, 3 intentos) + `pybreaker` (circuit breaker, abre después de 5 fallos, reset 60s).

5. **Timeout largo en Flutter:** 45 segundos para HTTP requests para tolerar cold starts de Render.

6. **Notificaciones tipo Google Weather:** Notificación persistente de baja importancia que se sobreescribe silenciosamente (ID fijo 42), más alertas intrusivas separadas para AQI malo.

7. **NavBar custom:** Barra de navegación tipo "pill" con animaciones, no usa `BottomNavigationBar` estándar.

8. **Carga en 2 fases:** MapScreen muestra datos críticos (AQI+clima) inmediatamente y carga historial + consejos en background.

---

## Convenciones del Código

- **Idioma de comentarios:** Español
- **Idioma de variables/funciones:** Mixto (español en nombres descriptivos, inglés en términos técnicos)
- **Gestión de estado:** Provider con un único `AppState` global
- **Persistencia:** Exclusivamente `SharedPreferences` (JSON serializado)
- **Comunicación API:** Toda vía `ApiService` centralizado
- **Errores de UI:** `MessageService` (SnackBars estilizados)
- **Iconos NavBar:** `flutter_iconly` (IconlyLight para inactivo, IconlyBold para activo)
- **Tipografía:** Product Sans (fuente personalizada en `assets/fonts/`)
