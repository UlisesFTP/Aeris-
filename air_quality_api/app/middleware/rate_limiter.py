"""
Rate Limiter Middleware with Upstash Redis Support

Flask-Limiter requires a Redis-protocol compatible connection, not REST API.
Upstash provides both REST API and Redis protocol endpoints.
"""
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask import request
import os

def get_user_id():
    """
    Determine the rate limiting key (user ID from request or IP address).
    """
    user_id = request.args.get('user_id') or request.json.get('user_id') if request.is_json else None
    return user_id if user_id else get_remote_address()

def init_limiter(app, redis_url=None):
    """
    Initialize Flask-Limiter with Upstash Redis (using Redis protocol, not REST API).
    
    Args:
        app: Flask application instance
        redis_url: Not used (kept for backward compatibility)
    
    Returns:
        Configured Limiter instance
    """
    # Get Upstash Redis endpoint from environment
    # Note: We need the REDIS endpoint with TLS (rediss://), not the REST endpoint (https://)
    upstash_redis_endpoint = os.getenv('UPSTASH_REDIS_ENDPOINT')
    upstash_redis_password = os.getenv('UPSTASH_REDIS_REST_TOKEN')
    
    if upstash_redis_endpoint and upstash_redis_password:
        # Use Upstash Redis with TLS (rediss://) - Upstash requires SSL
        # Format: rediss://default:PASSWORD@endpoint:port?ssl_cert_reqs=required
        storage_uri = f"rediss://default:{upstash_redis_password}@{upstash_redis_endpoint}"
    else:
        # Fallback to local Redis for development
        storage_uri = "redis://redis:6379"
    
    try:
        limiter = Limiter(
            app=app,
            key_func=get_user_id,
            default_limits=["200 per hour", "100 per minute"],
            storage_uri=storage_uri,
            storage_options={
                "socket_connect_timeout": 10,
                "socket_timeout": 10,
            },
            headers_enabled=True,
        )
        print(f"Rate limiter initialized with storage: {storage_uri.split('@')[0]}@...")
    except Exception as e:
        print(f"Error initializing rate limiter: {e}")
        # Fallback to in-memory storage (not recommended for production)
        limiter = Limiter(
            app=app,
            key_func=get_user_id,
            default_limits=["200 per hour", "100 per minute"],
            headers_enabled=True,
        )
        print("WARNING: Using in-memory rate limiting (not production-ready)")
    
    return limiter
