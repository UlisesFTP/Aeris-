# Gunicorn configuration for production deployment
import multiprocessing
import os

# Server socket
bind = "0.0.0.0:5000"
backlog = 2048

# Worker processes
# Recommended: (2 x $num_cores) + 1
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"  # Use 'gevent' for async I/O if needed
worker_connections = 1000
max_requests = 1000  # Restart workers after this many requests (prevents memory leaks)
max_requests_jitter = 50  # Add randomness to max_requests
timeout = 60  # Workers silent for more than this are killed and restarted
keepalive = 5  # Keep-alive connections

# Logging
accesslog = "-"  # Log to stdout
errorlog = "-"   # Log errors to stdout
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = "air_quality_api"

# Server mechanics
daemon = False
pidfile = None
umask = 0
user = None
group = None
tmp_upload_dir = None

# SSL (if needed)
# keyfile = None
# certfile = None

# Preload application for better performance
preload_app = True

# Graceful shutdown timeout
graceful_timeout = 30

def on_starting(server):
    """
    Called just before the master process is initialized.
    """
    print("Starting Gunicorn server...")

def on_reload(server):
    """
    Called to recycle workers during a reload via SIGHUP.
    """
    print("Reloading Gunicorn workers...")

def when_ready(server):
    """
    Called just after the server is started.
    """
    print(f"Gunicorn server is ready. Listening on: {bind}")
    print(f"Workers: {workers}")

def worker_int(worker):
    """
    Called during worker shutdown.
    """
    print(f"Worker {worker.pid} interrupted")

def post_fork(server, worker):
    """
    Called just after a worker has been forked.
    """
    print(f"Worker spawned (pid: {worker.pid})")
