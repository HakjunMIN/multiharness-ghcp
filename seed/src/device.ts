import type { DeviceCapabilities } from './types.ts';

const DEFAULTS: DeviceCapabilities = {
  ramMb: 8192,
  hasNpu: true,
  batteryPct: 80,
  thermalState: 'nominal',
  osVersion: '15',
};

// Workshop stub: no real hardware probing happens here.
export function probeDevice(overrides: Partial<DeviceCapabilities> = {}): DeviceCapabilities {
  return { ...DEFAULTS, ...overrides };
}
