# Playbook 02 — BloodHound CLI (sans GUI)

> Runbook étapes 19–24 | Challenges : *promener le chien*, *Environnement en changement*

## Variables

```bash
export DC_IP=10.13.37.42
export DOMAIN=celestina.shop
export USER=pentester
export PASS='Password123!'
```

---

### Étape 1 — Collecte BloodHound

```bash
cd /workspace
bloodhound-python -u 'pentester' -p 'Password123!' -d celestina.shop -ns 10.13.37.42 -c All
ls -la *.json 2>/dev/null || ls -la */
```

**Résultat attendu** : fichiers `*_users.json`, `*_computers.json`, etc.

**Si Kerberos fail** : refaire [00-setup-vpn-dns.md](00-setup-vpn-dns.md) étapes 4–5.

**Journal** : horodatage collecte → preuve *chien promené*.

---

### Étape 2 — ACL et délégations (grep global)

```bash
grep -i -C 15 "AddKeyCredentialLink" *.json
grep -i -C 15 "AllowedToDelegate\|allowedtodelegate\|trustedtoauth" *.json
grep -i -C 15 "GenericAll\|GenericWrite" *.json
```

**Résultat attendu (TP blanc)** :
- `AddKeyCredentialLink` sur **k.cheh** → a.nozer attaquant
- `allowedtodelegate` : **HTTP/WK-155** pour k.cedepte

---

### Étape 3 — Secrets dans description LDAP

```bash
grep -i '"description"' *users*.json | grep -v '""' | head -50
```

**Résultat attendu (TP blanc)** :
- k.cedepte → `R3m0t3Pr1v1l3g35@H4nd!`
- d.scrip, k.brown, m.jones, etc.

**Journal** : challenge *Décrivez précisément…*

---

### Étape 4 — Script automatique

```bash
bash /workspace/scripts/grep-bh-rights.sh k.cheh
bash /workspace/scripts/grep-bh-rights.sh k.cedepte
```

---

### Étape 5 — Résoudre SID → nom (ex. -1184 = a.nozer)

```bash
grep -i "1184" *users*.json
grep -i '"samaccountname":"a.nozer"' *users*.json
```

---

### Étape 6 — LDAP avec ticket (après PtT)

```bash
nxc ldap dc-celestina.celestina.shop -u 'k.udele' -d celestina.shop --use-kcache
```

*(Après export KRB5CCNAME — voir playbook 05)*
