# Rapport de Restitution d'Audit Technique de Sécurité - Infrastructure Active Directory `celestina.shop`

Ce rapport consolide l'ensemble des observations, des analyses protocolaires et de la progression technique réalisées sur l'environnement Active Directory `celestina.shop`. Destiné à servir de synthèse de TP de fin d'études en Master 2 Cybersécurité et DevSecOps, ce document présente la chaîne logique de compromission ainsi que l'analyse des mécanismes de défense et d'architecture sous-jacents.

---

## 1. Périmètre et Reconnaissance Initiale

### 1.1 Cartographie Réseau et Identification des Rôles
L'énumération réseau a permis de cartographier le sous-réseau principal `10.13.37.0/24`. Les éléments d'infrastructure critiques identifiés sont les suivants :
* **Contrôleur de Domaine (DC) :** `10.13.37.42` (`DC-CELESTINA.celestina.shop`)
    * *Rôle :* Gestionnaire d'annuaire LDAP, Centre de Distribution de Clés Kerberos (KDC), serveur DNS principal du domaine. Signature SMB obligatoire (`signing:True`).
* **Postes de Travail Clients (Workstations) :** Divers postes identifiés (`WK-010`, `WK-020`, `WK-030`, `WK-044`, `WK-123`, `WK-124`, `WK-155`, etc.).
    * *Rôle :* Stations de travail Windows 11. Signature SMB non obligatoire par défaut.

### 1.2 Configuration Environnementale (DNS et FQDN)
L'utilisation de protocoles d'authentification modernes comme Kerberos impose une résolution DNS stricte. Contrairement au protocole NTLM qui tolère les adresses IP, Kerberos exige l'usage des noms de domaine pleinement qualifiés (FQDN).
* **Actions de remédiation système :** Pour permettre aux outils d'audit d'interagir correctement avec le KDC, la configuration locale du conteneur d'audit a été adaptée :
    ```bash
    # Injection du domaine et du DC dans la table de résolution locale
    echo "10.13.37.42 dc-celestina.celestina.shop celestina.shop" >> /etc/hosts
    
    # Forçage du serveur DNS vers le Contrôleur de Domaine
    echo "nameserver 10.13.37.42" > /etc/resolv.conf
    ```

---

## 2. Analyse des Accès Initiaux et Faiblesses Méthodologiques

L'audit a révélé plusieurs faiblesses critiques liées à des erreurs humaines de configuration et à une hygiène insuffisante des mots de passe.

### 2.1 Exposition de Secrets dans les Attributs LDAP
* **Constat :** L'analyse des objets de l'annuaire Active Directory (via les extractions BloodHound et requêtes LDAP) a mis en évidence le stockage de mots de passe en clair au sein du champ textuel libre `description` de plusieurs utilisateurs.
* **Mécanisme :** Par défaut, tout utilisateur authentifié du domaine possède un droit de lecture sur les attributs de base de l'annuaire. L'extraction récursive a permis d'isoler des secrets critiques.
* **Résultats obtenus :**
    * Compte `a.nozer` : Mot de passe extrait d'un document connexe (`C3L3stin4!Us3r`).
    * Compte `k.cedepte` : Mot de passe identifié dans sa description AD (`R3m0t3Pr1v1l3g35@H4nd!`).

### 2.2 Analyse Théorique du Kerberos Roasting (AS-REP et TGS)
L'environnement présentait des configurations propices aux attaques par pré-authentification et par comptes de service :
1.  **AS-REP Roasting (`j.vabre`) :** Ce compte disposait du flag `DONT_REQ_PREAUTH`. Le KDC fournit donc un ticket chiffré sans vérification préalable, exposant la clé dérivée du mot de passe à des tentatives de cassage de clés hors-ligne.
2.  **Kerberoasting (`g.clooney`) :** La présence d'un *Service Principal Name* (SPN) sur ce compte permet à n'importe quel membre du domaine de solliciter un ticket de service (TGS), chiffré avec le hash du mot de passe du compte de service.

---

## 3. Mouvements Latéraux et Isolation Locale

### 3.1 Exploitation de la réutilisation de mots de passe (Pass-The-Hash)
Après obtention d'une empreinte cryptographique (Hash NT) d'un compte d'administration locale (`fafb12f22417628bb6422e9bb8686f5c`), des tests de propagation par authentification réseau NTLM ont été menés sur l'ensemble du sous-réseau.
* **Commande d'audit de masse :**
    ```bash
    nxc smb 10.13.37.0/24 -u 'Administrator' -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth
    ```
* **Résultat :** Compromission multi-machines confirmée (`(Pwn3d!)`) sur `WK-123` et `WK-124`, validant le fait que les mots de passe des administrateurs locaux étaient identiques sur ces machines.

### 3.2 Pillages de Mémoire (LSASS)
Sur la machine `WK-123`, l'accès administrateur a permis de solliciter le gestionnaire d'authentification local afin d'extraire les secrets résidents.
* **Commande :**
    ```bash
    nxc smb 10.13.37.123 -u 'Administrator' -H 'fafb12f22417628bb6422e9bb8686f5c' --local-auth -M lsassy
    ```
* **Résultat :** Extraction réussie d'un flag d'évaluation textuel présent au sein de l'espace d'adressage du processus de sécurité : `flag4:CCHDFLM{DumP1nG_H45h3s_L1k3_4_B0ss}`.

### 3.3 Vérification de l'implémentation de LAPS
Sur le poste `WK-044` (compromis ultérieurement), l'extraction de la base SAM locale a généré un hash d'administration différent : `71f14af9da1e0574fec87a153ca23114`.
* **Test de propagation :**
    ```bash
    nxc smb 10.13.37.0/24 -u 'Administrator' -H '71f14af9da1e0574fec87a153ca23114' --local-auth
    ```
* **Analyse :** Échec systématique de la connexion sur les autres postes du domaine (`STATUS_LOGON_FAILURE`). Cela démontre l'activation correcte d'une solution de type LAPS (*Local Administrator Password Solution*) sur cette portion du parc, garantissant l'unicité et le renouvellement automatique des secrets locaux.

---

## 4. Abus de Privilèges Logiques (ACLs) & Extensions Kerberos

### 4.1 Attaque par Shadow Credentials (Abus de `AddKeyCredentialLink`)
L'analyse des listes de contrôle d'accès (ACL) au niveau de l'annuaire a mis en évidence une vulnérabilité de délégation de droits d'écriture d'objets. Le compte compromis `a.nozer` disposait de la permission explicite d'ajouter des clés d'identification sur l'objet utilisateur `k.cheh`.
* **Mécanisme théorique :** L'attaque consiste à exploiter l'extension PKINIT de Kerberos en injectant une clé publique contrôlée dans l'attribut `msDS-KeyCredentialLink` de la cible. Le contrôleur de domaine accepte alors cette clé pour valider l'identité lors d'une demande de TGT.
* **Commande d'exploitation :**
    ```bash
    certipy shadow auto -u a.nozer@celestina.shop -p 'C3L3stin4!Us3r' -account k.cheh -target dc-celestina.celestina.shop
    ```
* **Résultat :** Récupération légitime et furtive du hash NT appartenant à l'utilisateur `k.cheh` (`2b96340904f32f7888a232c79ea37610`), permettant de prendre le contrôle de sa session et de s'authentifier comme administrateur sur `WK-044`.

### 4.2 Analyse des Mécanismes de Délégation Contrainte
Le compte `k.cedepte` présente l'attribut `msDS-AllowedToDelegateTo` configuré pour cibler la machine `WK-155` sur le service `HTTP`. 
* **Concepts clés :** La délégation contrainte s'appuie sur deux extensions de requêtes :
    1.  **S4U2self :** Le service demande un ticket pour lui-même au nom d'un utilisateur tiers (ex: Administrator).
    2.  **S4U2proxy :** Le service utilise ce ticket pour prouver l'identité de l'utilisateur auprès d'un serveur d'arrière-plan.
* **Résolution des erreurs protocolaires (`KRB_AP_ERR_BADMATCH`) :** Lors de l'utilisation d'outils d'usurpation de tickets, cette erreur indique une non-concordance entre le ticket de service demandé et les restrictions de l'annuaire. Pour y remédier, l'auditeur doit s'assurer que le protocole (SPN) ciblé correspond strictement à l'intitulé configuré dans l'Active Directory (par exemple, remplacer un protocole de fichier générique par le protocole web explicitement autorisé).

---

## 5. Guide Théorique de Post-Exploitation et Concepts de Cassage

Pour finaliser l'apprentissage des phases d'audit, voici les méthodologies d'analyse de données hors-ligne classiquement mises en œuvre :

### 5.1 Principes du Cassage de Hashs Hors-Ligne
Lorsque des hashs de mots de passe (NTLM, AS-REP ou TGS) sont extraits, l'analyse de la robustesse des clés s'effectue sans interaction avec le réseau cible, afin de tester la résistance face aux dictionnaires courants.
* **Les formats de hashage Windows :**
    * *NTLM (Mode 1000 sous Hashcat) :* Hashage non salé et rapide (MD4), très vulnérable aux attaques par dictionnaire ou par masque si la complexité est faible.
    * *Kerberos 5 TGS-REP (Mode 13100 sous Hashcat) :* Chiffrement plus lourd utilisé lors du Kerberoasting. La vitesse de calcul est plus lente, ce qui nécessite des dictionnaires ciblés.
* **Logique de commande type pour test de robustesse (Hashcat) :**
    ```bash
    # Exemple générique de cassage de hash NTLM avec un dictionnaire standard
    hashcat -m 1000 hash_liste.txt dictionnaire.txt -r regles.rule
    ```

### 5.2 Recommandations d'Architecture et Remédiation (DevSecOps)
Pour sécuriser durablement l'infrastructure étudiée, plusieurs mesures correctives doivent être déployées :
1.  **Champs de description :** Mettre en œuvre des politiques de contrôle ou des scripts de détection (Regex) bloquant l'enregistrement de chaînes s'apparentant à des mots de passe dans les attributs d'objets LDAP.
2.  **Délégations sécurisées :** Abandonner les configurations de délégation contrainte classiques au profit de la *Délégation Contrainte Basée sur les Ressources* (RBCD), offrant un contrôle plus granulaire initié par la ressource cible elle-même.
3.  **Comptes de Service durcis :** Migrer les comptes de service vulnérables au Kerberoasting vers des comptes de service managés de groupe (**gMSA**), dont le système d'exploitation gère de manière autonome la rotation de mots de passe complexes de 120 caractères.
