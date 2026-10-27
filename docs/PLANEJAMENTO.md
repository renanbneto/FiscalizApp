# FiscalizApp — Planejamento

> Aplicativo mobile (React Native) e sistema web (React) que reúne, a partir de
> dados públicos, informações sobre salários, benefícios e gastos de agentes
> políticos de um município.

---

## 1. Visão do produto

**Problema:** os dados existem (Lei de Acesso à Informação, LC 131/2009, TSE,
Tribunais de Contas), mas estão espalhados por vários portais, em formatos
diferentes e difíceis de entender para o cidadão comum.

**Proposta:** um único lugar onde o cidadão escolhe seu município e vê, de forma
simples, com fonte citada:

- quanto ganha cada agente político (prefeito, vice, vereadores, secretários);
- quais benefícios e verbas recebe (diárias, verbas indenizatórias, auxílios);
- quanto e com o que a Prefeitura e a Câmara gastam;
- patrimônio declarado e financiamento de campanha.

**Princípios inegociáveis**

1. **Toda informação tem fonte**: link original, data de coleta e cópia do arquivo bruto.
2. **Neutralidade**: o app mostra dados e indicadores, não faz acusações.
3. **Simplicidade**: linguagem cidadã ("quanto custa um vereador por mês"), não jargão contábil.
4. **Reprodutibilidade**: qualquer número exibido pode ser reconstruído a partir do dado bruto.

### Personas

| Persona | Necessidade |
|---|---|
| Cidadão comum | "Quanto ganha meu vereador? Ele gasta muito com diárias?" |
| Jornalista local | Exportar dados, comparar períodos, encontrar pautas |
| Ativista / observatório social | Monitorar contratos e cruzar fornecedores com doadores |
| Estudante / pesquisador | Séries históricas e download em CSV |

---

## 2. Fontes de dados públicos

A cobertura varia muito entre municípios. A **Fase 0** existe justamente para
mapear o que está disponível no município piloto.

### Fontes nacionais (cobrem todos os municípios)

| Fonte | O que traz | Acesso |
|---|---|---|
| **TSE – Dados Abertos** (`dadosabertos.tse.jus.br`) | Candidatos eleitos, **bens declarados**, **receitas e despesas de campanha** (doadores) | CSV em lote por eleição |
| **SICONFI / Tesouro** (`apidatalake.tesouro.gov.br`) | RREO, RGF, despesa com pessoal, despesas por função do município | API REST pública |
| **PNCP** (`pncp.gov.br/api/consulta`) | Licitações, contratos e atas (Lei 14.133/2021) | API REST pública |
| **Querido Diário** (`queridodiario.ok.org.br/api`) | Texto dos diários oficiais municipais (nomeações, leis de subsídio, decretos) | API REST pública, cobertura parcial |
| **Portal da Transparência – CGU** (`api.portaldatransparencia.gov.br`) | Transferências federais, emendas parlamentares, convênios destinados ao município | API REST com chave gratuita |
| **Receita Federal – CNPJ** | Quadro societário de fornecedores (para cruzamentos) | Dump mensal em CSV |
| **IBGE** (`servicodados.ibge.gov.br`) | Código IBGE, população (para comparar municípios de porte similar) | API REST pública |

### Fontes estaduais / municipais (variam por município)

| Fonte | O que traz | Observação |
|---|---|---|
| **Tribunal de Contas do Estado (TCE)** | Folha, despesas, empenhos, contratos. Ex.: TCE-SP, TCE-RS, TCE-PE, TCE-MG, TCE-PR têm dados abertos | Melhor fonte quando existe; padroniza vários municípios |
| **Portal da Transparência da Prefeitura** | Folha de pagamento nominal, diárias, empenhos | Geralmente sem API → raspagem (scraping). Muitos usam o mesmo fornecedor de sistema (IPM, Betha, Fiorilli, Elotech, etc.), então **um scraper serve vários municípios** |
| **Portal da Câmara Municipal** | Subsídio dos vereadores, verbas de gabinete, diárias, cota parlamentar | Idem |
| **Pedidos via LAI (e-SIC)** | Qualquer dado não publicado | Prazo de 20+10 dias; útil para preencher lacunas |

### Base legal

- **Lei 12.527/2011 (LAI)** e **LC 131/2009**: obrigam a transparência ativa.
- **STF, Tema 483 (ARE 652.777)**: é legítima a divulgação nominal da remuneração de servidores públicos.
- **LGPD (Lei 13.709/2018)**: aplicável — publicar apenas o necessário ao interesse público, nunca CPF completo, endereço ou dados de saúde/dependentes que eventualmente apareçam na folha.

---

## 3. Funcionalidades

### MVP (município piloto)

- [ ] Seleção de município (inicialmente só o piloto)
- [ ] Lista de agentes políticos (prefeito, vice, vereadores, secretários) com foto e partido
- [ ] **Perfil do político**
  - remuneração mensal (bruto/líquido) com histórico em gráfico
  - diárias e verbas indenizatórias
  - patrimônio declarado (evolução entre eleições — TSE)
  - principais doadores de campanha (TSE)
- [ ] **Painel do município**: custo total da Câmara, gasto por categoria, despesa com pessoal × limite da LRF
- [ ] Busca por nome
- [ ] Rodapé "Fonte" em todo dado, com link e data de atualização
- [ ] Página "Sobre os dados / metodologia"

### V1

- [ ] Seguir político → notificação push quando houver dado novo
- [ ] Comparativo com municípios de porte similar (IBGE)
- [ ] Contratos e licitações (PNCP / TCE)
- [ ] Cards compartilháveis (WhatsApp / Instagram) com o dado + fonte
- [ ] Exportar CSV
- [ ] Vários municípios do mesmo estado (via TCE)

### V2

- [ ] **Indicadores de atenção** (não acusações): fornecedor que também foi doador de campanha, sócio de fornecedor com mesmo sobrenome de agente, diárias acima da mediana, contrato emergencial recorrente
- [ ] Busca em diários oficiais (Querido Diário): nomeações, reajustes de subsídio
- [ ] Atalho "Quer denunciar?" com links para Ouvidoria, TCE e Ministério Público
- [ ] Gerador de pedido de LAI pré-preenchido

---

## 4. Arquitetura

```
                ┌─────────────────────────────────────────┐
                │   Coleta (ETL) — Python                 │
                │  coletores por fonte: TSE, SICONFI,     │
                │  PNCP, TCE, scrapers de portal          │
                └───────────┬─────────────────────────────┘
                            │ 1. baixa bruto → Object Storage (S3/MinIO)
                            │ 2. normaliza → PostgreSQL
                            ▼
┌──────────────┐    ┌───────────────┐    ┌──────────────────┐
│ Object       │    │ PostgreSQL    │◄───│ API (REST)       │
│ Storage      │    │ + pg_trgm     │    │ Node/TS ou       │
│ (arquivos    │    │ (busca)       │    │ Laravel          │
│ brutos)      │    └───────────────┘    └────────┬─────────┘
└──────────────┘                                  │  + Redis (cache)
                                   ┌──────────────┴──────────────┐
                                   ▼                             ▼
                          ┌─────────────────┐          ┌──────────────────┐
                          │ Web — Next.js   │          │ Mobile — Expo    │
                          │ (React, SSR/SEO)│          │ (React Native)   │
                          └─────────────────┘          └──────────────────┘
```

### Decisões de stack (recomendação)

| Camada | Recomendação | Por quê |
|---|---|---|
| **Coleta / ETL** | **Python** (httpx, pandas/polars, Playwright para portais com JS, Pydantic) | Ecossistema de dados e scraping imbatível |
| **Orquestração** | Início: GitHub Actions cron. Depois: Prefect ou Dagster | Começar simples, sem servidor extra |
| **API** | **Node.js + TypeScript (Fastify ou NestJS)** | Compartilha tipos/schemas (Zod) com web e mobile no mesmo monorepo |
| | *Alternativa:* **Laravel** | Se a equipe for mais produtiva em PHP; Eloquent + API Resources resolvem bem. Perde o compartilhamento de tipos |
| **Banco** | PostgreSQL 16 (+ `pg_trgm` para busca por nome) | Relacional, séries temporais simples, JSONB para dado bruto |
| **Cache** | Redis | Dados mudam no máximo diariamente → cache agressivo |
| **Web** | **Next.js (React)** | SSR = páginas de político indexáveis no Google e com preview bonito no WhatsApp |
| **Mobile** | **React Native com Expo** (Expo Router, EAS Build) | Build iOS/Android sem Mac local, OTA updates, push via Expo Notifications |
| **Compartilhado** | TanStack Query, Zod, design tokens; UI com NativeWind ou Tamagui | Reaproveitar lógica e estilo entre web e mobile |
| **Gráficos** | Recharts (web) / Victory Native (mobile) | |
| **Infra** | Web na Vercel; API + workers em Railway/Fly.io/Render; Postgres gerenciado (Neon/Supabase) | Custo baixo no começo |
| **Observabilidade** | Sentry (web, mobile e API) + log de cada execução de coleta | |

### Estrutura do monorepo (pnpm + Turborepo)

```
fiscalizapp/
├── apps/
│   ├── web/              # Next.js
│   ├── mobile/           # Expo / React Native
│   └── api/              # Fastify/NestJS (ou Laravel em /api-laravel)
├── packages/
│   ├── types/            # schemas Zod + tipos TS compartilhados
│   ├── api-client/       # cliente HTTP + hooks TanStack Query
│   ├── ui/               # componentes e design tokens
│   └── config/           # eslint, tsconfig, prettier
├── etl/                  # Python (uv/poetry)
│   ├── coletores/        # tse/, siconfi/, pncp/, tce_xx/, portais/<fornecedor>/
│   ├── normalizacao/
│   └── tests/            # fixtures com HTML/CSV reais salvos
├── infra/                # docker-compose (postgres, redis, minio)
└── docs/
```

---

## 5. Modelo de dados (inicial)

```
municipio(id, codigo_ibge, nome, uf, populacao)
orgao(id, municipio_id, tipo[prefeitura|camara], nome, cnpj)

pessoa(id, nome, nome_urna, foto_url, cpf_hash)        -- nunca CPF em claro
mandato(id, pessoa_id, orgao_id, cargo, partido, inicio, fim)

remuneracao(id, mandato_id, competencia[AAAA-MM], bruto, liquido,
            descontos, verbas_jsonb, fonte_id)
beneficio(id, mandato_id, tipo[diaria|verba_indenizatoria|auxilio|...],
          data, valor, descricao, destino, fonte_id)

despesa(id, orgao_id, data, fase[empenho|liquidacao|pagamento],
        funcao, elemento, valor, fornecedor_id, historico, fonte_id)
fornecedor(id, cnpj_cpf, nome)
contrato(id, orgao_id, fornecedor_id, objeto, valor, inicio, fim,
         modalidade, fonte_id)

bem_declarado(id, pessoa_id, eleicao_ano, tipo, descricao, valor, fonte_id)
doacao_campanha(id, pessoa_id, eleicao_ano, doador_nome, doador_doc,
                valor, fonte_id)

fonte(id, nome, url, coletado_em, hash_sha256, arquivo_bruto_path)
execucao_coleta(id, coletor, inicio, fim, status, registros, erro)
```

Pontos de atenção:

- **Identidade de pessoa**: casar a mesma pessoa entre TSE, folha e TCE (nome varia). Usar CPF *hasheado* quando disponível + revisão manual.
- **Valores** em centavos (`bigint`) para evitar erro de ponto flutuante.
- **Idempotência**: recoletar um mês não pode duplicar registros (chave natural + upsert).

---

## 6. Requisitos não funcionais

- **Confiabilidade dos dados**: testes do ETL com fixtures reais; alerta quando um portal mudar de layout (coleta retorna 0 registros ou schema diferente).
- **Desempenho**: API cacheada; páginas públicas do web com ISR (revalidação diária).
- **Offline (mobile)**: cache persistido do TanStack Query para perfis já vistos.
- **Acessibilidade**: WCAG 2.1 AA; valores sempre também em texto, não só em gráfico.
- **Segurança**: API somente leitura para o público; rate limit; painel admin separado com autenticação.
- **Jurídico**: termos de uso, política de privacidade, canal de correção ("encontrou um erro?").

---

## 7. Roadmap

| Fase | Duração estimada | Entregas |
|---|---|---|
| **0 — Descoberta** | 1–2 semanas | Escolher município piloto; inventário das fontes dele (o que tem API, o que precisa de scraping, o que não existe); protótipo das telas (Figma); decisão final Node × Laravel |
| **1 — Fundação** | 2 semanas | Monorepo, docker-compose, schema do banco, CI (lint/test), deploy de staging |
| **2 — ETL do piloto** | 3–4 semanas | Coletores TSE (eleitos, bens, doações), SICONFI, folha da Câmara e Prefeitura, diárias; tabela `fonte` funcionando |
| **3 — API + Web MVP** | 3 semanas | Endpoints de município, políticos, remuneração, benefícios, despesas; Next.js com perfil, painel e busca |
| **4 — Mobile MVP** | 3 semanas | App Expo com as mesmas telas; publicação em teste fechado (TestFlight / Play Console interno) |
| **5 — Lançamento piloto** | 1–2 semanas | Revisão dos dados com 2–3 pessoas externas, página de metodologia, divulgação local, coleta de feedback |
| **6 — V1** | contínuo | Push, comparativos, contratos, expansão para outros municípios do mesmo TCE |

Total até o MVP público: **~3 a 4 meses** com 1–2 desenvolvedores.

### Telas do MVP

1. **Início** — município selecionado, destaque "Quanto custa a Câmara por mês", atalhos.
2. **Lista de políticos** — filtros por cargo e partido.
3. **Perfil do político** — abas: Salário · Benefícios · Patrimônio · Campanha.
4. **Painel de gastos** — por categoria, por mês, maiores fornecedores.
5. **Busca**.
6. **Sobre os dados** — fontes, data de atualização, metodologia.

---

## 8. Riscos e mitigação

| Risco | Mitigação |
|---|---|
| Portal municipal sem dados ou fora do ar | Começar por fontes nacionais (TSE, SICONFI, PNCP); pedido via LAI; exibir "dado não publicado pelo município" (isso também é informação) |
| Portal muda o layout e quebra o scraper | Testes com fixtures, monitoramento de volume por coleta, scrapers por fornecedor de sistema |
| Erro de interpretação (ex.: confundir bruto com líquido) | Glossário, revisão manual dos primeiros meses, botão "reportar erro" |
| Risco jurídico (difamação, LGPD) | Só dados oficiais, sempre com fonte, linguagem neutra, sem CPF/dados sensíveis, termos de uso revisados por advogado |
| Homônimos / pessoa errada | Matching por CPF hasheado + revisão manual antes de publicar |
| Custo de infraestrutura | Dados mudam pouco → cache forte, tiers gratuitos no início |

---

## 9. Métricas de sucesso

- % dos agentes políticos do piloto com remuneração dos últimos 12 meses carregada (meta: 100%)
- Atraso médio entre publicação no portal oficial e no FiscalizApp (meta: < 7 dias)
- Usuários ativos mensais e compartilhamentos de cards
- Nº de erros reportados e tempo de correção

---

## 10. Decisões em aberto

1. **Qual é o município piloto?** (define quais fontes estaduais/municipais usar)
2. **API em Node/TypeScript ou Laravel?** (recomendação: Node/TS pelo compartilhamento de tipos com o front)
3. Modelo de sustentação: projeto open source sem fins lucrativos, parceria com observatório social, doações?
4. Haverá painel administrativo para curadoria manual dos dados no MVP?
