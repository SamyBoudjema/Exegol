# Énoncé du TP : Audit de Sécurité Active Directory - Celestina

## 📝 Contexte de la Mission
Vous intervenez en tant qu'auditeur de sécurité pour l'entreprise **Celestina**. L'équipe d'administration système a récemment déployé une nouvelle infrastructure Active Directory et souhaite que vous en évaluiez la robustesse avant le passage en production. 

L'entreprise applique des concepts de développement DevSecOps, mais soupçonne que des erreurs de configuration ont pu se glisser lors du déploiement automatisé. Votre objectif est de compromettre le domaine, d'identifier les chemins d'attaque et de récupérer les différents "flags" disséminés dans l'infrastructure pour prouver l'impact des vulnérabilités.

## 🎯 Périmètre et Informations Techniques
* **Domaine cible :** `celestina.shop`
* **Réseau cible (Subnet) :** `10.13.37.0/24`
* **Contrôleur de Domaine (DC) :** `10.13.37.42` (`DC-CELESTINA`)
* **Format des flags :** Les flags sont au format standard ou représentent la compromission d'un objectif précis.

---

## 🚩 Liste des Challenges / Objectifs à valider

### Phase 1 : Reconnaissance et OSINT Interne
* **[100 pts] Le goût par défaut est le meilleur goût**
  * *Description :* L'équipe IT a laissé traîner un document de déploiement. Saurez-vous trouver le point d'entrée ?
* **[100 pts] Décrivez précisement, mais pas trop**
  * *Indice :* Certains champs feraient mieux de ne pas être touchés si c'est pour faire fuiter des informations sensibles.
* **[100 pts] Un secret trop partagé n'est plus secret**
  * *Indice :* Le problème est que n'importe qui sur le domaine peut le trouver et le lire.

### Phase 2 : Attaques de Protocoles (Kerberos)
* **[100 pts] Un café vraiment pas sécurisé**
  * *Description :* Certains utilisateurs n'aiment pas prouver qui ils sont avant de demander un accès.
* **[100 pts] CAAS ou Café as a service**
  * *Description :* Les comptes de service sont souvent des cibles de choix.

### Phase 3 : Mouvement Latéral & Post-Exploitation
* **[200 pts] Passe moi le sel, euh le hash**
  * *Description :* Une fois administrateur local, le réseau s'ouvre à vous. Attention aux mots de passe réutilisés !
* **[100 pts] Caché dans le secret LSA**
  * *Description :* Les secrets les plus précieux sont parfois gardés en mémoire.
* **[100 pts] Un RDP non-nécessaire**
  * *Indice :* Puisque ce n'est pas obligatoire, pourquoi l'as-tu fait ?

### Phase 4 : Abus des Configurations Avancées
* **[400 pts] Je vis dans l'ombre, je suis ténébreux**
  * *Description :* Un droit d'écriture mal placé sur un objet peut mener à une usurpation d'identité totale et furtive.
* **[400 pts] Libéré, délivré, non contraint**
  * *Description :* La délégation est un outil puissant, mais mal configurée, elle permet de se faire passer pour le roi.
* **[??? pts] Environnement en perpétuel changement / Cible acquise...**
  * *Indice :* Avez-vous promené le chien récemment ?
