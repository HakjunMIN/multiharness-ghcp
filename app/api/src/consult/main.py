from fastapi import FastAPI

from consult.settings import Settings

app = FastAPI(title="Product consultation runway")


@app.get("/healthz")
def healthz() -> dict[str, str]:
    settings = Settings.from_env(require_apim=False)
    return {"status": "ok", "brand": settings.brand_name}
