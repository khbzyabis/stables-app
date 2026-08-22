import { SetMetadata } from '@nestjs/common';
import { Role } from '@prisma/client';

export const ROLES_KEY = 'roles';

/// Restrict a route to members holding one of these roles in the target stable.
export const Roles = (...roles: Role[]) => SetMetadata(ROLES_KEY, roles);
