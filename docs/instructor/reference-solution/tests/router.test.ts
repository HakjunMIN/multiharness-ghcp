import test from 'node:test';
import assert from 'node:assert/strict';
import { decideRoute } from '../src/router.ts';
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

test('blocks thermally critical devices', () => {
  assert.equal(
    decideRoute(probeDevice({ thermalState: 'critical' }), request()).target,
    'blocked',
  );
});

test('runs capable offline requests on-device', () => {
  assert.equal(
    decideRoute(probeDevice(), request({ networkOnline: false })).target,
    'on-device',
  );
});

test('blocks incapable offline requests', () => {
  assert.equal(
    decideRoute(
      probeDevice({ hasNpu: false }),
      request({ networkOnline: false }),
    ).target,
    'blocked',
  );
});

test('routes large payloads to cloud in allowed regions', () => {
  assert.equal(
    decideRoute(probeDevice(), request({ region: 'KR', payloadBytes: 1048576 })).target,
    'cloud',
  );
});

test('known gap: the region is now consulted when routing', () => {
  const capable = probeDevice();
  const incapable = probeDevice({ hasNpu: false, ramMb: 2048 });
  assert.equal(decideRoute(capable, request({ region: 'EU' })).target, 'on-device');
  assert.equal(decideRoute(incapable, request({ region: 'EU' })).target, 'blocked');
  assert.equal(decideRoute(incapable, request({ region: 'KR' })).target, 'cloud');
});
