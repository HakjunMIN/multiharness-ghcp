export type InferenceTarget = 'on-device' | 'cloud' | 'blocked';

export type ThermalState = 'nominal' | 'fair' | 'serious' | 'critical';

export interface DeviceCapabilities {
  ramMb: number;
  hasNpu: boolean;
  batteryPct: number;
  thermalState: ThermalState;
  osVersion: string;
}

export interface RequestContext {
  feature: string;
  payloadBytes: number;
  networkOnline: boolean;
  region: string;
  userOptedOutTelemetry?: boolean;
}

export interface RouteDecision {
  target: InferenceTarget;
  reason: string;
}
