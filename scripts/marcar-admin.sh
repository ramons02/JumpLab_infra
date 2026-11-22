#!/usr/bin/env bash
# Marca a conta do e-mail informado como administrador (HU016 RN03, D13).
# Uso: scripts/marcar-admin.sh maria@exemplo.com
# Roda o psql no serviço postgres do compose; o e-mail vai como variável do psql (:'email'), nunca
# concatenado no SQL.
set -euo pipefail

if [ "$#" -ne 1 ] || [ -z "$1" ]; then
  echo "Uso: $0 <email>" >&2
  exit 1
fi

pasta="$(cd "$(dirname "$0")/.." && pwd)"
cd "$pasta"

marcadas=$(docker compose exec -T postgres sh -c 'psql -v ON_ERROR_STOP=1 -tA -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v email="$1"' sh "$1" <<'SQL'
WITH marcadas AS (
  UPDATE usuario SET admin = true WHERE email = lower(trim(:'email')) RETURNING id
)
SELECT count(*) FROM marcadas;
SQL
)

echo "Contas marcadas como administrador: ${marcadas}"
