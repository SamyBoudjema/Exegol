# Checklist examen — Celestina AD

Référence challenges : [docs/ENONCE_TP_CELESTINA.md](docs/ENONCE_TP_CELESTINA.md)  
Runbook : [playbooks/RUNBOOK-CHRONOLOGIQUE.md](playbooks/RUNBOOK-CHRONOLOGIQUE.md)  
Journal : [exam-journal/JOURNAL_EXAMEN.md](exam-journal/JOURNAL_EXAMEN.md)

| # | Challenge | Pts | Runbook | Playbook | Technique | TP blanc | Soumis | Journal |
|---|-----------|-----|---------|----------|-----------|----------|--------|---------|
| 1 | Le goût par défaut est le meilleur goût | 100 | 7 | 01 | notice.pdf / HUB | Fait | ☐ | ☐ |
| 2 | Décrivez précisement, mais pas trop | 100 | 16 | 04 | description LDAP | Fait | ☐ | ☐ |
| 3 | Un secret trop partagé n'est plus secret | 100 | 17 | 04 | SYSVOL / GPP | À tester | ☐ | ☐ |
| 4 | Un café vraiment pas sécurisé | 100 | 12 | 03 | AS-REP j.vabre | Fait | ☐ | ☐ |
| 5 | CAAS ou Café as a service | 100 | 13 | 03 | Kerberoast g.clooney | Fait | ☐ | ☐ |
| 6 | Passe moi le sel, euh le hash | 200 | 19 | 05 | PTH admin local | Fait | ☐ | ☐ |
| 7 | Caché dans le secret LSA | 100 | 20 | 05 | lsassy / flag sortie | Fait | ☐ | ☐ |
| 8 | Un RDP non-nécessaire | 100 | 11 | 01 | nxc rdp pentester partout | Fait | ☐ | ☐ |
| 9 | Je vis dans l'ombre, je suis ténébreux | 400 | 23 | 06 | Shadow Credentials | Fait | ☐ | ☐ |
| 10 | Libéré, délivré, non contraint | 400 | 25 | 07 / 08 | Constrained / Unconstrained | En cours | ☐ | ☐ |
| 11 | Environnement en perpétuel changement | ??? | 9–10 | 02 | BloodHound collecte | Fait | ☐ | ☐ |
| 12 | Cible acquise, protocole KRB | ??? | 21 | 05 | PtT lsassy | Fait | ☐ | ☐ |
| 13 | Avez-vous promené le chien ? | ??? | 9 | 02 | BloodHound | Fait | ☐ | ☐ |
| 14 | Pivot 10.37.13.0/24 | — | 22, 26 | 09 | ipconfig dual-homed | Non | ☐ | ☐ |

## Pré-vol examen

- [ ] VPN testé
- [ ] Exegol `free` démarre
- [ ] Variables exportées (runbook étape 0)
- [ ] `scripts/setup-dns.sh` OK
- [ ] Journal ouvert dans un onglet
- [ ] Repo cloné / accessible hors ligne si possible

## Post-examen

- [ ] Tous flags soumis sur plateforme
- [ ] Journal complété
- [ ] [RAPPORT-FINAL-TEMPLATE.md](exam-journal/RAPPORT-FINAL-TEMPLATE.md) rédigé
