# FiscalizApp — A Ideia

> Documento vivo. Registra a concepção do produto, o município piloto, os dados
> já levantados e as decisões tomadas. Complementa o
> [PLANEJAMENTO.md](PLANEJAMENTO.md).

---

## 1. Em uma frase

**"Saiba quanto custa, de verdade, quem você elegeu."**

O FiscalizApp junta em um só lugar — app e site — os salários, benefícios e
gastos dos políticos do seu município, usando apenas dados públicos oficiais e
sempre mostrando de onde cada número veio.

## 2. Por que existe

- O cidadão vê posts em redes sociais com salários de vereadores (como o que
  motivou este projeto), mas **não sabe se o número está certo, de quando é ou
  o que está incluído**.
- Os dados oficiais existem, mas estão espalhados entre portal da Câmara,
  portal da Prefeitura, Tribunal de Contas, TSE e Diário Oficial.
- Quem quer fiscalizar precisa saber termos como *empenho*, *subsídio* e
  *verba de representação*.

O FiscalizApp transforma isso em respostas simples:

- Quanto ganha cada vereador e o prefeito?
- Quanto a Câmara custa por mês e por habitante?
- Quem recebeu diárias, para onde e quanto?
- O patrimônio declarado cresceu entre uma eleição e outra?
- Quem financiou a campanha? Essa pessoa ou empresa tem contrato com a prefeitura?
- Os gastos respeitam os limites da Constituição?

## 3. Município piloto: Campo Largo – PR

| Item | Valor | Status |
|---|---|---|
| Município | Campo Largo | ✅ |
| UF | Paraná | ✅ |
| Região | Região Metropolitana de Curitiba | ✅ |
| Código IBGE | 4104204 | ⚠️ confirmar na API do IBGE |
| População | ~136 mil (Censo 2022) | ⚠️ confirmar no IBGE |
| Tribunal de Contas | TCE-PR | ✅ |
| Legislatura atual | 2025–2028 (eleição de 2024) | ✅ |
| Nº de cadeiras na Câmara | 15 | ⚠️ confirmar na Câmara |

### 3.1 Vereadores — legislatura 2025–2028 (dados iniciais)

> **Fonte:** captura de tela de um post em rede social enviada pelo
> idealizador. **Não é fonte oficial.** Serve como **dado semente** para
> desenvolvimento e testes. Antes de publicar no app, cada linha precisa ser
> confirmada no TSE (eleitos), no portal da Câmara (mesa diretora) e na folha
> de pagamento oficial.

| # | Vereador(a) | Partido | Cargo | Subsídio informado (R$) | Verificado |
|---|---|---|---|---:|:---:|
| 01 | Alexandre Guimarães | PDT | Presidente | 15.859,18 | ☐ |
| 02 | André Gabardo | NOVO | Vereador | 11.859,18 | ☐ |
| 03 | Athos Martinez | PL | Vereador | 11.859,18 | ☐ |
| 04 | Genésio da Vital | MDB | Vereador | 11.859,18 | ☐ |
| 05 | Gustavo Torres | REPUBLICANOS | Vereador | 11.859,18 | ☐ |
| 06 | Júnior Andreassa | PODE | Vereador | 11.859,18 | ☐ |
| 07 | Luiz Scervenski | MDB | Vereador | 11.859,18 | ☐ |
| 08 | Polaco Preto | PSD | Vereador | 11.859,18 | ☐ |
| 09 | Rafael Freitas | UNIÃO | Vereador | 11.859,18 | ☐ |
| 10 | Rogério das Tintas | PL | Vereador | 11.859,18 | ☐ |
| 11 | Rogério da Viação | PSD | Vereador | 11.859,18 | ☐ |
| 12 | Sargento Leandro Chrestani | SDD | Vereador | 11.859,18 | ☐ |
| 13 | Sensei Clóvis | PP | Vereador | 11.859,18 | ☐ |
| 14 | Tomazina | PDT | Vereador | 11.859,18 | ☐ |
| 15 | Victor Bini | UNIÃO | Vereador | 11.859,18 | ☐ |

Observações:

- Os nomes são **nomes de urna/apelidos**. O nome civil virá do TSE, e é ele
  que liga a pessoa à folha de pagamento e à declaração de bens.
- O presidente aparece com **R$ 4.000,00 a mais**. A hipótese é uma
  *verba de representação* da presidência. Para confirmar, é preciso achar a
  lei ou resolução que fixa os subsídios da legislatura 2025–2028.
- Os valores informados não dizem se são **bruto ou líquido**, nem **de qual mês**.
  O app vai sempre mostrar os dois e a competência (mês/ano).

### 3.2 Primeira conta: quanto custam os subsídios

Com os valores informados, **sem verificação** e **sem** encargos, 13º,
diárias, assessores ou estrutura de gabinete:

| Item | Cálculo | Valor (R$) |
|---|---|---:|
| Subsídio do presidente | 1 × 15.859,18 | 15.859,18 |
| Subsídios dos demais | 14 × 11.859,18 | 166.028,52 |
| **Total mensal** | | **181.887,70** |
| Total em 12 meses | × 12 | 2.182.652,40 |
| Por habitante/mês (~136 mil hab.) | ÷ 136.000 | ≈ 1,34 |

Esse é o tipo de card que o app vai gerar, com a diferença de que a versão
real usa a folha oficial e mostra a fonte embaixo.

> O custo total da Câmara (servidores, comissionados, contratos, estrutura) é
> bem maior que só os subsídios. Ele virá do SIM-AM/TCE-PR e do SICONFI.

### 3.3 Fontes a investigar para Campo Largo (Fase 0)

| Fonte | O que buscar | Status |
|---|---|---|
| **TSE – Dados Abertos (Eleições 2024)** | Eleitos em Campo Largo: nome civil, nome de urna, partido, número, foto, **bens declarados**, **receitas de campanha** | ☐ |
| **Portal da Transparência da Câmara de Campo Largo** | Folha nominal (subsídios), diárias, verbas, contratos. Identificar o **fornecedor do sistema** do portal (define o tipo de coletor) | ☐ |
| **Portal da Transparência da Prefeitura de Campo Largo** | Folha do prefeito, vice e secretários; diárias; despesas | ☐ |
| **TCE-PR – Portal de Dados Abertos / PIT** | Dados que os municípios do PR enviam ao TCE pelo **SIM-AM** (despesas, empenhos, licitações, contratos). Avaliar se tem folha de pessoal | ☐ |
| **Lei/Resolução de fixação dos subsídios 2025–2028** | Valor oficial do subsídio e da verba de representação do presidente | ☐ |
| **Diário Oficial do Município** | Nomeações, reajustes, leis. Verificar se Campo Largo está no **Querido Diário** | ☐ |
| **SICONFI (Tesouro)** | RREO/RGF de Campo Largo: despesa com pessoal, receita corrente líquida | ☐ |
| **PNCP** | Contratos e licitações da Prefeitura e da Câmara | ☐ |
| **IBGE** | Código e população oficiais | ☐ |
| **Observatório Social de Campo Largo** | Possível parceiro: valida dados e divulga o app | ☐ |

Se algo não for encontrado, preparar um **pedido via LAI (e-SIC)**. O próprio
"dado não publicado" vira informação no app.

## 4. Verificações automáticas: o diferencial

Além de mostrar números, o app compara os gastos com os **limites da
Constituição Federal**. Os textos são neutros ("dentro do limite" / "acima do
limite"), sempre com o cálculo aberto.

| Regra | Base legal | Como calcular |
|---|---|---|
| Subsídio máximo do vereador | CF, art. 29, VI | Para municípios de 100.001 a 300.000 hab.: até **50% do subsídio do deputado estadual** |
| Total pago a vereadores | CF, art. 29, VII | Soma dos subsídios ≤ **5% da receita do município** |
| Gasto total da Câmara | CF, art. 29-A, I a VI | Faixa de 100.001 a 300.000 hab.: até **6%** da receita tributária + transferências do ano anterior |
| Folha da Câmara | CF, art. 29-A, §1º | Folha ≤ **70% do repasse** à Câmara |
| Nº máximo de vereadores | CF, art. 29, IV | Faixa de 120.001 a 160.000 hab.: até **19** vereadores |
| Despesa com pessoal (Prefeitura) | LRF, art. 20, III | Executivo ≤ 54% da RCL; Legislativo ≤ 6% da RCL |
| Subsídio fixado na legislatura anterior | CF, art. 29, VI | Reajuste no meio do mandato é um alerta |

> Os percentuais e faixas acima precisam ser revisados contra o texto vigente
> da Constituição antes de entrarem no código. Eles ficam **em configuração**
> (tabela no banco), não fixos no código, porque mudam com emendas e com a
> população.

## 5. Para quem é

| Persona | Exemplo em Campo Largo | O que quer no app |
|---|---|---|
| **Cidadã comum** | Moradora que viu o post do Instagram | "Isso é verdade? Quanto ganha meu vereador?" |
| **Jornalista local** | Portal de notícias da cidade | Série histórica, CSV, comparar com Araucária e São José dos Pinhais |
| **Observatório Social** | Voluntários que fiscalizam a Câmara | Diárias, contratos, cruzamentos |
| **O próprio vereador** | Mandato que quer mostrar transparência | Link do perfil para compartilhar |

## 6. Experiência do usuário

### Jornada principal

```
Abre o app ──► Campo Largo já selecionado
            ──► "A Câmara custa R$ X por mês (R$ Y por habitante)"
            ──► Lista dos 15 vereadores (foto, partido, subsídio)
            ──► Toca em um vereador
                 ├─ Salário: gráfico mês a mês, bruto × líquido
                 ├─ Benefícios: diárias (destino, motivo, valor), verbas
                 ├─ Patrimônio: bens 2020 × 2024 (TSE)
                 ├─ Campanha: quem doou e quanto
                 └─ Fonte de cada dado + "Encontrou um erro?"
            ──► Compartilhar card no WhatsApp
```

### Telas do MVP

1. **Início:** resumo do município e cards de destaque.
2. **Vereadores:** lista com filtro por partido; o mesmo para Prefeito/Vice/Secretários.
3. **Perfil:** abas Salário · Benefícios · Patrimônio · Campanha.
4. **Gastos:** Câmara e Prefeitura por categoria e por mês.
5. **Limites legais:** verificações da seção 4.
6. **Busca.**
7. **Sobre os dados:** fontes, última atualização, metodologia, glossário.

### Tom de voz

- Informar, nunca acusar: "recebeu R$ 3.200 em diárias em março", e não
  "gastou demais".
- Toda frase com número tem fonte e data.
- Termos técnicos com explicação ao tocar (glossário).

## 7. Decisões tomadas

| Data | Decisão | Motivo |
|---|---|---|
| 2026-10-27 | **Município piloto: Campo Largo – PR** | Município do idealizador; porte médio (~136 mil hab.); TCE-PR tem dados abertos |
| 2026-10-27 | **Backend em Node.js + TypeScript** | Mesma linguagem do web (React) e do mobile (React Native); tipos compartilhados |
| 2026-10-27 | **Coleta de dados (ETL) também em Node/TS** | Projeto com uma linguagem só. Playwright, cheerio e csv-parse cobrem scraping e CSV. Python fica como opção para análises pesadas no futuro |
| 2026-10-27 | Dado de rede social é **semente**, não fonte | Credibilidade: só publicar dado com fonte oficial |

### Stack proposta (Node)

| Camada | Escolha | Observação |
|---|---|---|
| API | **NestJS** (TypeScript) | Estrutura parecida com Laravel (módulos, controllers, services, injeção de dependência), o que facilita para quem vem do PHP |
| ORM / migrations | **Prisma** | Migrations e seeds parecidos com Eloquent/Artisan |
| Banco | PostgreSQL 16 + `pg_trgm` | Busca por nome tolerante a acentos e apelidos |
| Filas e agendamento | **BullMQ** + Redis | Jobs de coleta agendados (equivalente ao Scheduler + Queues do Laravel) |
| Coletores | Node/TS: `undici`/`fetch`, `cheerio`, **Playwright**, `csv-parse`, **Zod** | Zod valida cada registro coletado antes de gravar |
| Arquivos brutos | S3 / MinIO | Cópia de cada CSV/HTML/PDF coletado, com hash |
| Web | **Next.js** (React) | SEO e preview no WhatsApp |
| Mobile | **Expo** (React Native) | Build iOS/Android na nuvem (EAS) |
| Monorepo | pnpm + Turborepo | `packages/types` com schemas Zod usados por API, web e mobile |
| Testes | Vitest + Supertest; fixtures reais dos portais | |

## 8. Glossário inicial

| Termo | Explicação simples |
|---|---|
| **Subsídio** | O "salário" de um agente político (vereador, prefeito). É fixado em parcela única por lei |
| **Verba de representação** | Valor extra pago a quem ocupa uma função, como a presidência da Câmara |
| **Diária** | Valor pago para cobrir hospedagem e alimentação em viagem a serviço |
| **Verba indenizatória** | Reembolso de despesas do mandato (combustível, escritório...), quando existe |
| **Empenho** | Reserva do dinheiro para um gasto. É o primeiro passo da despesa |
| **Liquidação** | Confirmação de que o serviço foi prestado ou o produto entregue |
| **Pagamento** | Saída efetiva do dinheiro |
| **RCL** | Receita Corrente Líquida: base para os limites da LRF |
| **SIM-AM** | Sistema pelo qual os municípios do Paraná enviam suas contas ao TCE-PR |
| **LAI** | Lei de Acesso à Informação (12.527/2011): qualquer cidadão pode pedir dados públicos |

## 9. Próximos passos de planejamento

1. [ ] **Fase 0 / fontes:** preencher a tabela 3.3 com URL, formato e
       periodicidade de cada fonte de Campo Largo.
2. [ ] **Validar os 15 vereadores** no TSE e atualizar a tabela 3.1.
3. [ ] Achar a **lei de fixação dos subsídios 2025–2028**.
4. [ ] Definir os **endpoints da API** (contrato OpenAPI) a partir das telas.
5. [ ] Detalhar o **schema Prisma** a partir do modelo de dados do PLANEJAMENTO.
6. [ ] Wireframes das 7 telas.
7. [ ] Escrever os **termos de uso** e a **política de privacidade** (LGPD).
8. [ ] Conversar com o **Observatório Social de Campo Largo** sobre parceria.
