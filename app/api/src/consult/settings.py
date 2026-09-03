import os
from dataclasses import dataclass

from dotenv import load_dotenv

# Skip under pytest (PYTEST_VERSION is set for the whole session) so unit
# tests stay isolated from the real .env, which can hold a real customer
# brand name and APIM secrets; only the running server process auto-loads it.
if "PYTEST_VERSION" not in os.environ:
    load_dotenv(override=False)


@dataclass(frozen=True)
class Settings:
    brand_name: str
    apim_base_url: str | None
    apim_key: str | None
    knowledge_base_name: str | None

    @classmethod
    def from_env(cls, *, require_apim: bool = True) -> "Settings":
        settings = cls(
            brand_name=os.getenv("BRAND_NAME", "한빛전자"),
            apim_base_url=os.getenv("APIM_BASE_URL"),
            apim_key=os.getenv("APIM_KEY"),
            knowledge_base_name=os.getenv("KNOWLEDGE_BASE_NAME"),
        )
        if require_apim:
            missing = [
                name
                for name, value in (
                    ("APIM_BASE_URL", settings.apim_base_url),
                    ("APIM_KEY", settings.apim_key),
                    ("KNOWLEDGE_BASE_NAME", settings.knowledge_base_name),
                )
                if not value
            ]
            if missing:
                raise ValueError("missing required settings: " + ", ".join(missing))
        return settings
