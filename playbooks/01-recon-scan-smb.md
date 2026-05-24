# Playbook 01 — Reconnaissance SMB / partages / RDP

> Runbook étapes 9–18 | Challenge : *Le goût par défaut*, *Un RDP non-nécessaire*

## Variables

```bash
export DC_IP=10.13.37.42
export SUBNET=10.13.37.0/24
export USER=pentester
export PASS='Password123!'
```

---

### Étape 1 — Scan SMB du segment

```bash
nxc smb 10.13.37.0/24 -u 'pentester' -p 'Password123!'
```

**Résultat attendu** : liste WK-XXX + DC-CELESTINA, `[+]` sur machines accessibles.

**Journal** : lister les IP actives.

---

### Étape 2 — Lister les partages (DC + workstations)

```bash
nxc smb 10.13.37.42 -u 'pentester' -p 'Password123!' --shares
nxc smb 10.13.37.0/24 -u 'pentester' -p 'Password123!' --shares
```

**Résultat attendu** : SYSVOL, NETLOGON sur DC ; partages type **HUB**, **Todo**, etc. sur WK.

---

### Étape 3 — Spider partage intéressant (ex. HUB sur WK-123)

```bash
nxc smb 10.13.37.123 -u 'pentester' -p 'Password123!' -M spider_plus --share HUB
```

**Résultat attendu** : fichiers dont `notice.pdf`.

---

### Étape 4 — Télécharger / lire notice.pdf

```bash
smbclient //10.13.37.123/HUB -U 'pentester%Password123!' -c 'ls'
smbclient //10.13.37.123/HUB -U 'pentester%Password123!' -c 'get notice.pdf'
strings notice.pdf | less
strings notice.pdf | grep -i -E 'password|default|C3L|compte|flag'
```

**Résultat attendu (TP blanc)** : mot de passe par défaut `C3L3stin4!Us3r`.

**Journal** : noter le mot de passe → challenge *Le goût par défaut*.

---

### Étape 5 — Explorer partage Todo

```bash
smbclient //10.13.37.123/Todo -U 'pentester%Password123!'
# Dans smbclient : ls, get fichier.txt, exit
```

---

### Étape 6 — Test RDP (droit excessif pentester)

```bash
nxc rdp 10.13.37.0/24 -u 'pentester' -p 'Password123!'
```

**Résultat attendu (TP blanc)** : `[+]` sur toutes les machines → *Un RDP non-nécessaire*.

**Journal** : documenter que pentester peut RDP partout sans besoin métier.

---

### Étape 7 — Enum utilisateurs via RID (pour spray)

```bash
nxc smb 10.13.37.42 -u 'pentester' -p 'Password123!' --rid-brute 2>/dev/null | grep SidTypeUser | awk -F'\\' '{print $2}' | awk '{print $1}' | sort -u > users.txt
wc -l users.txt
head users.txt
```

**Résultat attendu** : fichier users.txt (~90 comptes TP blanc).
