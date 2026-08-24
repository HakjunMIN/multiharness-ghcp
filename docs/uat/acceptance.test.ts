import test from 'node:test';
import assert from 'node:assert/strict';
import { drain, probeDevice, route } from '../../seed/src/index.ts';
import type { RequestContext } from '../../seed/src/index.ts';

function request(overrides: Partial<RequestContext> = {}): RequestContext {
  return {
    feature: 'summarize',
    payloadBytes: 1024,
    networkOnline: true,
    region: 'KR',
    ...overrides,
  };
}

test.beforeEach(() => {
  drain();
});

test('UAT-01: EU capable requests never use cloud', () => {
  const result = route(probeDevice(), request({ region: 'EU', payloadBytes: 1048576 }));
  assert.equal(result.target, 'on-device');
});

test('UAT-02: EU incapable requests are blocked', () => {
  const result = route(
    probeDevice({ hasNpu: false, ramMb: 2048 }),
    request({ region: 'EU' }),
  );
  assert.equal(result.target, 'blocked');
});

test('UAT-03: KR incapable online requests can use cloud', () => {
  const result = route(
    probeDevice({ hasNpu: false, ramMb: 2048 }),
    request({ region: 'KR' }),
  );
  assert.equal(result.target, 'cloud');
});

test('UAT-04: telemetry opt-out emits no event', () => {
  route(probeDevice(), request({ userOptedOutTelemetry: true }));
  assert.equal(drain().length, 0);
});

test('UAT-05: telemetry opt-in emits one event', () => {
  route(probeDevice(), request({ userOptedOutTelemetry: false }));
  assert.equal(drain().length, 1);
});
