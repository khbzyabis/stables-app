import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { jwtVerify } from 'jose';

/// Verifies the JWT issued by Supabase Auth (GoTrue) on every request and
/// attaches the resolved user to the request. Signature is checked against the
/// shared Supabase JWT secret — a forged or expired token is rejected.
@Injectable()
export class SupabaseAuthGuard implements CanActivate {
  private readonly secret: Uint8Array;

  constructor(config: ConfigService) {
    const secret = config.get<string>('SUPABASE_JWT_SECRET') ?? '';
    this.secret = new TextEncoder().encode(secret);
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest();
    const header: string | undefined = req.headers?.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing bearer token');
    }
    const token = header.slice('Bearer '.length);
    try {
      const { payload } = await jwtVerify(token, this.secret);
      req.user = { id: String(payload.sub), email: payload.email as string };
      return true;
    } catch {
      throw new UnauthorizedException('Invalid or expired token');
    }
  }
}
