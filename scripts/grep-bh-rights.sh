#!/usr/bin/env bash
# Analyse CLI des JSON BloodHound
shopt -s nullglob
JSON=( *.json *_*.json )

if [ ${#JSON[@]} -eq 0 ]; then
  echo "[!] Aucun fichier JSON BloodHound dans le répertoire courant."
  echo "    Lancer bloodhound-python puis exécuter ce script dans le dossier des JSON."
  exit 1
fi

echo "=== ACL / délégation / description ==="
grep -i -E "AddKeyCredentialLink|GenericAll|GenericWrite|AllowedToDelegate|allowedtodelegate|trustedtoauth|WriteOwner" "${JSON[@]}" 2>/dev/null | head -80

echo ""
echo "=== Mots de passe dans description (candidats) ==="
grep -i -B2 -A2 '"description"' *users*.json 2>/dev/null | grep -i description | head -40

echo ""
echo "=== Recherche utilisateur (argument optionnel: $1) ==="
if [ -n "${1:-}" ]; then
  grep -i -C 15 "$1" "${JSON[@]}"
fi
