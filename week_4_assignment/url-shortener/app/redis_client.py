import redis


def create_redis_client(config):
    """Create one reusable Redis connection pool for the application."""
    return redis.Redis(
        host=config["REDIS_HOST"],
        port=config["REDIS_PORT"],
        db=config["REDIS_DB"],
        decode_responses=True,
        socket_connect_timeout=3,
        socket_timeout=3,
    )

