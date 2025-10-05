# main.py
from app import create_app

app = create_app()

if __name__ == '__main__':
    # El modo debug reinicia el servidor automáticamente con cada cambio
    app.run(debug=True, port=5000)