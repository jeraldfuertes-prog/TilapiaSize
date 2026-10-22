from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "TilapiaSize API"
    environment: str = "development"
    database_url: str = "postgresql://postgres:postgres@localhost:5432/tilapiasize"
    cors_origins: str = "http://localhost:3000,http://localhost:8080,http://127.0.0.1:8080"
    cors_origin_regex: str = r"https?://(localhost|127\.0\.0\.1)(:\d+)?$"
    jwt_secret: str = "change-this-in-your-env-file"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 1440

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @property
    def cors_origins_list(self) -> list[str]:
        return [
            origin.strip()
            for origin in self.cors_origins.split(",")
            if origin.strip()
        ]


settings = Settings()
