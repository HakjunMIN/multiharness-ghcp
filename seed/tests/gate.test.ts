import { test, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { route } from '../src/gate.ts';
import { decideRoute } from '../src/router.ts';
import { drain } from '../src/telemetry.ts';
import { probeDevice } from '../src/device.ts';
import type { RequestContext } from '../src/types.ts';

function ctx(overrides: Partial<RequestContext> = {}): RequestContext {
  return {
    feature: 'summarize',
    payloadBytes: 1024,
    networkOnline: true,
    region: 'KR',
    ...overrides,
  };
}

beforeEach(() => {
  drain();
});

test('route returns the same decision as decideRoute', () => {
  const caps = probeDevice();
  assert.deepEqual(route(caps, ctx()), decideRoute(caps, ctx()));
});

test('route emits exactly one telemetry event carrying the region', () => {
  route(probeDevice(), ctx({ region: 'EU' }));
  const events = drain();
  assert.equal(events.length, 1);
  assert.equal(events[0].name, 'route.decided');
  assert.equal(events[0].props.region, 'EU');
});

// Lab 3 flips this test. Do not delete it: change the expectation and say why
// in the commit message.
test('known gap: telemetry is emitted even when the user opted out', () => {
  route(probeDevice(), ctx({ userOptedOutTelemetry: true }));
  assert.equal(drain().length, 1);
});
