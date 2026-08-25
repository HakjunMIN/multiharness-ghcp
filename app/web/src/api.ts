export type Health = { status: string; brand: string };

export async function fetchHealth(): Promise<Health> {
  const response = await fetch("/healthz");
  if (!response.ok) {
    throw new Error(`health check failed: ${response.status}`);
  }
  return response.json() as Promise<Health>;
}
