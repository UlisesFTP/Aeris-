"""
Rate limiting middleware using Flask-Limiter and Redis.
Prevents API abuse and ensures fair usage across all users.
"""
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask import request

def get_user_id():
    """
    Extract user_id from request for per-user rate limiting.
    Falls back to IP address if no user_id present.
    """
    # Try to get user_id from JSON body
    if request.is_json:
        data = request.get_json(silent=True)
        if data and 'user_id' in data:
            return data['user_id']
    
    # Try to get from query parameters
    user_id = request.args.get('user_id')
    if user_id:
        return user_id
    
    # Fall back to IP address
    return get_remote_address()

def init_limiter(app, redis_url):
    """
    Initialize rate limiter with Redis backend.
    
    Args:
        app: Flask application instance
        redis_url: Redis connection URL
    
    Returns:
        Configured Limiter instance
    """
    limiter = Limiter(
        app=app,
        key_func=get_user_id,
        storage_uri=redis_url,
        default_limits=["200 per hour", "100 per minute"],  # Global limits
        strategy="fixed-window",
        headers_enabled=True,  # Send rate limit info in response headers
    )
    
    return limiter
