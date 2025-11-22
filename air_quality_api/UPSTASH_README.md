# Upstash Redis Migration Summary

This document provides instructions for migrating from local Redis to Upstash Redis (cloud-based Redis service).

## Environment Variables Required

Add the following to your `.env` file:

```
UPSTASH_REDIS_REST_URL=your_upstash_url_here
UPSTASH_REDIS_REST_TOKEN=your_upstash_token_here
```

You can get these values from your Upstash dashboard at https://console.upstash.com/

## Changes Made

### 1. Dependencies (`requirements.txt`)

- Added `upstash-redis` library

### 2. Cache Service (`app/services/cache_service.py`)

- Updated to use `Redis.from_env()` from `upstash_redis` library
- Reads credentials from `UPSTASH_REDIS_REST_URL` and `UPSTASH_REDIS_REST_TOKEN` environment variables
- No longer requires `redis_url` parameter in constructor

### 3. Rate Limiter (`app/middleware/rate_limiter.py`)

- Attempts to use Upstash credentials if available
- Falls back to local Redis if Upstash credentials not found
- Compatible with Flask-Limiter

### 4. Application Initialization (`app/__init__.py`)

- Updated to pass `None` for redis_url (Upstash uses env vars)
- Health check updated to work with Upstash
- Metrics endpoint handles Upstash limitations (INFO command may not be fully supported via REST API)

### 5. Gemini Service (`app/services/gemini_service.py`)

- Updated to use new `CacheService()` constructor (no parameters)

### 6. Quality Routes (`app/controllers/quality_routes.py`)

- Updated cache service initialization

## Testing

1. **Add environment variables to `.env`**:

   ```
   UPSTASH_REDIS_REST_URL=https://your-endpoint.upstash.io
   UPSTASH_REDIS_REST_TOKEN=your_token
   ```

2. **Rebuild Docker image**:

   ```bash
   docker compose build
   ```

3. **Start containers**:

   ```bash
   docker compose up
   ```

4. **Test health endpoint**:

   ```bash
   curl http://localhost:5000/api/health
   ```

   Expected response should show Redis as "connected"

5. **Test caching**:
   Make a request to get Gemini advice, then make the same request again. The second request should be faster (cache hit).

## Docker Compose Changes

You can now remove the `redis` service from `docker-compose.yml` since you're using Upstash's cloud Redis:

```yaml
# Remove this entire section:
# redis:
#   image: "redis:alpine"
#   ...
```

Also update the API service dependencies:

```yaml
api:
  # Remove redis dependency
  depends_on: [] # Or remove this section entirely
```

## Benefits of Upstash Redis

- ✅ No need to manage Redis instance
- ✅ Automatic backups
- ✅ Global replication
- ✅ Pay-per-use pricing
- ✅ Built-in persistence
- ✅ TLS/SSL encryption
- ✅ REST API access

## Rollback Instructions

If you need to rollback to local Redis:

1. Remove `UPSTASH_REDIS_REST_URL` and `UPSTASH_REDIS_REST_TOKEN` from `.env`
2. Add back `REDIS_URL=redis://redis:6379` to `.env`
3. The rate limiter will automatically fallback to local Redis
4. Update `CacheService` to accept `redis_url` parameter again
