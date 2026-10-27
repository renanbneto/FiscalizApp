import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../generated/prisma/client.js';

export function criarPrisma(databaseUrl = process.env.DATABASE_URL): PrismaClient {
  if (!databaseUrl) throw new Error('DATABASE_URL não definida');
  return new PrismaClient({ adapter: new PrismaPg({ connectionString: databaseUrl }) });
}
