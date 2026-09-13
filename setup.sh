#!/usr/bin/env bash
# FidoBank demo'ni noldan ko'taradi.
#   ./setup.sh          - ko'taradi va sxemani yuklaydi
#   ./setup.sh --fresh  - avval hamma narsani (baza volume'i bilan) o'chiradi
set -euo pipefail
cd "$(dirname "$0")"

if [ "${1:-}" = "--fresh" ]; then
  echo ">> Eski stack o'chirilyapti"
  docker compose down -v
fi

echo ">> Konteynerlar ko'tarilyapti (Oracle healthy bo'lguncha kutiladi)"
docker compose up -d --build

echo ">> Sxema yuklanyapti"
# Sxema ataylab shu yerda yuklanadi, initdb.d orqali emas: gvenzl obrazi
# initdb skriptlarini APP_USER yaratilishidan oldin bajaradi.
docker exec -i fidobank-oracle \
  sqlplus -s bank/bank123@//localhost:1521/XEPDB1 < db/init/01_schema.sql

echo ">> Tekshiruv"
for i in $(seq 1 30); do
  code=$(docker exec fidobank-app bash -c \
    'exec 3<>/dev/tcp/localhost/8080 && echo -e "GET / HTTP/1.0\r\n\r" >&3 && head -1 <&3' \
    2>/dev/null | grep -o '[0-9]\{3\}' | head -1 || true)
  if [ "$code" = "200" ]; then
    echo ">> TAYYOR: http://localhost:8080"
    exit 0
  fi
  sleep 2
done

echo ">> OGOHLANTIRISH: ilova javob bermadi, log'ga qarang:"
echo "   docker compose logs app --tail 40"
exit 1
