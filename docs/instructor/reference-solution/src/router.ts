import type { DeviceCapabilities, RequestContext, RouteDecision } from './types.ts';
import { isCloudAllowed } from './policy.ts';

function canRunOnDevice(caps: DeviceCapabilities): boolean {
  return caps.hasNpu && caps.ramMb >= 4096 && caps.thermalState !== 'serious';
}

export function decideRoute(caps: DeviceCapabilities, ctx: RequestContext): RouteDecision {
  if (caps.thermalState === 'critical') {
    return { target: 'blocked', reason: 'device thermal critical' };
  }

  if (caps.batteryPct < 15 && !ctx.networkOnline) {
    return { target: 'blocked', reason: 'low battery and offline' };
  }

  if (!ctx.networkOnline) {
    return canRunOnDevice(caps)
      ? { target: 'on-device', reason: 'offline, device capable' }
      : { target: 'blocked', reason: 'offline, device not capable' };
  }

  if (!isCloudAllowed(ctx.region)) {
    return canRunOnDevice(caps)
      ? { target: 'on-device', reason: 'regional policy requires on-device' }
      : { target: 'blocked', reason: 'regional policy blocks cloud' };
  }

  if (ctx.payloadBytes > 262144) {
    return { target: 'cloud', reason: 'payload too large for device' };
  }

  return canRunOnDevice(caps)
    ? { target: 'on-device', reason: 'device capable' }
    : { target: 'cloud', reason: 'fallback to cloud' };
}
