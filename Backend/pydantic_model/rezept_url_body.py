from pydantic import BaseModel


class rezept_url_body(BaseModel):
    url: str