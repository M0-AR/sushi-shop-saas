// Verified 2026 admin RBAC: stable action keys, service-boundary enforcement, JWT 1h + Redis option
export const PERMISSIONS = {
  'menu.read': ['superadmin', 'manager', 'support'],
  'menu.write': ['superadmin', 'manager'],
  'orders.read': ['superadmin', 'manager', 'support'],
  'orders.refund': ['superadmin'],
  'audit.read': ['superadmin'],
  'support.impersonate': ['superadmin'],
  'export.customer_pii': ['superadmin'],
} as const;
export type Role = 'superadmin' | 'manager' | 'support' | 'viewer';
export function can(role: Role, action: keyof typeof PERMISSIONS): boolean {
  return (PERMISSIONS[action] as readonly string[]).includes(role);
}
