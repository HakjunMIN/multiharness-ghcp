import type { DeviceCapabilities, RequestContext, RouteDecision } from './types.ts';
import { decideRoute } from './router.ts';
import { emit } from './telemetry.ts';

export function route(caps: DeviceCapabilities, ctx: RequestContext): RouteDecision {
  const decision = decideRoute(caps, ctx);
  if (!ctx.userOptedOutTelemetry) {
    emit('route.decided', {
      feature: ctx.feature,
      region: ctx.region,
      target: decision.target,
      reason: decision.reason,
    });
  }
  return decision;
}
