import secrets
import string
from urllib.parse import urlparse

from flask import Blueprint, current_app, flash, redirect, render_template, request, url_for
from redis.exceptions import RedisError

main = Blueprint("main", __name__)
ALPHABET = string.ascii_letters + string.digits


def redis_client():
    return current_app.extensions["redis"]


def is_valid_url(value):
    """Accept complete HTTP(S) URLs with a hostname."""
    try:
        parsed = urlparse(value)
        return parsed.scheme in {"http", "https"} and bool(parsed.netloc)
    except (TypeError, ValueError):
        return False


def create_unique_code(length=6):
    for _ in range(10):
        code = "".join(secrets.choice(ALPHABET) for _ in range(length))
        if not redis_client().exists(f"url:{code}"):
            return code
    raise RuntimeError("Could not create a unique short code")


@main.get("/")
def index():
    return render_template("index.html")


@main.post("/shorten")
def shorten():
    long_url = request.form.get("long_url", "").strip()
    if not long_url:
        flash("Please enter a URL.", "error")
        return render_template("index.html", long_url=long_url), 400
    if not is_valid_url(long_url):
        flash("Enter a valid URL beginning with http:// or https://.", "error")
        return render_template("index.html", long_url=long_url), 400

    try:
        code = create_unique_code()
        pipeline = redis_client().pipeline()
        pipeline.set(f"url:{code}", long_url)
        pipeline.set(f"clicks:{code}", 0)
        pipeline.execute()
    except (RedisError, RuntimeError):
        current_app.logger.exception("Unable to shorten URL")
        flash("The storage service is temporarily unavailable. Please try again.", "error")
        return render_template("index.html", long_url=long_url), 503

    short_url = url_for("main.follow_short_url", short_code=code, _external=True)
    return render_template("index.html", short_url=short_url, short_code=code, long_url=long_url), 201


@main.get("/<short_code>")
def follow_short_url(short_code):
    try:
        long_url = redis_client().get(f"url:{short_code}")
        if not long_url:
            flash("That short URL does not exist.", "error")
            return render_template("index.html"), 404
        redis_client().incr(f"clicks:{short_code}")
        return redirect(long_url)
    except RedisError:
        current_app.logger.exception("Unable to read short URL")
        flash("The storage service is temporarily unavailable. Please try again.", "error")
        return render_template("index.html"), 503


@main.get("/stats/<short_code>")
def stats(short_code):
    try:
        long_url = redis_client().get(f"url:{short_code}")
        if not long_url:
            flash("Statistics were not found for that short code.", "error")
            return render_template("index.html"), 404
        clicks = int(redis_client().get(f"clicks:{short_code}") or 0)
        short_url = url_for("main.follow_short_url", short_code=short_code, _external=True)
        return render_template("index.html", stats={"code": short_code, "url": long_url, "clicks": clicks}, short_url=short_url)
    except RedisError:
        current_app.logger.exception("Unable to load statistics")
        flash("The storage service is temporarily unavailable. Please try again.", "error")
        return render_template("index.html"), 503


@main.get("/health")
def health():
    try:
        redis_client().ping()
        return {"status": "healthy"}, 200
    except RedisError:
        return {"status": "unhealthy"}, 503

