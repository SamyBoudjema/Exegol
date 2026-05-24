# Guide d'examen — Active Directory Celestina (Exegol CLI)

Repo de révision pour l'examen de cybersécurité forensic / pentest AD. **Internet autorisé** le jour J ; ce dépôt sert de mémoire externe (commandes, runbooks, journal de rapport).

## Jour J — par où commencer

1. **[playbooks/RUNBOOK-CHRONOLOGIQUE.md](playbooks/RUNBOOK-CHRONOLOGIQUE.md)** — fil principal : toutes les étapes dans l'ordre, commandes complètes
2. **[exam-journal/JOURNAL_EXAMEN.md](exam-journal/JOURNAL_EXAMEN.md)** — noter chaque action (base du rapport final)
3. **[EXAM-CHECKLIST.md](EXAM-CHECKLIST.md)** — cocher les 14 challenges / flags

## Si tu es bloqué

| Problème | Fichier |
|----------|---------|
| Kerberos / DNS / FQDN | [cheatsheets/kerberos-troubleshooting.md](cheatsheets/kerberos-troubleshooting.md) |
| Modes hashcat | [cheatsheets/hashcat-modes.md](cheatsheets/hashcat-modes.md) |
| Outils Exegol | [cheatsheets/exegol-commands.md](cheatsheets/exegol-commands.md) |

## Références TP blanc & camarade

| Fichier | Usage |
|---------|--------|
| [docs/RECAP-COMMANDES-TP-CELESTINA.md](docs/RECAP-COMMANDES-TP-CELESTINA.md) | Synthèse chronologique du TP (discuss_gemini distillé) |
| [docs/NOTES-PENTEST-REFERENCE.md](docs/NOTES-PENTEST-REFERENCE.md) | Patterns validés (notes-pentest-brutes → Celestina) |
| [docs/notes-pentest-brutes.md](docs/notes-pentest-brutes.md) | Notes détaillées camarade (4 flags, même toolchain) |
| [docs/discuss_gemini.md](docs/discuss_gemini.md) | Journal brut conversation TP |
| [docs/ENONCE_TP_CELESTINA.md](docs/ENONCE_TP_CELESTINA.md) | Liste des challenges |

## Playbooks par thème

| Fichier | Sujet |
|---------|--------|
| [playbooks/00-setup-vpn-dns.md](playbooks/00-setup-vpn-dns.md) | VPN, DNS, hosts |
| [playbooks/01-recon-scan-smb.md](playbooks/01-recon-scan-smb.md) | Scan SMB, partages, RDP |
| [playbooks/02-bloodhound-cli.md](playbooks/02-bloodhound-cli.md) | BloodHound sans GUI |
| [playbooks/03-kerberos-roasting.md](playbooks/03-kerberos-roasting.md) | AS-REP + Kerberoast |
| [playbooks/04-ldap-secrets.md](playbooks/04-ldap-secrets.md) | description LDAP, SYSVOL, GPP |
| [playbooks/05-lateral-ptH-lsass.md](playbooks/05-lateral-ptH-lsass.md) | PTH, lsassy, PtT |
| [playbooks/06-shadow-credentials.md](playbooks/06-shadow-credentials.md) | certipy shadow |
| [playbooks/07-delegation-constrained.md](playbooks/07-delegation-constrained.md) | getST / S4U |
| [playbooks/08-delegation-unconstrained.md](playbooks/08-delegation-unconstrained.md) | Unconstrained delegation |
| [playbooks/09-pivot-reseau-cache.md](playbooks/09-pivot-reseau-cache.md) | Réseau 10.37.13.0/24 |

## Théorie & rapport

- [docs/REVISION_AD_TP.md](docs/REVISION_AD_TP.md) — concepts AD (Kerberos, ACL, LAPS…)
- [docs/RAPPORT_AUDIT_FINAL_CELESTINA.md](docs/RAPPORT_AUDIT_FINAL_CELESTINA.md) — exemple de rapport
- [exam-journal/RAPPORT-FINAL-TEMPLATE.md](exam-journal/RAPPORT-FINAL-TEMPLATE.md) — template à remplir après l'examen

## Scripts

```bash
scripts/setup-dns.sh
scripts/gen-targets-fqdn.sh
scripts/grep-bh-rights.sh
scripts/roast-and-crack.sh
```
