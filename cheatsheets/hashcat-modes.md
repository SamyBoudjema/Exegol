# Hashcat — modes utiles Celestina / AD

| Type | Mode `-m` | Fichier source | Commande type |
|------|-----------|----------------|---------------|
| NTLM (hash NT) | 1000 | secretsdump, SAM | `hashcat -m 1000 ntlm.txt /usr/share/wordlists/rockyou.txt` |
| Kerberos AS-REP | 18200 | GetNPUsers.py | `hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt --force` |
| Kerberos TGS (Kerberoast) | 13100 | GetUserSPNs.py | `hashcat -m 13100 kerb.txt /usr/share/wordlists/rockyou.txt --force` |

## Règles optionnelles (comptes service)

```bash
hashcat -m 13100 kerb.txt /usr/share/wordlists/rockyou.txt --rules-file /usr/share/hashcat/rules/best64.rule --force
```

## Afficher un crack déjà trouvé

```bash
hashcat -m 18200 asrep.txt --show
hashcat -m 13100 kerb.txt --show
```

## TP blanc — résultats connus (entraînement)

| Compte | Mode | Mot de passe |
|--------|------|--------------|
| j.vabre | 18200 | Coffee4me! |
| g.clooney | 13100 | CoffeeMug!1 |
