/**
 * Strongly typed role enumeration for SchoolBus360 Admin Portal.
 */
export const UserRole = Object.freeze({
  PARENT: 'parent',
  DRIVER: 'driver',
  ADMIN: 'admin',
  UNKNOWN: 'unknown',

  isValid: (role) => [UserRole.PARENT, UserRole.DRIVER, UserRole.ADMIN].includes(role),
  isAdmin: (role) => role === UserRole.ADMIN,
});
