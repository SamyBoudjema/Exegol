# Rapport d'audit de sécurité — Active Directory Celestina

> Remplir **après** l'examen à partir de [JOURNAL_EXAMEN.md](JOURNAL_EXAMEN.md).  
> Exemple de style : [docs/RAPPORT_AUDIT_FINAL_CELESTINA.md](../docs/RAPPORT_AUDIT_FINAL_CELESTINA.md)

---

## 1. Contexte et périmètre

- **Client** : Celestina
- **Objectif** : Audit de posture AD, récupération de flags, preuve d'impact
- **Périmètre réseau** : 10.13.37.0/24 (hors 10.13.37.1), 10.37.13.0/24
- **Compte fourni** : pentester
- **Outils** : Exegol-free, NetExec (nxc), Impacket, Certipy, BloodHound.py, Hashcat

---

## 2. Méthodologie

Décrire les phases suivies (alignées sur le runbook) :

1. Connexion VPN et configuration DNS/Kerberos
2. Reconnaissance (SMB, partages, BloodHound CLI)
3. Attaques Kerberos (AS-REP, Kerberoasting)
4. OSINT interne (partages, LDAP, GPP)
5. Mouvement latéral (PTH, dumps mémoire, PtT)
6. Abus AD avancés (Shadow Credentials, délégations)
7. Pivot vers réseau secondaire (si applicable)

---

## 3. Découverte des flags (un sous-chapitre par flag)

### 3.1 [Nom du challenge]

- **Indice plateforme** :
- **Technique** : (ex. AS-REP Roasting)
- **Découverte** : comment la vulnérabilité a été identifiée
- **Exploitation** : commandes exactes (copier depuis le journal)

```bash

```

- **Preuve** : flag ou capture `(Pwn3d!)` / hash
- **Impact** : ce qu'un attaquant peut faire
- **Référence journal** : [HH:MM] dans JOURNAL_EXAMEN.md

### 3.2 [Challenge suivant]

*(Répéter pour chaque flag validé)*

---

## 4. Synthèse des vulnérabilités

| ID | Vulnérabilité | Sévérité | Actifs concernés |
|----|---------------|----------|------------------|
| V1 | | | |
| V2 | | | |

---

## 5. Recommandations (DevSecOps)

### 5.1 Secrets et annuaire LDAP

- Interdire mots de passe dans `description` / `info`
- Scripts de détection regex sur l'annuaire

### 5.2 Kerberos

- Pré-authentification obligatoire (pas de DONT_REQ_PREAUTH)
- gMSA pour comptes de service avec SPN

### 5.3 ACL et délégations

- Principe du moindre privilège sur `AddKeyCredentialLink`, `GenericAll`
- Limiter délégation contrainte / supprimer non contrainte sur serveurs non-DC

### 5.4 Postes clients

- LAPS sur administrateurs locaux
- Restreindre droits RDP (pas de RDP domaine sur tout le parc)

---

## 6. Conclusion

Résumé en 5–10 lignes : niveau de maturité AD, chemins d'attaque principaux, priorisation des correctifs.

---

## Annexe A — Inventaire machines (TP blanc)

| IP | Hostname | Rôle |
|----|----------|------|
| 10.13.37.42 | DC-CELESTINA | Contrôleur de domaine |
| 10.13.37.123 | WK-123 | Workstation |
| … | WK-XXX | |

## Annexe B — Comptes compromis

*(Table depuis le journal)*
