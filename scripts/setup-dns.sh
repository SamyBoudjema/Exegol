#!/usr/bin/env bash
# Configuration DNS/hosts pour Celestina (Exegol)
set -euo pipefail

DC_IP="${DC_IP:-10.13.37.42}"
DOMAIN="${DOMAIN:-celestina.shop}"
DC_HOST="${DC_HOST:-dc-celestina}"

echo "[*] Configuration pour $DOMAIN (DC: $DC_IP)"

if ! grep -q "$DC_HOST.$DOMAIN" /etc/hosts 2>/dev/null; then
  echo "$DC_IP $DC_HOST.$DOMAIN $DOMAIN" | sudo tee -a /etc/hosts
else
  echo "[*] Entrée déjà présente dans /etc/hosts"
fi

echo "nameserver $DC_IP" | sudo tee /etc/resolv.conf

echo "[*] Test résolution:"
nslookup "$DC_HOST.$DOMAIN" || true
echo "[*] Test SMB:"
nxc smb "$DC_IP" -u "${USER:-pentester}" -p "${PASS:-Password123!}" 2>/dev/null | head -5 || echo "Ajuster USER/PASS si besoin"
