import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '@prisma/client';

import { PrismaService } from '../../prisma/prisma.service';
import { ROLES_KEY } from '../decorators/roles.decorator';

/// Enforces the role matrix per membership. The target stable is taken from the
/// `stableId` route param; the caller must hold one of the required roles in
/// that stable. This mirrors the product rule: role is per membership.
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const required = this.reflector.getAllAndOverride<Role[] | undefined>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );
    if (!required || required.length === 0) return true;

    const req = context.switchToHttp().getRequest();
    const userId: string | undefined = req.user?.id;
    const stableId: string | undefined = req.params?.stableId;
    if (!userId || !stableId) {
      throw new ForbiddenException('Stable membership required');
    }

    const membership = await this.prisma.membership.findUnique({
      where: { userId_stableId: { userId, stableId } },
      select: { role: true },
    });
    if (!membership || !required.includes(membership.role)) {
      throw new ForbiddenException('Insufficient role for this stable');
    }
    // Expose the resolved role to handlers if needed.
    req.membershipRole = membership.role;
    return true;
  }
}
