/** Normaliza nomes para a coluna `nomeBusca`: minúsculas, sem acentos, espaços simples. */
export function normalizarBusca(...partes: Array<string | null | undefined>): string {
  return partes
    .filter((p): p is string => Boolean(p))
    .join(' ')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}
