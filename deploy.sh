#!/usr/bin/env bash
# Despliegue manual a Infomaniak, alternativa a la GitHub Action.
# Credenciales en .env.deploy (NO versionado):
#   FTP_HOST=ftp.cinemafilmak.com
#   FTP_USER=usuario_restringido
#   FTP_PASSWORD=...
#   FTP_DIR=/            # carpeta del subdominio dentro de ese usuario
#
#   ./deploy.sh          sube
#   ./deploy.sh -n       simulacro: dice qué subiría, sin tocar nada
set -euo pipefail
cd "$(dirname "$0")"

[ -f .env.deploy ] || { echo "Falta .env.deploy (mira la cabecera de este script)"; exit 1; }
set -a; . ./.env.deploy; set +a
: "${FTP_HOST:?}" "${FTP_USER:?}" "${FTP_PASSWORD:?}" "${FTP_DIR:?}"
command -v lftp >/dev/null || { echo "Falta lftp: brew install lftp"; exit 1; }

DRY=""; [ "${1:-}" = "-n" ] && DRY="--dry-run"

rm -rf _site && mkdir -p _site
cp index.html webar.html realizacion-nivel1.html _site/
[ -d media ] && cp -r media _site/
echo "Subiendo a $FTP_HOST$FTP_DIR ${DRY:+(simulacro)}"
lftp -c "
  set ftp:ssl-force true;
  set ftp:ssl-protect-data true;
  open -u \"$FTP_USER\",\"$FTP_PASSWORD\" \"$FTP_HOST\";
  mirror -R --verbose $DRY --parallel=2 --exclude-glob .git* _site \"$FTP_DIR\";
"
echo "Hecho. Comprueba https://puzzle.cinemafilmak.com/?v=\$(date +%s)"
