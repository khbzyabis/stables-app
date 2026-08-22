import { ValidationPipe, VersioningType } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import helmet from 'helmet';

import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  const config = app.get(ConfigService);

  // Security headers (CSP, no-sniff, frame-deny, HSTS in prod behind TLS).
  app.use(helmet());

  // Lock CORS to known app/dashboard origins.
  const origins = (config.get<string>('CORS_ORIGINS') ?? '')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
  app.enableCors({ origin: origins.length ? origins : false, credentials: true });

  // URI versioning: /v1/...
  app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' });

  // Reject unknown/wrong-typed fields before they reach a handler. Combined with
  // Prisma's parameterized queries, this closes the injection surface.
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  // Drain in-flight requests on SIGTERM/SIGINT for zero-downtime rolling deploys.
  app.enableShutdownHooks();

  const port = Number(config.get('PORT') ?? 3000);
  await app.listen(port, '0.0.0.0');
}

void bootstrap();
