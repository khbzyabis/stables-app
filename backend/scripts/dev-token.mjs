// Mint a development login token (JWT) for local testing, signed with the same
// secret the API verifies against. DEV ONLY — never use in production; real
// tokens come from Supabase Auth.
//
//   node scripts/dev-token.mjs
//
// Uses SUPABASE_JWT_SECRET from the environment, or the local-dev default that
// matches infra/docker-compose.yml.

import { SignJWT } from 'jose';

const secret = process.env.SUPABASE_JWT_SECRET || 'local-dev-secret-change-me';
// Matches the seeded dev user (prisma/seed.ts).
const userId = process.env.DEV_USER_ID || '11111111-1111-1111-1111-111111111111';

const jwt = await new SignJWT({ email: 'ahmad@serc.ae', role: 'authenticated' })
  .setProtectedHeader({ alg: 'HS256' })
  .setSubject(userId)
  .setIssuedAt()
  .setExpirationTime('12h')
  .sign(new TextEncoder().encode(secret));

// eslint-disable-next-line no-console
console.log(jwt);
