# FiscalizApp

Aplicativo mobile (React Native) e sistema web (React) que reúne dados públicos
sobre salários, benefícios e gastos de agentes políticos municipais.

Status: **planejamento / fundação**. Município piloto: **Campo Largo – PR**.
Stack: Node.js/TypeScript, React (Next.js) e React Native (Expo).

## Documentação

- [docs/IDEIA.md](docs/IDEIA.md): a ideia, o piloto e as decisões
- [docs/PLANEJAMENTO.md](docs/PLANEJAMENTO.md): fontes, arquitetura e roadmap
- [docs/API.md](docs/API.md): endpoints da API (v1)
- [docs/MODELO-DE-DADOS.md](docs/MODELO-DE-DADOS.md): modelo de dados e schema Prisma

## Estrutura

```
apps/
  api/            # NestJS + Prisma (por enquanto: schema, migrations e seed)
packages/         # tipos compartilhados (a criar)
infra/
  docker-compose.yml   # PostgreSQL 16, Redis 7, MinIO (S3)
docs/
```

## Rodando localmente

Requisitos: Node 22+, pnpm 10 (`corepack enable`) e Docker.

```bash
pnpm install                       # instala e gera o Prisma Client
cp .env.example .env               # variáveis do docker-compose
cp apps/api/.env.example apps/api/.env

pnpm infra:up                      # sobe Postgres, Redis e MinIO
pnpm db:migrate                    # aplica as migrations
pnpm db:seed                       # 15 vereadores de Campo Largo (dados NÃO verificados)
pnpm db:studio                     # opcional: navegar no banco
```

| Serviço | Endereço |
|---|---|
| PostgreSQL | `localhost:5432` (bancos `fiscalizapp` e `fiscalizapp_test`) |
| Redis | `localhost:6379` |
| MinIO (API S3) | `http://localhost:9000` (bucket `fontes-brutas`) |
| MinIO (console) | `http://localhost:9001` |

Para começar do zero: `pnpm infra:down && docker volume rm fiscalizapp_postgres-data`.
