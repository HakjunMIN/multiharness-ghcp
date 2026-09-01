export type Citation = {
  title: string;
  url: string;
};

export type ConsultResponse = {
  answer: string;
  citations: Citation[];
};

export async function consult(question: string): Promise<ConsultResponse> {
  const response = await fetch("/api/consult", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ question }),
  });

  if (!response.ok) {
    throw new Error(`consult failed: ${response.status}`);
  }

  return response.json() as Promise<ConsultResponse>;
}
