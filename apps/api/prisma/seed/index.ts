/**
 * Semente de desenvolvimento: Campo Largo – PR, legislatura 2025–2028.
 *
 * Todos os dados vêm de um post de rede social (ver o JSON) e entram como
 * NAO_VERIFICADO, portanto não aparecem na API pública. Idempotente: pode
 * rodar quantas vezes quiser.
 */
import 'dotenv/config';
import { readFile } from 'node:fs/promises';
import { criarPrisma } from '../../src/lib/prisma.js';
import { normalizarBusca } from '../../src/lib/texto.js';

interface Semente {
  municipio: { codigoIbge: string; nome: string; uf: string; slug: string; ativo: boolean };
  orgaos: Array<{
    tipo: 'PREFEITURA' | 'CAMARA';
    nome: string;
    plataforma: 'ATENDE_NET';
    subdominio: string;
    portalUrl: string;
  }>;
  fonte: { nome: string; url: string; coletadoEm: string; observacao: string };
  legislatura: string;
  inicioMandato: string;
  vereadores: Array<{
    nomeUrna: string;
    slug: string;
    partido: string;
    funcaoMesa: 'PRESIDENTE' | null;
    subsidioInformadoCentavos: number;
  }>;
}

const prisma = criarPrisma();

async function main() {
  const arquivo = new URL('./camara-campo-largo-2025.json', import.meta.url);
  const semente = JSON.parse(await readFile(arquivo, 'utf8')) as Semente;
  const coletadoEm = new Date(semente.fonte.coletadoEm);
  const inicio = new Date(semente.inicioMandato);

  const municipio = await prisma.municipio.upsert({
    where: { codigoIbge: semente.municipio.codigoIbge },
    update: { nome: semente.municipio.nome, ativo: semente.municipio.ativo },
    create: semente.municipio,
  });

  const orgaos = new Map<string, number>();
  for (const o of semente.orgaos) {
    const orgao = await prisma.orgao.upsert({
      where: { municipioId_tipo: { municipioId: municipio.id, tipo: o.tipo } },
      update: { nome: o.nome, plataforma: o.plataforma, subdominio: o.subdominio, portalUrl: o.portalUrl },
      create: { ...o, municipioId: municipio.id },
    });
    orgaos.set(o.tipo, orgao.id);
  }
  const camaraId = orgaos.get('CAMARA')!;

  const fonte =
    (await prisma.fonte.findFirst({ where: { tipo: 'REDE_SOCIAL', nome: semente.fonte.nome } })) ??
    (await prisma.fonte.create({ data: { ...semente.fonte, tipo: 'REDE_SOCIAL', coletadoEm } }));

  for (const v of semente.vereadores) {
    const partido = await prisma.partido.upsert({
      where: { sigla: v.partido },
      update: {},
      create: { sigla: v.partido },
    });

    const pessoa = await prisma.pessoa.upsert({
      where: { slug: v.slug },
      update: { nomeUrna: v.nomeUrna, nomeBusca: normalizarBusca(v.nomeUrna) },
      create: { slug: v.slug, nomeUrna: v.nomeUrna, nomeBusca: normalizarBusca(v.nomeUrna) },
    });

    const chaveMandato = { pessoaId: pessoa.id, orgaoId: camaraId, cargo: 'VEREADOR' as const, inicio };
    const mandato = await prisma.mandato.upsert({
      where: { pessoaId_orgaoId_cargo_inicio: chaveMandato },
      update: { partidoId: partido.id, legislatura: semente.legislatura, fonteId: fonte.id },
      create: {
        ...chaveMandato,
        partidoId: partido.id,
        legislatura: semente.legislatura,
        verificacao: 'NAO_VERIFICADO',
        fonteId: fonte.id,
      },
    });

    if (v.funcaoMesa) {
      await prisma.funcaoMesa.upsert({
        where: { mandatoId_funcao_inicio: { mandatoId: mandato.id, funcao: v.funcaoMesa, inicio } },
        update: {},
        create: { mandatoId: mandato.id, funcao: v.funcaoMesa, inicio, fonteId: fonte.id },
      });
    }

    // O post não informa a competência: registra no mês da coleta, como bruto,
    // marcado como não verificado. Será substituído pela folha do Atende.Net.
    const competencia = { ano: coletadoEm.getFullYear(), mes: coletadoEm.getMonth() + 1 };
    await prisma.remuneracao.upsert({
      where: {
        mandatoId_ano_mes_tipoFolha: { mandatoId: mandato.id, ...competencia, tipoFolha: 'MENSAL' },
      },
      update: { brutoCentavos: BigInt(v.subsidioInformadoCentavos) },
      create: {
        orgaoId: camaraId,
        mandatoId: mandato.id,
        ...competencia,
        brutoCentavos: BigInt(v.subsidioInformadoCentavos),
        verificacao: 'NAO_VERIFICADO',
        fonteId: fonte.id,
      },
    });
  }

  const total = await prisma.remuneracao.aggregate({
    where: { orgaoId: camaraId, verificacao: 'NAO_VERIFICADO' },
    _sum: { brutoCentavos: true },
    _count: true,
  });
  console.log(
    `Semente aplicada: ${municipio.nome}-${municipio.uf}, ${total._count} vereadores, ` +
      `subsídios somados R$ ${(Number(total._sum.brutoCentavos ?? 0n) / 100).toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`,
  );
}

main()
  .catch((e) => {
    console.error(e);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
