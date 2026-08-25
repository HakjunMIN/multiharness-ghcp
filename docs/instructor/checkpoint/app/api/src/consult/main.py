from fastapi import Depends, FastAPI

from consult.agent import AgentFrameworkSynthesizer, Synthesizer
from consult.contracts import ConsultRequest, ConsultResponse
from consult.retrieval import ApimRetriever, Retriever
from consult.settings import Settings

app = FastAPI(title="Product consultation agent")


def get_retriever() -> Retriever:
    return ApimRetriever(Settings.from_env())


def get_synthesizer() -> Synthesizer:
    return AgentFrameworkSynthesizer(Settings.from_env())


@app.get("/healthz")
def healthz() -> dict[str, str]:
    settings = Settings.from_env(require_apim=False)
    return {"status": "ok", "brand": settings.brand_name}


@app.post("/api/consult", response_model=ConsultResponse)
async def consult(
    request: ConsultRequest,
    retriever: Retriever = Depends(get_retriever),
    synthesizer: Synthesizer = Depends(get_synthesizer),
) -> ConsultResponse:
    result = await retriever.retrieve(request.question)
    answer = await synthesizer.synthesize(request.question, result)
    return ConsultResponse(answer=answer, citations=result.citations)
