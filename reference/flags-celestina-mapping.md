# Mapping indices → techniques → playbooks

> Les flags exacts peuvent changer à l'examen ; la **technique** reste la preuve à documenter dans le rapport.

| Indice / titre | Catégorie | Technique | Commande clé | Playbook |
|----------------|-----------|-----------|--------------|----------|
| Par défaut c'est ok, mais change le stp | Network | Mot de passe par défaut dans doc | `strings notice.pdf`, spray `users.txt` | 01, 04 |
| Certains champs… fuiter des informations | Network | `description` LDAP | `grep description *users*.json` | 02, 04 |
| N'importe qui sur le domaine peut le lire | Network | SYSVOL / GPP | `nxc -M gpp_password` | 04 |
| N'aiment pas prouver qui ils sont | Kerberos | AS-REP Roasting | `GetNPUsers.py` + hashcat 18200 | 03 |
| Café / secrets (CAAS) | Kerberos | Kerberoasting | `GetUserSPNs.py` + hashcat 13100 | 03 |
| Réutilisation mot de passe / NTHash | Network | Pass-The-Hash local | `nxc --local-auth -H` | 05 |
| Secrets en mémoire | Bonus | lsassy / LSA | `nxc -M lsassy` | 05 |
| RDP pas obligatoire | Bonus | RDP ouvert à pentester | `nxc rdp` | 01 |
| Ombre / ténébreux | Kerberos | Shadow Credentials | `certipy-ad shadow auto` | 06 |
| Déléguer / non contraint | Kerberos | Constrained S4U ou UD | `getST.py` / `--trusted-for-delegation` | 07, 08 |
| Promener le chien | Kerberos | BloodHound | `bloodhound-python -c All` | 02 |
| Protocole KRB enclenché | Kerberos | Pass-The-Ticket | `export KRB5CCNAME` + `nxc -k` | 05 |
| Réseau non accessible | Network | Pivot dual-homed | `ipconfig` + scan 10.37.13.0/24 | 09 |

## Preuves à capturer pour le rapport

1. Capture terminal de la commande d'exploitation
2. Ligne de succès (`[+]`, `(Pwn3d!)`, hash, ou flag)
3. Une phrase d'impact (ex. « accès admin local sur N machines »)

## Section entraînement uniquement

Ne pas confondre avec l'examen si les flags sont régénérés. Voir [docs/RECAP-COMMANDES-TP-CELESTINA.md](../docs/RECAP-COMMANDES-TP-CELESTINA.md) pour la chronologie TP blanc.
