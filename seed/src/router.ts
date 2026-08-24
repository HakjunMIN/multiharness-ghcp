import type { DeviceCapabilities, RequestContext, RouteDecision } from './types.ts';

export function decideRoute(caps: DeviceCapabilities, ctx: RequestContext): RouteDecision {
  if (caps.thermalState === 'critical') {
    return { target: 'blocked', reason: 'device thermal critical' };
  } else {
    if (caps.batteryPct < 15) {
      if (!ctx.networkOnline) {
        return { target: 'blocked', reason: 'low battery and offline' };
      }
    }
    if (!ctx.networkOnline) {
      if (caps.hasNpu) {
        if (caps.ramMb >= 4096) {
          return { target: 'on-device', reason: 'offline, device capable' };
        } else {
          return { target: 'blocked', reason: 'offline, device not capable' };
        }
      } else {
        return { target: 'blocked', reason: 'offline, device not capable' };
      }
    } else {
      if (ctx.payloadBytes > 262144) {
        return { target: 'cloud', reason: 'payload too large for device' };
      } else {
        if (caps.hasNpu) {
          if (caps.ramMb >= 4096) {
            if (caps.thermalState !== 'serious') {
              return { target: 'on-device', reason: 'device capable' };
            }
          }
        }
      }
    }
  }
  return { target: 'cloud', reason: 'fallback to cloud' };
}
