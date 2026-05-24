# Chaîne de credentials — à remplir pendant l'examen

| Compte | Mot de passe / Hash / Ticket | Comment obtenu | Testé sur (Pwn3d / accès) |
|--------|------------------------------|----------------|---------------------------|
| pentester | Password123! | Fourni | Toutes machines SMB/RDP |
| | | | |
| | | | |
| | | | |

## Hashes locaux (Administrateur)

| Machine | Hash NT local | Réutilisable ailleurs ? |
|---------|---------------|-------------------------|
| WK-123 | fafb12f22417628bb6422e9bb8686f5c | Oui → WK-124 (TP blanc) |
| WK-044 | 71f14af9da1e0574fec87a153ca23114 | Non (LAPS) |

## Tickets Kerberos (.ccache)

| Fichier | Compte | Source |
|---------|--------|--------|
| | | lsassy sur WK-123 |
| Administrator.ccache | Administrator | getST.py (k.cedepte) |
