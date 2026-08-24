import { test } from 'node:test';
import assert from 'node:assert/strict';
import { decideRoute } from '../src/router.ts';
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

test('blocks when the device is thermally critical', () => {
  const d = decideRoute(probeDevice({ thermalState: 'critical' }), ctx());
  assert.equal(d.target, 'blocked');
  assert.equal(d.reason, 'device thermal critical');
});

test('blocks when the battery is low and the device is offline', () => {
  const d = decideRoute(probeDevice({ batteryPct: 5 }), ctx({ networkOnline: false }));
  assert.equal(d.target, 'blocked');
  assert.equal(d.reason, 'low battery and offline');
});

test('runs on-device when offline but capable', () => {
  const d = decideRoute(probeDevice(), ctx({ networkOnline: false }));
  assert.equal(d.target, 'on-device');
  assert.equal(d.reason, 'offline, device capable');
});

test('blocks when offline and the device is not capable', () => {
  const d = decideRoute(probeDevice({ hasNpu: false }), ctx({ networkOnline: false }));
  assert.equal(d.target, 'blocked');
  assert.equal(d.reason, 'offline, device not capable');
});

test('routes to cloud when the payload is too large', () => {
  const d = decideRoute(probeDevice(), ctx({ payloadBytes: 262145 }));
  assert.equal(d.target, 'cloud');
  assert.equal(d.reason, 'payload too large for device');
});

test('runs on-device when the device is capable', () => {
  const d = decideRoute(probeDevice(), ctx());
  assert.equal(d.target, 'on-device');
  assert.equal(d.reason, 'device capable');
});

test('falls back to cloud when the device is not capable', () => {
  const d = decideRoute(probeDevice({ ramMb: 2048 }), ctx());
  assert.equal(d.target, 'cloud');
  assert.equal(d.reason, 'fallback to cloud');
});

test('known gap: the region is not consulted when routing', () => {
  const kr = decideRoute(probeDevice(), ctx({ region: 'KR' }));
  const eu = decideRoute(probeDevice(), ctx({ region: 'EU' }));
  assert.deepEqual(kr, eu);
});
