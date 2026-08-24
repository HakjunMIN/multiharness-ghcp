import test from 'node:test';
import assert from 'node:assert/strict';
import { route } from '../src/gate.ts';
import { drain } from '../src/telemetry.ts';
import { probeDevice } from '../src/device.ts';
import type { RequestContext } from '../src/types.ts';

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

test('known gap: telemetry is not emitted when the user opted out', () => {
  route(probeDevice(), request({ userOptedOutTelemetry: true }));
  assert.equal(drain().length, 0);
});

test('telemetry is emitted when the user did not opt out', () => {
  route(probeDevice(), request({ userOptedOutTelemetry: false }));
  assert.equal(drain().length, 1);
});
