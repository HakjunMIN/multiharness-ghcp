from pydantic import BaseModel, Field


class ConsultRequest(BaseModel):
    question: str = Field(min_length=1)


class Citation(BaseModel):
    title: str
    url: str


class ConsultResponse(BaseModel):
    answer: str
    citations: list[Citation]
