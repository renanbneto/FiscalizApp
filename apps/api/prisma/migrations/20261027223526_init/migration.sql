-- Extensões para busca por nome tolerante a erros de digitação e acentos
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- CreateEnum
CREATE TYPE "TipoOrgao" AS ENUM ('PREFEITURA', 'CAMARA');

-- CreateEnum
CREATE TYPE "PlataformaPortal" AS ENUM ('ATENDE_NET', 'BETHA', 'ELOTECH', 'FIORILLI', 'OUTRA');

-- CreateEnum
CREATE TYPE "Cargo" AS ENUM ('PREFEITO', 'VICE_PREFEITO', 'SECRETARIO', 'VEREADOR');

-- CreateEnum
CREATE TYPE "SituacaoMandato" AS ENUM ('TITULAR', 'SUPLENTE_EM_EXERCICIO', 'LICENCIADO', 'AFASTADO', 'ENCERRADO');

-- CreateEnum
CREATE TYPE "FuncaoMesaDiretora" AS ENUM ('PRESIDENTE', 'VICE_PRESIDENTE', 'PRIMEIRO_SECRETARIO', 'SEGUNDO_SECRETARIO');

-- CreateEnum
CREATE TYPE "TipoFolha" AS ENUM ('MENSAL', 'DECIMO_TERCEIRO', 'FERIAS', 'COMPLEMENTAR', 'RESCISAO');

-- CreateEnum
CREATE TYPE "NaturezaRubrica" AS ENUM ('PROVENTO', 'DESCONTO');

-- CreateEnum
CREATE TYPE "FaseDespesa" AS ENUM ('EMPENHO', 'LIQUIDACAO', 'PAGAMENTO');

-- CreateEnum
CREATE TYPE "TipoPessoaFornecedor" AS ENUM ('FISICA', 'JURIDICA');

-- CreateEnum
CREATE TYPE "StatusVerificacao" AS ENUM ('NAO_VERIFICADO', 'VERIFICADO', 'DIVERGENTE');

-- CreateEnum
CREATE TYPE "TipoFonte" AS ENUM ('PORTAL_TRANSPARENCIA', 'TCE', 'TSE', 'SICONFI', 'PNCP', 'IBGE', 'DIARIO_OFICIAL', 'LEGISLACAO', 'PEDIDO_LAI', 'REDE_SOCIAL', 'MANUAL');

-- CreateEnum
CREATE TYPE "StatusExecucao" AS ENUM ('EM_ANDAMENTO', 'SUCESSO', 'SUCESSO_SEM_REGISTROS', 'FALHA');

-- CreateEnum
CREATE TYPE "SituacaoLimite" AS ENUM ('DENTRO', 'PROXIMO', 'ACIMA', 'SEM_DADOS');

-- CreateEnum
CREATE TYPE "StatusReporte" AS ENUM ('ABERTO', 'EM_ANALISE', 'CORRIGIDO', 'DESCARTADO');

-- CreateTable
CREATE TABLE "municipios" (
    "id" SERIAL NOT NULL,
    "codigoIbge" CHAR(7) NOT NULL,
    "nome" TEXT NOT NULL,
    "uf" CHAR(2) NOT NULL,
    "slug" TEXT NOT NULL,
    "populacao" INTEGER,
    "populacaoAno" INTEGER,
    "ativo" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "municipios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "orgaos" (
    "id" SERIAL NOT NULL,
    "municipioId" INTEGER NOT NULL,
    "tipo" "TipoOrgao" NOT NULL,
    "nome" TEXT NOT NULL,
    "cnpj" CHAR(14),
    "plataforma" "PlataformaPortal",
    "portalUrl" TEXT,
    "subdominio" TEXT,

    CONSTRAINT "orgaos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "partidos" (
    "id" SERIAL NOT NULL,
    "sigla" TEXT NOT NULL,
    "nome" TEXT,
    "numero" INTEGER,

    CONSTRAINT "partidos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pessoas" (
    "id" SERIAL NOT NULL,
    "slug" TEXT NOT NULL,
    "nomeCivil" TEXT,
    "nomeUrna" TEXT NOT NULL,
    "nomeBusca" TEXT NOT NULL,
    "cpfHash" TEXT,
    "tseSequenciais" TEXT[],
    "fotoUrl" TEXT,

    CONSTRAINT "pessoas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "mandatos" (
    "id" SERIAL NOT NULL,
    "pessoaId" INTEGER NOT NULL,
    "orgaoId" INTEGER NOT NULL,
    "partidoId" INTEGER,
    "cargo" "Cargo" NOT NULL,
    "descricaoCargo" TEXT,
    "legislatura" TEXT,
    "inicio" DATE NOT NULL,
    "fim" DATE,
    "situacao" "SituacaoMandato" NOT NULL DEFAULT 'TITULAR',
    "verificacao" "StatusVerificacao" NOT NULL DEFAULT 'NAO_VERIFICADO',
    "fonteId" INTEGER,

    CONSTRAINT "mandatos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "funcoes_mesa" (
    "id" SERIAL NOT NULL,
    "mandatoId" INTEGER NOT NULL,
    "funcao" "FuncaoMesaDiretora" NOT NULL,
    "inicio" DATE NOT NULL,
    "fim" DATE,
    "fonteId" INTEGER,

    CONSTRAINT "funcoes_mesa_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "remuneracoes" (
    "id" SERIAL NOT NULL,
    "orgaoId" INTEGER NOT NULL,
    "mandatoId" INTEGER NOT NULL,
    "ano" INTEGER NOT NULL,
    "mes" INTEGER NOT NULL,
    "tipoFolha" "TipoFolha" NOT NULL DEFAULT 'MENSAL',
    "brutoCentavos" BIGINT NOT NULL,
    "descontosCentavos" BIGINT NOT NULL DEFAULT 0,
    "liquidoCentavos" BIGINT,
    "verificacao" "StatusVerificacao" NOT NULL DEFAULT 'NAO_VERIFICADO',
    "fonteId" INTEGER NOT NULL,
    "chaveOrigem" TEXT,

    CONSTRAINT "remuneracoes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "remuneracao_itens" (
    "id" SERIAL NOT NULL,
    "remuneracaoId" INTEGER NOT NULL,
    "codigo" TEXT,
    "rubrica" TEXT NOT NULL,
    "natureza" "NaturezaRubrica" NOT NULL,
    "valorCentavos" BIGINT NOT NULL,

    CONSTRAINT "remuneracao_itens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "diarias" (
    "id" SERIAL NOT NULL,
    "orgaoId" INTEGER NOT NULL,
    "mandatoId" INTEGER,
    "beneficiarioNome" TEXT NOT NULL,
    "dataInicio" DATE NOT NULL,
    "dataFim" DATE,
    "destino" TEXT,
    "motivo" TEXT,
    "quantidade" DECIMAL(6,2),
    "valorCentavos" BIGINT NOT NULL,
    "numeroEmpenho" TEXT,
    "verificacao" "StatusVerificacao" NOT NULL DEFAULT 'VERIFICADO',
    "fonteId" INTEGER NOT NULL,
    "chaveOrigem" TEXT NOT NULL,

    CONSTRAINT "diarias_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fornecedores" (
    "id" SERIAL NOT NULL,
    "documento" TEXT NOT NULL,
    "tipo" "TipoPessoaFornecedor" NOT NULL,
    "nome" TEXT NOT NULL,
    "nomeBusca" TEXT NOT NULL,

    CONSTRAINT "fornecedores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "despesas" (
    "id" SERIAL NOT NULL,
    "orgaoId" INTEGER NOT NULL,
    "ano" INTEGER NOT NULL,
    "numeroEmpenho" TEXT NOT NULL,
    "fase" "FaseDespesa" NOT NULL,
    "data" DATE NOT NULL,
    "funcao" TEXT,
    "subfuncao" TEXT,
    "elemento" TEXT,
    "fornecedorId" INTEGER,
    "historico" TEXT,
    "valorCentavos" BIGINT NOT NULL,
    "fonteId" INTEGER NOT NULL,
    "chaveOrigem" TEXT NOT NULL,

    CONSTRAINT "despesas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contratos" (
    "id" SERIAL NOT NULL,
    "orgaoId" INTEGER NOT NULL,
    "fornecedorId" INTEGER NOT NULL,
    "numero" TEXT NOT NULL,
    "objeto" TEXT NOT NULL,
    "modalidade" TEXT,
    "valorCentavos" BIGINT NOT NULL,
    "inicio" DATE,
    "fim" DATE,
    "fonteId" INTEGER NOT NULL,
    "chaveOrigem" TEXT NOT NULL,

    CONSTRAINT "contratos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bens_declarados" (
    "id" SERIAL NOT NULL,
    "pessoaId" INTEGER NOT NULL,
    "eleicaoAno" INTEGER NOT NULL,
    "tipo" TEXT NOT NULL,
    "descricao" TEXT,
    "valorCentavos" BIGINT NOT NULL,
    "fonteId" INTEGER NOT NULL,
    "chaveOrigem" TEXT NOT NULL,

    CONSTRAINT "bens_declarados_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receitas_campanha" (
    "id" SERIAL NOT NULL,
    "pessoaId" INTEGER NOT NULL,
    "eleicaoAno" INTEGER NOT NULL,
    "doadorNome" TEXT NOT NULL,
    "doadorDocumento" TEXT,
    "origem" TEXT,
    "data" DATE,
    "valorCentavos" BIGINT NOT NULL,
    "fonteId" INTEGER NOT NULL,
    "chaveOrigem" TEXT NOT NULL,

    CONSTRAINT "receitas_campanha_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "financas_municipais" (
    "id" SERIAL NOT NULL,
    "municipioId" INTEGER NOT NULL,
    "ano" INTEGER NOT NULL,
    "indicador" TEXT NOT NULL,
    "valorCentavos" BIGINT NOT NULL,
    "fonteId" INTEGER NOT NULL,

    CONSTRAINT "financas_municipais_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "regras_limite" (
    "id" SERIAL NOT NULL,
    "codigo" TEXT NOT NULL,
    "titulo" TEXT NOT NULL,
    "baseLegal" TEXT NOT NULL,
    "explicacao" TEXT NOT NULL,
    "parametros" JSONB NOT NULL,
    "vigenciaInicio" DATE NOT NULL,
    "vigenciaFim" DATE,

    CONSTRAINT "regras_limite_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verificacoes_limite" (
    "id" SERIAL NOT NULL,
    "municipioId" INTEGER NOT NULL,
    "regraId" INTEGER NOT NULL,
    "ano" INTEGER NOT NULL,
    "valorApuradoCentavos" BIGINT,
    "limiteCentavos" BIGINT,
    "percentualApurado" DECIMAL(7,4),
    "situacao" "SituacaoLimite" NOT NULL,
    "memoriaCalculo" JSONB NOT NULL,
    "calculadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "verificacoes_limite_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fontes" (
    "id" SERIAL NOT NULL,
    "tipo" "TipoFonte" NOT NULL,
    "nome" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "coletadoEm" TIMESTAMP(3) NOT NULL,
    "hashSha256" CHAR(64),
    "arquivoPath" TEXT,
    "contentType" TEXT,
    "observacao" TEXT,
    "execucaoId" INTEGER,

    CONSTRAINT "fontes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "execucoes_coleta" (
    "id" SERIAL NOT NULL,
    "coletor" TEXT NOT NULL,
    "orgaoId" INTEGER,
    "parametros" JSONB,
    "status" "StatusExecucao" NOT NULL DEFAULT 'EM_ANDAMENTO',
    "iniciadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finalizadoEm" TIMESTAMP(3),
    "registrosLidos" INTEGER NOT NULL DEFAULT 0,
    "registrosGravados" INTEGER NOT NULL DEFAULT 0,
    "erro" TEXT,

    CONSTRAINT "execucoes_coleta_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reportes_erro" (
    "id" SERIAL NOT NULL,
    "entidade" TEXT NOT NULL,
    "entidadeId" INTEGER,
    "pagina" TEXT,
    "mensagem" TEXT NOT NULL,
    "contato" TEXT,
    "status" "StatusReporte" NOT NULL DEFAULT 'ABERTO',
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolvidoEm" TIMESTAMP(3),

    CONSTRAINT "reportes_erro_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "municipios_codigoIbge_key" ON "municipios"("codigoIbge");

-- CreateIndex
CREATE UNIQUE INDEX "municipios_slug_key" ON "municipios"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "orgaos_cnpj_key" ON "orgaos"("cnpj");

-- CreateIndex
CREATE UNIQUE INDEX "orgaos_municipioId_tipo_key" ON "orgaos"("municipioId", "tipo");

-- CreateIndex
CREATE UNIQUE INDEX "partidos_sigla_key" ON "partidos"("sigla");

-- CreateIndex
CREATE UNIQUE INDEX "partidos_numero_key" ON "partidos"("numero");

-- CreateIndex
CREATE UNIQUE INDEX "pessoas_slug_key" ON "pessoas"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "pessoas_cpfHash_key" ON "pessoas"("cpfHash");

-- CreateIndex
CREATE INDEX "pessoas_nomeBusca_idx" ON "pessoas" USING GIN ("nomeBusca" gin_trgm_ops);

-- CreateIndex
CREATE INDEX "mandatos_orgaoId_cargo_idx" ON "mandatos"("orgaoId", "cargo");

-- CreateIndex
CREATE UNIQUE INDEX "mandatos_pessoaId_orgaoId_cargo_inicio_key" ON "mandatos"("pessoaId", "orgaoId", "cargo", "inicio");

-- CreateIndex
CREATE UNIQUE INDEX "funcoes_mesa_mandatoId_funcao_inicio_key" ON "funcoes_mesa"("mandatoId", "funcao", "inicio");

-- CreateIndex
CREATE INDEX "remuneracoes_orgaoId_ano_mes_idx" ON "remuneracoes"("orgaoId", "ano", "mes");

-- CreateIndex
CREATE UNIQUE INDEX "remuneracoes_mandatoId_ano_mes_tipoFolha_key" ON "remuneracoes"("mandatoId", "ano", "mes", "tipoFolha");

-- CreateIndex
CREATE INDEX "remuneracao_itens_remuneracaoId_idx" ON "remuneracao_itens"("remuneracaoId");

-- CreateIndex
CREATE INDEX "diarias_mandatoId_dataInicio_idx" ON "diarias"("mandatoId", "dataInicio");

-- CreateIndex
CREATE UNIQUE INDEX "diarias_orgaoId_chaveOrigem_key" ON "diarias"("orgaoId", "chaveOrigem");

-- CreateIndex
CREATE UNIQUE INDEX "fornecedores_documento_key" ON "fornecedores"("documento");

-- CreateIndex
CREATE INDEX "fornecedores_nomeBusca_idx" ON "fornecedores" USING GIN ("nomeBusca" gin_trgm_ops);

-- CreateIndex
CREATE INDEX "despesas_orgaoId_ano_fase_idx" ON "despesas"("orgaoId", "ano", "fase");

-- CreateIndex
CREATE INDEX "despesas_fornecedorId_idx" ON "despesas"("fornecedorId");

-- CreateIndex
CREATE UNIQUE INDEX "despesas_orgaoId_chaveOrigem_key" ON "despesas"("orgaoId", "chaveOrigem");

-- CreateIndex
CREATE INDEX "contratos_fornecedorId_idx" ON "contratos"("fornecedorId");

-- CreateIndex
CREATE UNIQUE INDEX "contratos_orgaoId_chaveOrigem_key" ON "contratos"("orgaoId", "chaveOrigem");

-- CreateIndex
CREATE INDEX "bens_declarados_pessoaId_eleicaoAno_idx" ON "bens_declarados"("pessoaId", "eleicaoAno");

-- CreateIndex
CREATE UNIQUE INDEX "bens_declarados_eleicaoAno_chaveOrigem_key" ON "bens_declarados"("eleicaoAno", "chaveOrigem");

-- CreateIndex
CREATE INDEX "receitas_campanha_pessoaId_eleicaoAno_idx" ON "receitas_campanha"("pessoaId", "eleicaoAno");

-- CreateIndex
CREATE INDEX "receitas_campanha_doadorDocumento_idx" ON "receitas_campanha"("doadorDocumento");

-- CreateIndex
CREATE UNIQUE INDEX "receitas_campanha_eleicaoAno_chaveOrigem_key" ON "receitas_campanha"("eleicaoAno", "chaveOrigem");

-- CreateIndex
CREATE UNIQUE INDEX "financas_municipais_municipioId_ano_indicador_key" ON "financas_municipais"("municipioId", "ano", "indicador");

-- CreateIndex
CREATE UNIQUE INDEX "regras_limite_codigo_vigenciaInicio_key" ON "regras_limite"("codigo", "vigenciaInicio");

-- CreateIndex
CREATE UNIQUE INDEX "verificacoes_limite_municipioId_regraId_ano_key" ON "verificacoes_limite"("municipioId", "regraId", "ano");

-- CreateIndex
CREATE INDEX "fontes_tipo_coletadoEm_idx" ON "fontes"("tipo", "coletadoEm");

-- CreateIndex
CREATE INDEX "execucoes_coleta_coletor_iniciadoEm_idx" ON "execucoes_coleta"("coletor", "iniciadoEm");

-- CreateIndex
CREATE INDEX "reportes_erro_status_criadoEm_idx" ON "reportes_erro"("status", "criadoEm");

-- AddForeignKey
ALTER TABLE "orgaos" ADD CONSTRAINT "orgaos_municipioId_fkey" FOREIGN KEY ("municipioId") REFERENCES "municipios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mandatos" ADD CONSTRAINT "mandatos_pessoaId_fkey" FOREIGN KEY ("pessoaId") REFERENCES "pessoas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mandatos" ADD CONSTRAINT "mandatos_orgaoId_fkey" FOREIGN KEY ("orgaoId") REFERENCES "orgaos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mandatos" ADD CONSTRAINT "mandatos_partidoId_fkey" FOREIGN KEY ("partidoId") REFERENCES "partidos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mandatos" ADD CONSTRAINT "mandatos_fonteId_fkey" FOREIGN KEY ("fonteId") REFERENCES "fontes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "funcoes_mesa" ADD CONSTRAINT "funcoes_mesa_mandatoId_fkey" FOREIGN KEY ("mandatoId") REFERENCES "mandatos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "funcoes_mesa" ADD CONSTRAINT "funcoes_mesa_fonteId_fkey" FOREIGN KEY ("fonteId") REFERENCES "fontes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "remuneracoes" ADD CONSTRAINT "remuneracoes_orgaoId_fkey" FOREIGN KEY ("orgaoId") REFERENCES "orgaos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "remuneracoes" ADD CONSTRAINT "remuneracoes_mandatoId_fkey" FOREIGN KEY ("mandatoId") REFERENCES "mandatos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "remuneracoes" ADD CONSTRAINT "remuneracoes_fonteId_fkey" FOREIGN KEY ("fonteId") REFERENCES "fontes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "remuneracao_itens" ADD CONSTRAINT "remuneracao_itens_remuneracaoId_fkey" FOREIGN KEY ("remuneracaoId") REFERENCES "remuneracoes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "diarias" ADD CONSTRAINT "diarias_orgaoId_fkey" FOREIGN KEY ("orgaoId") REFERENCES "orgaos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "diarias" ADD CONSTRAINT "diarias_mandatoId_fkey" FOREIGN KEY ("mandatoId") REFERENCES "mandatos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "diarias" ADD CONSTRAINT "diarias_fonteId_fkey" FOREIGN KEY ("fonteId") REFERENCES "fontes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "despesas" ADD CONSTRAINT "despesas_orgaoId_fkey" FOREIGN KEY ("orgaoId") REFERENCES "orgaos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "despesas" ADD CONSTRAINT "despesas_fornecedorId_fkey" FOREIGN KEY ("fornecedorId") REFERENCES "fornecedores"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "despesas" ADD CONSTRAINT "despesas_fonteId_fkey" FOREIGN KEY ("fonteId") REFERENCES "fontes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contratos" ADD CONSTRAINT "contratos_orgaoId_fkey" FOREIGN KEY ("orgaoId") REFERENCES "orgaos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contratos" ADD CONSTRAINT "contratos_fornecedorId_fkey" FOREIGN KEY ("fornecedorId") REFERENCES "fornecedores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contratos" ADD CONSTRAINT "contratos_fonteId_fkey" FOREIGN KEY ("fonteId") REFERENCES "fontes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bens_declarados" ADD CONSTRAINT "bens_declarados_pessoaId_fkey" FOREIGN KEY ("pessoaId") REFERENCES "pessoas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bens_declarados" ADD CONSTRAINT "bens_declarados_fonteId_fkey" FOREIGN KEY ("fonteId") REFERENCES "fontes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receitas_campanha" ADD CONSTRAINT "receitas_campanha_pessoaId_fkey" FOREIGN KEY ("pessoaId") REFERENCES "pessoas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receitas_campanha" ADD CONSTRAINT "receitas_campanha_fonteId_fkey" FOREIGN KEY ("fonteId") REFERENCES "fontes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "financas_municipais" ADD CONSTRAINT "financas_municipais_municipioId_fkey" FOREIGN KEY ("municipioId") REFERENCES "municipios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "financas_municipais" ADD CONSTRAINT "financas_municipais_fonteId_fkey" FOREIGN KEY ("fonteId") REFERENCES "fontes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verificacoes_limite" ADD CONSTRAINT "verificacoes_limite_municipioId_fkey" FOREIGN KEY ("municipioId") REFERENCES "municipios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verificacoes_limite" ADD CONSTRAINT "verificacoes_limite_regraId_fkey" FOREIGN KEY ("regraId") REFERENCES "regras_limite"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fontes" ADD CONSTRAINT "fontes_execucaoId_fkey" FOREIGN KEY ("execucaoId") REFERENCES "execucoes_coleta"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "execucoes_coleta" ADD CONSTRAINT "execucoes_coleta_orgaoId_fkey" FOREIGN KEY ("orgaoId") REFERENCES "orgaos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- ───────── Restrições de integridade (não representáveis no schema Prisma) ─────────

-- Competência válida
ALTER TABLE "remuneracoes" ADD CONSTRAINT "remuneracoes_mes_check" CHECK ("mes" BETWEEN 1 AND 12);
ALTER TABLE "remuneracoes" ADD CONSTRAINT "remuneracoes_ano_check" CHECK ("ano" BETWEEN 2000 AND 2100);

-- Valores monetários não negativos
ALTER TABLE "remuneracoes" ADD CONSTRAINT "remuneracoes_valores_check"
  CHECK ("brutoCentavos" >= 0 AND "descontosCentavos" >= 0 AND ("liquidoCentavos" IS NULL OR "liquidoCentavos" >= 0));
ALTER TABLE "remuneracao_itens" ADD CONSTRAINT "remuneracao_itens_valor_check" CHECK ("valorCentavos" >= 0);
ALTER TABLE "diarias" ADD CONSTRAINT "diarias_valor_check" CHECK ("valorCentavos" >= 0);
ALTER TABLE "contratos" ADD CONSTRAINT "contratos_valor_check" CHECK ("valorCentavos" >= 0);
ALTER TABLE "bens_declarados" ADD CONSTRAINT "bens_declarados_valor_check" CHECK ("valorCentavos" >= 0);
ALTER TABLE "receitas_campanha" ADD CONSTRAINT "receitas_campanha_valor_check" CHECK ("valorCentavos" >= 0);
-- Despesas podem ter valor negativo (estorno/anulação de empenho), por isso ficam de fora.

-- Períodos coerentes
ALTER TABLE "mandatos" ADD CONSTRAINT "mandatos_periodo_check" CHECK ("fim" IS NULL OR "fim" >= "inicio");
ALTER TABLE "funcoes_mesa" ADD CONSTRAINT "funcoes_mesa_periodo_check" CHECK ("fim" IS NULL OR "fim" >= "inicio");
ALTER TABLE "diarias" ADD CONSTRAINT "diarias_periodo_check" CHECK ("dataFim" IS NULL OR "dataFim" >= "dataInicio");

-- Formatos
ALTER TABLE "municipios" ADD CONSTRAINT "municipios_codigo_ibge_check" CHECK ("codigoIbge" ~ '^[0-9]{7}$');
ALTER TABLE "orgaos" ADD CONSTRAINT "orgaos_cnpj_check" CHECK ("cnpj" IS NULL OR "cnpj" ~ '^[0-9]{14}$');
ALTER TABLE "fontes" ADD CONSTRAINT "fontes_hash_check" CHECK ("hashSha256" IS NULL OR "hashSha256" ~ '^[0-9a-f]{64}$');
