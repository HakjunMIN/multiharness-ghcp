export type {
  InferenceTarget,
  ThermalState,
  DeviceCapabilities,
  RequestContext,
  RouteDecision,
} from './types.ts';
export { probeDevice } from './device.ts';
export { decideRoute } from './router.ts';
export { emit, drain } from './telemetry.ts';
export type { TelemetryEvent, TelemetryValue } from './telemetry.ts';
export { route } from './gate.ts';
