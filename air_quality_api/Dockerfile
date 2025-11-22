# Use explicit and stable Python base image (Debian Bullseye)
FROM python:3.11-bullseye

# Set working directory
WORKDIR /app

# Install build tools and SSL libraries for pymongo
RUN apt-get update && apt-get install -y \
    ca-certificates \
    build-essential \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*  

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose Flask port
EXPOSE 5000

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/api/health', timeout=5)"

# Use Gunicorn for production
CMD ["gunicorn", "--config", "gunicorn.conf.py", "main:app"]