import os

from flask import Flask

from .redis_client import create_redis_client


def create_app(test_config=None):
    """Application factory used by both Gunicorn and the tests."""
    app = Flask(__name__)
    app.config.from_mapping(
        REDIS_HOST=os.getenv("REDIS_HOST", "redis"),
        REDIS_PORT=int(os.getenv("REDIS_PORT", "6379")),
        REDIS_DB=int(os.getenv("REDIS_DB", "0")),
    )

    if test_config:
        app.config.update(test_config)

    app.extensions["redis"] = app.config.get("REDIS_CLIENT") or create_redis_client(app.config)

    from .routes import main
    app.register_blueprint(main)
    return app

