from flask import Flask
from config import Config
from flask_cors import CORS # <--- 1. Importa la librería

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    CORS(app) # <--- 2. Aplícala a tu aplicación

        # Registrar el Blueprint (nuestro controlador de rutas)
    from .controllers.quality_routes import quality_bp
    app.register_blueprint(quality_bp, url_prefix='/api')

    return app