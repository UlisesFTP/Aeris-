from flask import Flask, jsonify
from config import Config
from flask_cors import CORS
import structlog

# Configure structured logging
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.stdlib.ProcessorFormatter.wrap_for_formatter,
    ],
    logger_factory=structlog.stdlib.LoggerFactory(),
)

logger = structlog.get_logger()


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    app.config['DEBUG'] = False

    CORS(app, resources={
        r"/api/*": {
            "origins": "*",
            "methods": ["GET", "POST", "DELETE"],
            "allow_headers": ["Content-Type"]
        }
    })

    # Initialize rate limiter with Upstash Redis backend
    from .middleware.rate_limiter import init_limiter
    limiter = init_limiter(app, redis_url=None)

    # ── Error handlers ────────────────────────────────────────────────────────
    @app.errorhandler(400)
    def bad_request(e):
        logger.error("bad_request", error=str(e))
        return jsonify({"error": "Bad request", "message": str(e)}), 400

    @app.errorhandler(404)
    def not_found(e):
        return jsonify({"error": "Resource not found"}), 404

    @app.errorhandler(429)
    def ratelimit_handler(e):
        logger.warning("rate_limit_exceeded", error=str(e))
        return jsonify({
            "error": "Rate limit exceeded",
            "message": "Too many requests. Please try again later."
        }), 429

    @app.errorhandler(500)
    def internal_server_error(e):
        logger.error("internal_server_error", error=str(e))
        return jsonify({
            "error": "Internal server error",
            "message": "An unexpected error occurred. Please try again later."
        }), 500

    @app.errorhandler(Exception)
    def handle_exception(e):
        logger.error("unhandled_exception", error=str(e), exc_info=True)
        return jsonify({
            "error": "Internal server error",
            "message": "An unexpected error occurred."
        }), 500

    # ── Health check ──────────────────────────────────────────────────────────
    @app.route('/api/health', methods=['GET'])
    def health_check():
        """Lightweight health check — only checks Redis cache."""
        from .services.cache_service import CacheService

        health_status = {
            "status": "healthy",
            "services": {}
        }

        try:
            cache_service = CacheService()
            if cache_service.client:
                test_key = "__health_check__"
                cache_service.client.set(test_key, "ok", ex=10)
                result = cache_service.client.get(test_key)
                health_status["services"]["redis"] = "connected" if result else "disconnected"
            else:
                health_status["services"]["redis"] = "disconnected"
                health_status["status"] = "degraded"
        except Exception as e:
            logger.error("health_check_redis_failed", error=str(e))
            health_status["services"]["redis"] = "error"

        status_code = 200 if health_status["status"] in ["healthy", "degraded"] else 503
        return jsonify(health_status), status_code

    # ── Metrics ───────────────────────────────────────────────────────────────
    @app.route('/api/metrics', methods=['GET'])
    def get_metrics():
        from .services.cache_service import CacheService

        metrics = {
            "service": "air_quality_api",
            "version": "2.0.0",
        }

        try:
            cache_service = CacheService()
            if cache_service.client:
                metrics["redis"] = {
                    "status": "connected",
                    "note": "Upstash REST API"
                }
        except Exception as e:
            logger.error("metrics_redis_error", error=str(e))
            metrics["redis"] = "unavailable"

        return jsonify(metrics), 200

    # ── Register blueprint ────────────────────────────────────────────────────
    from .controllers.quality_routes import quality_bp, limiter as routes_limiter
    routes_limiter._limiter = limiter
    app.register_blueprint(quality_bp, url_prefix='/api')

    logger.info("application_initialized", debug=app.config['DEBUG'])

    return app