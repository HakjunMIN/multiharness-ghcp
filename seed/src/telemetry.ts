export type TelemetryValue = string | number | boolean;

export interface TelemetryEvent {
  name: string;
  props: Record<string, TelemetryValue>;
}

const buffer: TelemetryEvent[] = [];

export function emit(name: string, props: Record<string, TelemetryValue>): void {
  buffer.push({ name, props });
}

export function drain(): TelemetryEvent[] {
  const out = buffer.slice();
  buffer.length = 0;
  return out;
}
