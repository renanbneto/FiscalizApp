import 'dotenv/config';
import { defineConfig } from 'prisma/config';

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed/index.ts',
  },
  datasource: {
    // Sem fallback o `prisma generate` do postinstall falharia sem .env
    url: process.env.DATABASE_URL ?? '',
  },
});
