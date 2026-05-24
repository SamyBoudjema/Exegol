#!/usr/bin/env bash
# Génère targets.txt (FQDN) pour nxc -k
DOMAIN="${DOMAIN:-celestina.shop}"
OUT="${1:-targets.txt}"

cat > "$OUT" << EOF
WK-010.$DOMAIN
WK-020.$DOMAIN
WK-030.$DOMAIN
WK-044.$DOMAIN
WK-101.$DOMAIN
WK-111.$DOMAIN
WK-123.$DOMAIN
WK-124.$DOMAIN
WK-132.$DOMAIN
WK-137.$DOMAIN
WK-155.$DOMAIN
WK-202.$DOMAIN
WK-222.$DOMAIN
WK-234.$DOMAIN
dc-celestina.$DOMAIN
EOF

echo "[+] Écrit $(wc -l < "$OUT") hôtes dans $OUT"
