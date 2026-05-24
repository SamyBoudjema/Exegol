# Fiche de Révision : Sécurité Active Directory & Méthodologie d'Audit (Lab Celestina)

Ce guide de révision au format `README.md` compile les concepts théoriques, l'analyse d'architecture, la compréhension des protocoles et les mécanismes de durcissement (hardening) étudiés lors du TP sur l'environnement `celestina.shop`. Conçu pour la préparation de l'examen final de Master 2 en Cybersécurité / DevSecOps, il met l'accent sur la compréhension profonde des attaques de protocoles et des mauvaises configurations d'annuaire.

---

## Table des Matières
1. [Architecture du Domaine & Énumération Globale](#1-architecture-du-domaine--énumération-globale)
2. [Faiblesses de Configuration Humaine & Fuites de Données](#2-faiblesses-de-configuration-humaine--fuites-de-données)
3. [Attaques sur les Protocoles d'Authentification (Kerberos)](#3-attaques-sur-les-protocoles-dauthentification-kerberos)
4. [Abus de Droits et Listes de Contrôle d'Accès (ACL) : Shadow Credentials](#4-abus-de-droits-et-listes-de-contrôle-daccès-acl--shadow-credentials)
5. [Analyse de Post-Exploitation & Limites du Mouvement Latéral](#5-analyse-de-post-exploitation--limites-du-mouvement-latéral)
6. [Mécanismes de Délégation Kerberos & Résolution d'Erreurs](#6-mécanismes-de-délégation-kerberos--résolution-derreurs)
7. [Guide DevSecOps : Remédiation et Durcissement AD](#7-guide-devsecops--remédiation-et-durcissement-ad)

---

## 1. Architecture du Domaine & Énumération Globale

### Les Fondations du Réseau
La cartographie réseau est la première étape indispensable pour comprendre la topologie de l'Active Directory. 
* **Le Contrôleur de Domaine (DC) :** Pivot central de l'annuaire, il gère l'authentification, le catalogue global et les services DNS/Kerberos. Il se repère par la présence obligatoire de la signature SMB (`signing:True`) et l'écoute sur les ports standardisés : 445 (SMB), 389 (LDAP), 88 (Kerberos), 53 (DNS).
* **Les Postes de Travail (Workstations - WK) :** Représentent la surface d'exposition principale. L'absence de signature SMB obligatoire sur les postes clients facilite les techniques de relais si l'authentification NTLM est active.

### L'Impératif DNS sous Kerberos
Kerberos est un protocole de sécurité strict qui s'appuie sur le principe de non-répudiation et de contraintes de temps. Une erreur classique consiste à scanner ou interroger des services en utilisant des adresses IP.
* **Le Mécanisme :** Kerberos utilise des *Service Principal Names* (SPN) pour attribuer des tickets de service. Ces SPN sont intimement liés aux noms de domaine complets (**FQDN**, ex: `WK-123.celestina.shop`).
* **La Configuration :** Le système de l'auditeur ou de l'ingénieur DevSecOps doit impérativement utiliser le serveur DNS interne de l'architecture (le DC) pour résoudre dynamiquement l'ensemble des noms de machines. Sans cette modification de la configuration de résolution locale (`/etc/resolv.conf`), les requêtes d'authentification Kerberos échouent systématiquement.

---

## 2. Faiblesses de Configuration Humaine & Fuites de Données

### L'Abus des Attributs Textuels LDAP
L'une des vulnérabilités les plus fréquentes et les plus simples à identifier en entreprise réside dans le détournement des champs de texte libre de l'annuaire Active Directory à des fins de documentation par les équipes informatiques.

* **L'Attribut `description` :** Conçu originellement pour renseigner la fonction ou le service d'un collaborateur, il est parfois utilisé pour consigner des mots de passe temporaires, des codes d'activation ou des notes de déploiement lors de l'intégration de nouveaux comptes ou de pipelines d'automatisation.
* **Méthodologie d'Analyse :** Tout utilisateur authentifié sur le domaine (même avec les privilèges les plus bas) possède le droit de lire les attributs de base des autres objets de l'annuaire via des requêtes LDAP. L'extraction et le filtrage systématique de ces attributs (comme le champ `description` ou `info`) via des scripts ou des outils d'analyse de graphes permettent de découvrir des secrets critiques sans déclencher d'alertes majeures.
* **Flag associé (Mémoire du TP) :** *« Décrivez précisément, mais pas trop »* — Lié à la découverte de secrets dans les descriptions d'utilisateurs.

---

## 3. Attaques sur les Protocoles d'Authentification (Kerberos)

### AS-REP Roasting (Comptes sans Pré-authentification)
* **Le Concept Théorique :** Par défaut, Kerberos exige une pré-authentification : l'utilisateur chiffre un horodatage avec son propre secret pour prouver son identité avant que le DC ne lui fournisse un ticket maître (TGT). Cependant, pour des raisons de compatibilité avec de vieilles applications, l'attribut `DONT_REQ_PREAUTH` peut être activé sur certains comptes.
* **Le Mécanisme d'Attaque :** Si la pré-authentification n'est pas requise, n'importe qui peut envoyer une requête de demande de ticket (AS-REQ) au nom de l'utilisateur visé. Le Contrôleur de Domaine répond immédiatement en envoyant une structure AS-REP contenant un composant chiffré avec la clé dérivée du mot de passe de l'utilisateur. L'auditeur peut intercepter cette réponse hors-ligne et tenter de casser le chiffrement par force brute pour retrouver le mot de passe en clair.
* **Flag associé (Mémoire du TP) :** *« Un café vraiment pas sécurisé »* (référence à l'absence de pré-authentification sur des comptes spécifiques).

### Kerberoasting (Comptes de Service avec SPN)
* **Le Concept Théorique :** Lorsqu'un utilisateur a besoin d'accéder à un service spécifique dans le domaine (un serveur SQL, un serveur web, etc.), il demande au DC un ticket de service appelé TGS (*Ticket Granting Service*). Ce TGS est chiffré à l'aide de la clé secrète du compte qui exécute le service en question.
* **Le Mécanisme d'Attaque :** Tout utilisateur authentifié du domaine a le droit légitime de demander un TGS pour n'importe quel compte possédant un *Service Principal Name* (SPN) enregistré. Un attaquant va donc demander massivement des tickets pour les comptes de service du domaine, les extraire de sa propre mémoire de session, puis tenter un cassage de mots de passe hors-ligne. Étant donné que les comptes de service ont historiquement des mots de passe robustes mais statiques, ou parfois faibles par négligence, cette attaque est redoutable pour obtenir un accès initial persistant.
* **Flag associé (Mémoire du TP) :** *« CAAS ou Café as a service »* (référence à l'extraction de hashs de comptes de service dotés de SPN).

---

## 4. Abus de Droits et Listes de Contrôle d'Accès (ACL) : Shadow Credentials

Les attaques modernes sur l'Active Directory se concentrent massivement sur l'abus de privilèges logiques accordés par les ACL (*Access Control Lists*). Celles-ci définissent les permissions précises (droits de lecture, d'écriture, de modification) qu'un objet possède sur un autre.

### La Technique des Shadow Credentials
Cette technique avancée repose sur l'exploitation des droits de modification sur l'attribut spécifique `msDS-KeyCredentialLink` d'une identité cible (utilisateur ou ordinateur).

```
[Compte A (ex: a.nozer)] 
       │
       ▼ (Possède le droit ACL : AddKeyCredentialLink)
[Compte Cible (ex: k.cheh)] 
       │
       ▼ (Injection d'une clé publique dans msDS-KeyCredentialLink)
[Authentification PKINIT (Certificat)] ──► [Obtention d'un TGT / Hash NT]
```

* **Le Principe Mécanique :** Si un compte A possède la permission `GenericWrite`, `GenericAll` ou spécifiquement `AddKeyCredentialLink` sur un compte B, il a le droit de modifier les structures de clés d'authentification de ce dernier.
* **L'Exploitation :** L'attaquant génère une paire de clés asymétriques (un certificat auto-signé) et écrit la clé publique directement dans l'attribut `msDS-KeyCredentialLink` de la cible. L'Active Directory considère désormais cette clé comme un moyen d'authentification légitime pour ce compte via l'extension PKINIT (Kerberos supportant l'authentification par clé publique/certificat).
* **Le Résultat :** L'attaquant s'authentifie auprès du DC en utilisant sa clé privée correspondante, obtient un ticket TGT au nom de la cible, puis utilise des requêtes spécifiques pour extraire le hash NT du compte visé, sans jamais avoir altéré ou réinitialisé son mot de passe d'origine. C'est une technique extrêmement discrète.
* **Flag associé (Mémoire du TP) :** *« Je vis dans l'ombre, je suis ténébreux »* (référence directe au mécanisme Shadow Credentials).

---

## 5. Analyse de Post-Exploitation & Limites du Mouvement Latéral

### Extraction des Secrets Locaux (SAM et LSA)
Lorsqu'un accès administratif complet est obtenu sur une machine (statut Administrateur Local ou `Pwn3d!`), deux bases de stockage locales doivent être auditées :
1.  **La base SAM (Security Account Manager) :** Contient les hashs des mots de passe des comptes locaux de la machine (ex: le compte `Administrator` local).
2.  **Les secrets LSA (Local Security Authority) :** Contient des données d'infrastructure critiques, des mots de passe de comptes de services locaux, ou des configurations de comptes de machines nécessaires au fonctionnement du système d'exploitation au sein du domaine.
3.  **La Mémoire Vive (LSASS) :** Le processus `lsass.exe` gère la politique de sécurité locale et stocke temporairement des tickets Kerberos ou des hashs d'utilisateurs connectés. L'extraction de cette mémoire peut être entravée ou bloquée par des solutions de sécurité (comme Windows Defender ou la protection Credential Guard).

### Comprendre l'Architecture Défensive LAPS
Durant l'analyse d'un parc informatique, il arrive fréquemment qu'un hash d'Administrateur Local récupéré sur une machine ne fonctionne sur aucune autre machine du réseau (renvoyant une erreur de type `STATUS_LOGON_FAILURE`).
* **Le Concept :** C'est le comportement attendu d'une architecture qui implémente **LAPS** (*Local Administrator Password Solution*). LAPS automatise la rotation des mots de passe des administrateurs locaux de chaque machine et s'assure qu'ils soient tous **uniques** et aléatoires.
* **L'Impact en Sécurité :** LAPS casse net la technique classique du *Pass-The-Hash* de masse. Si un attaquant compromet un poste, le hash de l'administrateur local de ce poste ne lui permettra pas de rebondir sur les machines voisines. Il est alors contraint de repasser par des escalades de privilèges basées sur les relations Active Directory (graphes d'ACL) plutôt que sur la réutilisation de secrets locaux.
* **Flag associé (Mémoire du TP) :** *« Passe moi le sel, euh le hash »* & *« Caché dans le secret LSA »*.

---

## 6. Mécanismes de Délégation Kerberos & Résolution d'Erreurs

La délégation Kerberos est une fonctionnalité conçue pour permettre à une application multi-tiers (par exemple, un serveur Web frontal) d'agir pour le compte d'un utilisateur auprès d'un service d'arrière-plan (par exemple, une base de données SQL).

### La Délégation Contrainte (Constrained Delegation)
* **Le Fonctionnement :** Encadrée par l'attribut `msDS-AllowedToDelegateTo`, elle restreint la capacité d'usurpation d'un compte à une liste explicite de services (SPN) et de machines cibles. Elle met en œuvre deux extensions du protocole Kerberos :
  1.  **S4U2self (Service for User to Self) :** Permet à un service de demander un ticket de service au nom d'un utilisateur pour lui-même.
  2.  **S4U2proxy (Service for User to Proxy) :** Permet au service d'utiliser ce ticket pour demander un nouveau ticket de service ciblant le serveur d'arrière-plan spécifié dans les contraintes de l'AD.

### Résolution de l'Erreur `KRB_AP_ERR_BADMATCH`
Lors de l'audit ou de la manipulation des tickets via des outils d'extensions de services (comme la suite Impacket), la réception de l'erreur `KRB_AP_ERR_BADMATCH` lors de la phase *S4U2self* indique un rejet strict du Contrôleur de Domaine.

* **Les Causes Principales :**
  1.  **Divergence de type de service (SPN) :** Si l'annuaire AD autorise uniquement le compte à déléguer vers un service spécifique (par exemple `HTTP/machine.celestina.shop`), tenter de forger ou de demander un ticket pour un service différent (par exemple le protocole de fichiers `cifs/`) provoquera une non-correspondance immédiate et un rejet par le protocole.
  2.  **Formatage de l'identité :** Kerberos requiert une exactitude parfaite concernant la casse des caractères et la syntaxe des domaines. Une confusion entre le nom NetBIOS court et le nom de domaine complet (FQDN) invalide l'authenticité de la requête.

---

## 7. Guide DevSecOps : Remédiation et Durcissement AD

Pour obtenir la note maximale lors d'un TP d'évaluation ou appliquer ces principes dans un cadre d'ingénierie DevSecOps, la phase de recommandation et de remédiation est essentielle. Voici les contre-mesures structurelles à préconiser :

### Contre l'exposition de secrets en clair
* **Nettoyage de l'Annuaire :** Interdire formellement l'usage des champs `description` ou `info` pour stocker des données sensibles. Implémenter des scripts de vérification automatique réguliers pour détecter des motifs de mots de passe dans la base LDAP.
* **Gestion des Secrets Décentralisée :** Remplacer les identifiants en clair par des solutions de coffre-fort de mots de passe ou de gestion de secrets centralisée (HashiCorp Vault, AWS Secrets Manager) intégrées nativement dans les pipelines de déploiement.

### Contre les attaques Kerberos (Roasting)
* **Durcissement des Comptes de Service :** Assurer que les comptes disposant d'un SPN (Kerberoasting) utilisent des mots de passe d'une longueur supérieure à 25 caractères, ou migrer vers des **gMSA** (*Group Managed Service Accounts*), dont les mots de passe sont gérés, modifiés automatiquement par le DC et mathématiquement incassables hors-ligne.
* **Pré-authentification Obligatoire :** Auditer l'annuaire pour s'assurer qu'aucun compte actif ne possède la case "Ne pas exiger la pré-authentification Kerberos" cochée.

### Contre l'abus des ACL et des Délégations
* **Principe du Moindre Privilège :** Restreindre drastiquement l'attribution de droits critiques comme `GenericAll` ou `WriteProperty` sur les objets utilisateurs et ordinateurs. L'accès aux modifications d'attributs de sécurité doit être réservé aux seuls groupes d'administration restreints.
* **Protection des Comptes Sensibles :** Ajouter les comptes à privilèges élevés (comme les Administrateurs du Domaine) au groupe de sécurité intégrée **« Protected Users »**. Les membres de ce groupe ne peuvent pas être utilisés dans des mécanismes de délégation (contrainte ou non contrainte) et leurs secrets ne sont pas mis en cache sous des formats vulnérables en mémoire vive.
