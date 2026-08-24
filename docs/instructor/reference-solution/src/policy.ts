export function isCloudAllowed(region: string): boolean {
  return region !== 'EU';
}
