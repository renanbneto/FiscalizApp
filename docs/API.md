# FiscalizApp — API (v1)

API REST em **NestJS** consumida pelo web (Next.js) e pelo mobile (Expo).
O contrato é gerado em **OpenAPI** (`/v1/docs`). Os schemas **Zod** ficam em
`packages/types`, compartilhados entre API, web e mobile.

Modelo de dados: [MODELO-DE-DADOS.md](MODELO-DE-DADOS.md).

---

## 1. Convenções

| Tema | Regra |
|---|---|
| Base | `https://api.fiscalizapp.com.br/v1` (domínio a definir) |
| Acesso público | Somente leitura (`GET`), sem login. A única exceção é `POST /v1/reportes` |
| Identificadores | Município pelo **código IBGE** (`4104204`); agente pelo **slug** (`alexandre-guimaraes`); órgão por `prefeitura` ou `camara` dentro do município |
| Dinheiro | Inteiro em **centavos**: `"brutoCentavos": 1585918` |
| Datas | ISO 8601 (`2025-03-01`); competência como `"2025-03"` |
| Paginação | `?pagina=1&porPagina=20` (máx. 100); resposta em `meta.paginacao` |
| Ordenação | `?ordenar=campo` / `?ordenar=-campo` (desc) |
| Exportação | Listas aceitam `?formato=csv` (ou `Accept: text/csv`) |
| Erros | `application/problem+json` (RFC 9457) |
| Cache | `Cache-Control: public, max-age=3600, stale-while-revalidate=86400` + `ETag`. Os dados mudam no máximo diariamente |
| Limite | 120 req/min por IP; 5 req/hora no `POST /reportes` |
| Verificação | Por padrão só registros `VERIFICADO` e `DIVERGENTE`. Em ambiente de desenvolvimento, `?incluirNaoVerificados=true` libera a semente |

### Envelope de resposta

Todo dado vem acompanhado de **fonte** e **data de atualização**. Esse é o
princípio central do produto.

```json
{
  "data": { },
  "meta": {
    "atualizadoEm": "2026-10-20T03:00:00-03:00",
    "fontes": [
      {
        "id": 812,
        "nome": "Portal da Transparência – Câmara de Campo Largo (Atende.Net)",
        "url": "https://camaracampolargo.atende.net/transparencia/",
        "coletadoEm": "2026-10-20T03:00:00-03:00"
      }
    ],
    "paginacao": { "pagina": 1, "porPagina": 20, "total": 15 }
  }
}
```

---

## 2. Endpoints públicos

### Municípios

| Método | Rota | Tela | Descrição |
|---|---|---|---|
| GET | `/municipios` | Seleção de município | Municípios ativos (`ativo = true`) |
| GET | `/municipios/:ibge` | — | Dados do município e seus órgãos |
| GET | `/municipios/:ibge/resumo` | **Início** | Custo mensal da Câmara, total de subsídios, custo por habitante, destaques |
| GET | `/municipios/:ibge/limites?ano=2025` | **Limites legais** | Resultado de cada regra (CF art. 29, 29-A, LRF) com memória de cálculo |

### Agentes políticos

| Método | Rota | Tela | Descrição |
|---|---|---|---|
| GET | `/municipios/:ibge/agentes` | **Vereadores / Executivo** | Filtros: `orgao=camara\|prefeitura`, `cargo`, `partido`, `legislatura`, `q` |
| GET | `/agentes/:slug` | **Perfil** (cabeçalho) | Pessoa, mandato atual, partido, função na mesa e último subsídio |
| GET | `/agentes/:slug/remuneracoes` | Perfil › **Salário** | Série mensal. Filtros: `de=2025-01`, `ate=2025-12`, `tipoFolha`. Inclui rubricas |
| GET | `/agentes/:slug/diarias` | Perfil › **Benefícios** | Diárias com destino, motivo e valor. Filtros: `ano`, `de`, `ate` |
| GET | `/agentes/:slug/patrimonio` | Perfil › **Patrimônio** | Bens por eleição e variação entre eleições |
| GET | `/agentes/:slug/campanha` | Perfil › **Campanha** | Receitas da campanha agrupadas por doador e origem |

### Gastos dos órgãos

| Método | Rota | Tela | Descrição |
|---|---|---|---|
| GET | `/municipios/:ibge/orgaos/:orgao/despesas` | **Gastos** (lista) | Filtros: `ano`, `mes`, `fase`, `elemento`, `fornecedor`, `q` |
| GET | `/municipios/:ibge/orgaos/:orgao/despesas/agregado` | **Gastos** (gráficos) | `?ano=2025&por=elemento\|mes\|fornecedor\|funcao` |
| GET | `/municipios/:ibge/orgaos/:orgao/diarias` | Gastos › Diárias | Todas as diárias do órgão, incluindo servidores |
| GET | `/municipios/:ibge/orgaos/:orgao/contratos` | Gastos › Contratos (V1) | Filtros: `vigentes=true`, `fornecedor`, `q` |
| GET | `/fornecedores/:documento` | Fornecedor (V1) | Total recebido por órgão e ano; contratos |

### Apoio

| Método | Rota | Descrição |
|---|---|---|
| GET | `/busca?q=rogerio&municipio=4104204` | Busca unificada: agentes, fornecedores. Tolera acento e apelido (`pg_trgm` + `unaccent`) |
| GET | `/fontes/:id` | Proveniência completa: URL, data, hash, link para o arquivo bruto |
| GET | `/glossario` | Termos (subsídio, empenho, diária...) |
| GET | `/status` | Última coleta de cada coletor (página "Sobre os dados") |
| POST | `/reportes` | "Encontrou um erro?" `{ entidade, entidadeId, pagina, mensagem, contato? }` + captcha (Turnstile) |

---

## 3. Exemplos

### `GET /v1/municipios/4104204/resumo`

```json
{
  "data": {
    "municipio": { "codigoIbge": "4104204", "nome": "Campo Largo", "uf": "PR", "populacao": 136000 },
    "competencia": "2025-09",
    "camara": {
      "vereadores": 15,
      "subsidiosMensaisCentavos": 18188770,
      "subsidiosPorHabitanteCentavos": 134,
      "despesaTotalMesCentavos": null,
      "despesaTotalAnoCentavos": null
    },
    "destaques": [
      { "tipo": "MAIOR_DIARIA_MES", "agenteSlug": "…", "valorCentavos": 0 }
    ]
  },
  "meta": { "atualizadoEm": "…", "fontes": ["…"] }
}
```

> Os números acima vêm da semente (post de rede social) e servem só para
> desenvolvimento.

### `GET /v1/municipios/4104204/agentes?orgao=camara`

```json
{
  "data": [
    {
      "slug": "alexandre-guimaraes",
      "nomeUrna": "Alexandre Guimarães",
      "nomeCivil": null,
      "fotoUrl": null,
      "partido": "PDT",
      "cargo": "VEREADOR",
      "funcaoMesa": "PRESIDENTE",
      "ultimoSubsidio": { "competencia": "2025-09", "brutoCentavos": 1585918, "liquidoCentavos": null },
      "verificacao": "NAO_VERIFICADO"
    }
  ],
  "meta": { "paginacao": { "pagina": 1, "porPagina": 20, "total": 15 } }
}
```

### `GET /v1/agentes/alexandre-guimaraes/remuneracoes?de=2025-01&ate=2025-03`

```json
{
  "data": {
    "agente": { "slug": "alexandre-guimaraes", "nomeUrna": "Alexandre Guimarães" },
    "serie": [
      {
        "competencia": "2025-01",
        "tipoFolha": "MENSAL",
        "brutoCentavos": 1585918,
        "descontosCentavos": 0,
        "liquidoCentavos": null,
        "itens": [
          { "rubrica": "Subsídio", "natureza": "PROVENTO", "valorCentavos": 1185918 },
          { "rubrica": "Verba de representação (Presidência)", "natureza": "PROVENTO", "valorCentavos": 400000 }
        ],
        "fonteId": 1
      }
    ],
    "totais": { "brutoCentavos": 1585918, "meses": 1 }
  },
  "meta": { "fontes": ["…"] }
}
```

> As rubricas do exemplo são **hipótese**. Vão ser confirmadas na folha do
> Atende.Net.

### `GET /v1/municipios/4104204/limites?ano=2025`

```json
{
  "data": [
    {
      "regra": {
        "codigo": "CF_29_VI_SUBSIDIO_VEREADOR",
        "titulo": "Subsídio máximo do vereador",
        "baseLegal": "Constituição Federal, art. 29, VI",
        "explicacao": "Em cidades de 100.001 a 300.000 habitantes, o vereador pode ganhar no máximo 50% do salário de um deputado estadual."
      },
      "situacao": "DENTRO",
      "valorApuradoCentavos": 1185918,
      "limiteCentavos": null,
      "percentualApurado": null,
      "memoriaCalculo": [
        "População: 136.000 → faixa 100.001–300.000 → 50%",
        "Subsídio de deputado estadual (PR): a coletar",
        "Limite = 50% × subsídio do deputado estadual"
      ]
    }
  ]
}
```

### Erro (`problem+json`)

```json
{
  "type": "https://fiscalizapp.com.br/erros/nao-encontrado",
  "title": "Agente não encontrado",
  "status": 404,
  "detail": "Nenhum agente com slug 'fulano' em Campo Largo – PR."
}
```

---

## 4. Endpoints administrativos

Prefixo `/admin`. Login com e-mail + senha e 2FA, papel `CURADOR` ou `ADMIN`.
Fica fora do OpenAPI público.

| Método | Rota | Descrição |
|---|---|---|
| GET | `/admin/execucoes` | Histórico das coletas, com destaque para `FALHA` e `SUCESSO_SEM_REGISTROS` |
| POST | `/admin/coletas/:coletor` | Dispara um coletor sob demanda. Ex.: `atende-net:remuneracao`, `{ "orgao": "camara", "ano": 2025, "mes": 9 }` |
| GET | `/admin/pendencias` | Registros `NAO_VERIFICADO` e `DIVERGENTE` para curadoria |
| PATCH | `/admin/:entidade/:id/verificacao` | Marca como `VERIFICADO` / `DIVERGENTE`, com fonte e observação |
| POST | `/admin/pessoas/:id/mesclar` | Une duas pessoas duplicadas (TSE × folha) |
| GET | `/admin/reportes` · PATCH `/admin/reportes/:id` | Triagem do "Encontrou um erro?" |
| PUT | `/admin/regras-limite/:codigo` | Cria nova vigência de uma regra |

---

## 5. Organização no NestJS

```
apps/api/src/
├── main.ts
├── app.module.ts
├── common/            # envelope, problem+json, paginação, BigInt → number, cache
├── prisma/            # PrismaService
├── municipios/        # controller, service, dto (Zod)
├── agentes/
├── remuneracoes/
├── diarias/
├── despesas/
├── tse/               # patrimônio e campanha
├── limites/           # cálculo das regras + endpoint
├── busca/
├── fontes/
├── reportes/
└── admin/             # guarda de autenticação + rotas de curadoria
```

O cálculo de limites fica em um *service* puro, sem acesso ao banco, que recebe
os números e devolve situação e memória de cálculo. Assim ele é testável com
casos de tabela.

## 6. Próximos passos

- [ ] Criar `packages/types` com os schemas Zod das respostas acima
- [ ] Scaffold do NestJS com `PrismaService`, interceptor de envelope e filtro `problem+json`
- [ ] Implementar `/municipios/:ibge/agentes` e `/agentes/:slug` usando a semente
- [ ] Testes e2e (Vitest + Supertest) com banco Postgres em container
