import fakeredis
import pytest

from app import create_app


@pytest.fixture()
def client():
    fake_redis = fakeredis.FakeRedis(decode_responses=True)
    app = create_app({"TESTING": True, "REDIS_CLIENT": fake_redis})
    return app.test_client()


def test_homepage_loads(client):
    response = client.get("/")
    assert response.status_code == 200
    assert b"Make long links" in response.data


@pytest.mark.parametrize("url", ["", "not-a-url", "ftp://example.com"])
def test_rejects_invalid_url(client, url):
    response = client.post("/shorten", data={"long_url": url})
    assert response.status_code == 400


def test_shorten_redirect_and_click_tracking(client):
    response = client.post("/shorten", data={"long_url": "https://example.com/long"})
    assert response.status_code == 201
    short_code = response.data.decode().split("/stats/")[1].split('"')[0]

    redirect_response = client.get(f"/{short_code}")
    assert redirect_response.status_code == 302
    assert redirect_response.location == "https://example.com/long"

    stats_response = client.get(f"/stats/{short_code}")
    assert stats_response.status_code == 200
    assert b"https://example.com/long" in stats_response.data
    assert b'class="count">1<' in stats_response.data


def test_unknown_code_returns_404(client):
    assert client.get("/missing").status_code == 404

