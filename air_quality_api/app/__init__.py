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
    
    # Disable debug mode in production
    app.config['DEBUG'] = False
    
    # Configure CORS with specific origins for security
    # In production, replace '*' with your Flutter app's domain
    CORS(app, resources={
        r"/api/*": {
            "origins": "*",  # TODO: Restrict to specific domains in production
            "methods": ["GET", "POST", "DELETE"],
            "allow_headers": ["Content-Type"]
        }
    })
    
    # Initialize rate limiter with Upstash Redis backend
    # Upstash Redis credentials are loaded from environment variables
    from .middleware.rate_limiter import init_limiter
    limiter = init_limiter(app, redis_url=None)
    
    # Register error handlers
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
    
    # Health check endpoint
    @app.route('/api/health', methods=['GET'])
    def health_check():
        """
        Health check endpoint to verify service status.
        Returns 200 if all critical services are operational.
        """
        from .services.database_service import DatabaseService
        from .services.cache_service import CacheService
        
        health_status = {
            "status": "healthy",
            "services": {}
        }
        
        # Check MongoDB connection
        try:
            db_service = DatabaseService(
                db_uri=Config.MONGO_URI,
                db_name=Config.MONGO_DB_NAME
            )
            if db_service.client is not None:
                db_service.client.admin.command('ping')
                health_status["services"]["mongodb"] = "connected"
            else:
                health_status["services"]["mongodb"] = "disconnected"
                health_status["status"] = "degraded"
        except Exception as e:
            logger.error("health_check_mongodb_failed", error=str(e))
            health_status["services"]["mongodb"] = "error"
            health_status["status"] = "unhealthy"
        
        # Check Upstash Redis connection
        try:
            cache_service = CacheService()
            if cache_service.client:
                # Test with a simple operation instead of ping()
                # Upstash REST API doesn't support ping() reliably
                test_key = "__health_check__"
                cache_service.client.set(test_key, "ok", ex=10)
                result = cache_service.client.get(test_key)
                if result:
                    health_status["services"]["redis"] = "connected"
                else:
                    health_status["services"]["redis"] = "disconnected"
                    health_status["status"] = "degraded"
            else:
                health_status["services"]["redis"] = "disconnected"
                health_status["status"] = "degraded"
        except Exception as e:
            logger.error("health_check_redis_failed", error=str(e))
            health_status["services"]["redis"] = "error"
            # Redis is non-critical, so don't mark as unhealthy
        
        status_code = 200 if health_status["status"] in ["healthy", "degraded"] else 503
        return jsonify(health_status), status_code
    
    # Metrics endpoint
    @app.route('/api/metrics', methods=['GET'])
    def get_metrics():
        """
        Simple metrics endpoint for monitoring.
        Returns basic statistics about the service.
        """
        from .services.cache_service import CacheService
        
        metrics = {
            "service": "air_quality_api",
            "version": "1.0.0",
            "uptime": "calculated_on_demand"
        }
        
        # Try to get Upstash Redis info
        try:
            cache_service = CacheService()
            if cache_service.client:
                # Upstash REST API doesn't support INFO command
                # Just report that Redis is available
                metrics["redis"] = {
                    "status": "connected",
                    "note": "Upstash REST API - detailed stats unavailable"
                }
        except Exception as e:
            logger.error("metrics_redis_error", error=str(e))
            metrics["redis"] = "unavailable"
        
        return jsonify(metrics), 200
    
    # Register API routes blueprint
    from .controllers.quality_routes import quality_bp, limiter as routes_limiter
    routes_limiter._limiter = limiter  # Share limiter instance
    app.register_blueprint(quality_bp, url_prefix='/api')
    
    logger.info("application_initialized", debug=app.config['DEBUG'])
    
    return app