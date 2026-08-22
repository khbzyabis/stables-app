import { Global, Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

export const REDIS = Symbol('REDIS');

/// A single shared ioredis client — used by the rate limiter (so counters are
/// correct across all API replicas) and for caching.
@Global()
@Module({
  providers: [
    {
      provide: REDIS,
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const url = config.get<string>('REDIS_URL') ?? 'redis://localhost:6379';
        return new Redis(url, { maxRetriesPerRequest: 3, lazyConnect: false });
      },
    },
  ],
  exports: [REDIS],
})
export class RedisModule {}
