import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface AuthUser {
  /// Supabase user id (subject of the JWT).
  id: string;
  email?: string;
}

/// Injects the authenticated user resolved by SupabaseAuthGuard.
export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): AuthUser => {
    const req = ctx.switchToHttp().getRequest();
    return req.user as AuthUser;
  },
);
