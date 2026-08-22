import { Controller, Get, Inject, VERSION_NEUTRAL } from '@nestjs/common';
import { HealthCheck, HealthCheckService } from '@nestjs/terminus';
import { SkipThrottle } from '@nestjs/throttler';
import type Redis from 'ioredis';

import { PrismaService } from '../prisma/prisma.service';
import { REDIS } from '../redis/redis.module';

/// Endpoints the load balancer polls. `/healthz` = process is up (liveness);
/// `/readyz` = dependencies (DB + Redis) are reachable (readiness). Unhealthy
/// replicas are pulled from rotation automatically. Exempt from rate limiting
/// so LB polling never trips the limiter.
@SkipThrottle()
@Controller({ version: VERSION_NEUTRAL })
export class HealthController {
  constructor(
    private readonly health: HealthCheckService,
    private readonly prisma: PrismaService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  @Get('healthz')
  liveness(): { status: string } {
    return { status: 'ok' };
  }

  @Get('readyz')
  @HealthCheck()
  readiness() {
    return this.health.check([
      async () => {
        await this.prisma.$queryRaw`SELECT 1`;
        return { database: { status: 'up' } };
      },
      async () => {
        const pong = await this.redis.ping();
        return { redis: { status: pong === 'PONG' ? 'up' : 'down' } };
      },
    ]);
  }
}
