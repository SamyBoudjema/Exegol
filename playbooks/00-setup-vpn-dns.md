# Playbook 00 — VPN, Exegol, DNS

> Voir aussi : [RUNBOOK-CHRONOLOGIQUE.md](RUNBOOK-CHRONOLOGIQUE.md) étapes 1–8 | [scripts/setup-dns.sh](../scripts/setup-dns.sh)

## Variables (remplir une fois)

```bash
export DC_IP=10.13.37.42
export DOMAIN=celestina.shop
export DC_HOST=dc-celestina
export SUBNET=10.13.37.0/24
export SUBNET_HIDDEN=10.37.13.0/24
export USER=pentester
export PASS='Password123!'
```

---

### Étape 1 — Connexion VPN

**Objectif** : accéder au réseau cible.

```bash
sudo openvpn --config /chemin/vers/fourni.par.le.prof.ovpn
```

**Résultat attendu** : interface tun/tap, routes vers 10.13.37.0/24 (et éventuellement 10.37.13.0/24).

**Journal** : noter l’IP VPN attribuée (`ip a`).

---

### Étape 2 — Vérifier connectivité

```bash
ip a
ip route
ping -c 2 10.13.37.42
```

**Résultat attendu** : réponses du DC (si ICMP autorisé).

---

### Étape 3 — Lancer Exegol (si hors conteneur)

```bash
exegol start free
exegol connect free
cd /workspace
```

---

### Étape 4 — Configurer /etc/hosts

```bash
echo "10.13.37.42 dc-celestina.celestina.shop celestina.shop" | sudo tee -a /etc/hosts
cat /etc/hosts | grep celestina
```

**Résultat attendu** : ligne avec DC_IP et FQDN du DC.

---

### Étape 5 — Forcer le DNS vers le DC

```bash
echo "nameserver 10.13.37.42" | sudo tee /etc/resolv.conf
cat /etc/resolv.conf
nslookup dc-celestina.celestina.shop
```

**Résultat attendu** : résolution vers 10.13.37.42.

**Si échec** : voir [cheatsheets/kerberos-troubleshooting.md](../cheatsheets/kerberos-troubleshooting.md).

---

### Étape 6 — Valider les credentials sur le DC

```bash
nxc smb 10.13.37.42 -u 'pentester' -p 'Password123!'
```

**Résultat attendu** : `[+] celestina.shop\pentester:Password123!`

---

### Étape 7 — tmux (recommandé)

```bash
tmux new -s exam
# Ctrl+b puis c : nouvelle fenêtre | Ctrl+b puis 1/2 : changer de fenêtre
```

**Journal** : une fenêtre pour hashcat, une pour nxc.
