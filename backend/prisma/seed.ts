// Development seed — a known, friendly dataset for local work and demos.
//
// This is for DEV/staging only; production databases start empty and are
// populated by real user activity. Run explicitly:
//
//   npx prisma db seed
//
// It is idempotent (upserts on fixed ids), so re-running is safe.

import { PrismaClient, Role, HorseStatus } from '@prisma/client';

const prisma = new PrismaClient();

const DEV_USER_ID = '11111111-1111-1111-1111-111111111111';
const DEV_STABLE_ID = '22222222-2222-2222-2222-222222222222';
const DEV_MEMBERSHIP_ID = '33333333-3333-3333-3333-333333333333';

async function main() {
  const user = await prisma.user.upsert({
    where: { id: DEV_USER_ID },
    update: {},
    create: { id: DEV_USER_ID, email: 'ahmad@serc.ae', fullName: 'Ahmad' },
  });

  const stable = await prisma.stable.upsert({
    where: { id: DEV_STABLE_ID },
    update: {},
    create: { id: DEV_STABLE_ID, name: 'Serc' },
  });

  await prisma.membership.upsert({
    where: { id: DEV_MEMBERSHIP_ID },
    update: {},
    create: {
      id: DEV_MEMBERSHIP_ID,
      userId: user.id,
      stableId: stable.id,
      role: Role.admin,
    },
  });

  const horses = [
    { name: 'Kiki', statusLine: 'Farrier due Thursday', status: HorseStatus.well, age: '9 years', breed: 'Arabian' },
    { name: 'Comme Ci', statusLine: 'Box rest · day 3 of 10', status: HorseStatus.watch },
    { name: 'Abby', statusLine: 'Schooled yesterday · 40 min', status: HorseStatus.well },
  ];

  for (const h of horses) {
    const existing = await prisma.horse.findFirst({
      where: { stableId: stable.id, name: h.name },
    });
    if (!existing) {
      await prisma.horse.create({ data: { stableId: stable.id, ...h } });
    }
  }

  const count = await prisma.horse.count({ where: { stableId: stable.id } });
  // eslint-disable-next-line no-console
  console.log(`Seeded stable "${stable.name}" with ${count} horses.`);
}

main()
  .catch((e) => {
    // eslint-disable-next-line no-console
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
