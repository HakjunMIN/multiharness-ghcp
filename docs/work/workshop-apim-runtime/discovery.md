# Workshop APIM runtime discovery

## Approved decisions

- `APIM_BASE_URL` and `APIM_KEY` are runtime values stored only in the
  gitignored repository-root `.env`.
- The committed repository uses only non-routable URL examples such as
  `https://workshop-apim.example.invalid`.
- Model synthesis uses the Responses API operation at
  `${APIM_BASE_URL}/model/v1/responses`.
- Foundry IQ retrieval uses
  `${APIM_BASE_URL}/search/knowledgebases/{KNOWLEDGE_BASE_NAME}/retrieve`.
- The workshop knowledge base name is `workshop-products`.
- Both APIM operations authenticate with the participant subscription key in
  the `Ocp-Apim-Subscription-Key` header.
- No separate model endpoint, search endpoint, or model ID runtime setting is
  introduced.

## Observed problem

`python-dotenv` currently searches relative to the process context. The normal
development script sources the repository-root `.env`, but starting the API
directly from `app/api` can miss that file. When this happens, the application
falls back to the committed `한빛전자` brand and required APIM settings are
absent.

The APIM base URL alone also does not document which operations the participant
implementation must call. Without the model and retrieval route contracts,
participants can configure a valid key and host but still receive route errors.

## Proposed change

1. Extend the fixed APIM runtime boundary in `AGENTS.md` with the model route,
   retrieval route, knowledge base name, and subscription-key header.
2. Set `KNOWLEDGE_BASE_NAME=workshop-products` in `.env.example`; keep
   `APIM_BASE_URL` and `APIM_KEY` empty.
3. Load the repository-root `.env` by an explicit path in API settings so
   direct API startup and `scripts/dev.sh` behave consistently.
4. Keep operator details and non-routable examples in
   `docs/setup/azure-setup.md`.
5. Add network-free tests for the root `.env` lookup and committed APIM route
   contract.

## Constraints

- Do not commit the live APIM hostname, subscription key, origin credentials,
  questions, answers, or provider payloads.
- Preserve the single `APIM_BASE_URL` plus `APIM_KEY` runtime boundary.
- Default unit and contract tests must not use the network.
- Live APIM verification remains behind the `live` marker.

## Success criteria

- API startup resolves the repository-root `.env` regardless of whether it is
  launched through `scripts/dev.sh` or directly from `app/api`.
- A copied `.env.example` already selects `workshop-products`.
- Participants can derive both APIM request URLs and the authentication header
  from committed repository guidance.
- Missing runtime host or key fails explicitly instead of silently attempting a
  malformed request.

## Related artifacts

- `AGENTS.md`
- `CONTEXT.md`
- `.env.example`
- `app/api/src/consult/settings.py`
- `docs/setup/azure-setup.md`
