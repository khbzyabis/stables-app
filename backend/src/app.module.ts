import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { ThrottlerStorageRedisService } from 'nestjs-throttler-storage-redis';
import { LoggerModule } from 'nestjs-pino';
import type Redis from 'ioredis';

import { HealthModule } from './health/health.module';
import { HorsesModule } from './horses/horses.module';
import { PrismaModule } from './prisma/prisma.module';
import { REDIS, RedisModule } from './redis/redis.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    LoggerModule.forRoot({
      pinoHttp: {
        // Structured JSON logs; never log Authorization headers or bodies.
        redact: ['req.headers.authorization', 'req.headers.cookie'],
        autoLogging: true,
      },
    }),
    RedisModule,
    PrismaModule,

    // Distributed rate limiting: the counter lives in Redis so limits are
    // correct across all API replicas behind the load balancer.
    ThrottlerModule.forRootAsync({
      inject: [ConfigService, REDIS],
      useFactory: (config: ConfigService, redis: Redis) => ({
        throttlers: [
          {
            name: 'default',
            ttl: Number(config.get('RATE_LIMIT_TTL_MS') ?? 60_000),
            limit: Number(config.get('RATE_LIMIT_MAX') ?? 100),
          },
        ],
        storage: new ThrottlerStorageRedisService(redis),
      }),
    }),

    HealthModule,
    HorsesModule,
  ],
  providers: [
    // Apply the rate limiter to every route by default.
    { provide: APP_GUARD, useClass: ThrottlerGuard },
  ],
})
export class AppModule {}
