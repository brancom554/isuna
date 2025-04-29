Isuna : Votre compagnon complet de gestion financière personnelle 💰
🌟 Présentation
Isuna est une application Flutter avancée, propulsée par l'IA, conçue pour transformer la gestion des finances personnelles. En combinant technologie de pointe et design intuitif, Isuna offre aux utilisateurs une solution globale pour suivre, analyser et optimiser leur santé financière.

Téléchargez l'APK pour Android ici :
Isuna APK

🚀 Fonctionnalités principales
1. Tableau de bord financier complet
Aperçus financiers interactifs

Multiples options de visualisation pour une analyse financière approfondie

Filtrage dynamique des transactions sur différentes périodes

Indicateurs de performance détaillés et représentations visuelles

https://???

2. Suivi avancé des dépenses
Gestion transparente des transactions

Ajouter, modifier et supprimer des transactions facilement

Prise en charge de plusieurs comptes

Catégorisation détaillée des transactions

Validation intelligente

Validation intelligente des dépenses

Vérifications du solde en temps réel

Mécanismes de prévention des découverts

https://???

3. Visualisation puissante des données
Capacités de graphiques avancées

Graphique à barres Revenus vs Dépenses

Graphique linéaire des transactions mensuelles

Visualisation de la répartition par catégorie

Fonctionnalités interactives

Mises à jour des graphiques en temps réel

Indicateurs colorés pour une compréhension instantanée

Design réactif pour tous les appareils

https://???

4. Assistant financier propulsé par l'IA
Intégration de Gemini AI

Conseils financiers personnalisés

Analyse intelligente des transactions

Recommandations basées sur les habitudes de dépenses

Prédictions financières

Prévision des dépenses futures

Suggestions pour optimiser l’épargne

Évaluation complète de la santé financière

https://???

5. Personnalisation du format de la devise
Affichage personnalisé des devises

Visualisez soldes et transactions dans le format de devise de votre choix

Prise en charge de divers formats régionaux de nombre et de devise

https://???

Rapports financiers améliorés

Rapports personnalisés avec options d'affichage de la devise

Formatage cohérent pour une meilleure lisibilité

Paramètres conviviaux

Configuration facile des préférences de format de devise

6. Authentification sécurisée et confidentialité
Sécurité alimentée par Firebase

Authentification robuste des utilisateurs

Stockage sécurisé des données

Processus de connexion et d'inscription simplifiés

📊 Indicateurs financiers complets
Isuna suit et analyse les indicateurs financiers clés :

Revenus totaux

Dépenses totales

Solde net

Taux d’épargne

Catégories de revenus/dépenses les plus élevées

Analyse du patrimoine net

🛠 Architecture technique
Pile technologique
Framework Frontend : Flutter

Services Backend :

Firebase Firestore (persistance des données)

Firebase Authentication

Firebase Storage

Intégration IA : Google Gemini

Visualisation : Bibliothèque FL Chart

Utilitaires : Package Intl pour la gestion des dates

Points techniques importants
Compatibilité multiplateforme

Interface utilisateur réactive et adaptative

Animations et transitions fluides

Gestion complète des erreurs

Système de design basé sur les dégradés

📱 Fonctionnalités principales
Gestion des transactions
Prise en charge des revenus et dépenses

Validation du solde en temps réel

Prévention des découverts potentiels

Interface animée et conviviale

Champs de saisie des transactions
Montant (avec validation numérique)

Description détaillée de la transaction

Sélection flexible de la date

Basculement du type de transaction

Sélection de la catégorie

Prise en charge multi-comptes

🔍 Fonctionnalités uniques
Entrée vocale pour l'assistant financier IA

Suggestions de requêtes financières prédéfinies

Personnalisation du profil

Gestion sécurisée des comptes

🛠 Guide complet d'installation
1. Prérequis
Logiciels nécessaires
Flutter SDK (dernière version stable)

Dart SDK (inclus avec Flutter)

Android Studio ou Visual Studio Code

Git

Android SDK

Comptes nécessaires
Compte Google Cloud Platform

Compte Firebase

Compte Google AI Studio (pour l'API Gemini)

2. Configuration de l'environnement de développement
Installer Flutter
Télécharger Flutter SDK depuis le site officiel :


https://docs.flutter.dev/get-started/install
Ajouter Flutter au PATH système


export PATH="$PATH:[CHEMIN_DU_RÉPERTOIRE_FLUTTER_GIT]/flutter/bin"
Vérifier l'installation de Flutter


flutter doctor
Installer Android Studio ou VS Code
Installer les plugins Flutter et Dart

3. Configuration Firebase
Créer un projet Firebase
Accédez à la console Firebase : https://console.firebase.google.com/

Cliquez sur "Ajouter un projet"

Entrez le nom du projet : "Isuna"

Activez Google Analytics (recommandé)

Configurer Firebase pour Flutter
Dans la console Firebase, cliquez sur "Ajouter une application"

Sélectionnez la plateforme Flutter/Android

Enregistrez l'application avec le nom de package (ex : com.Isuna.app)

Téléchargez google-services.json

Placez google-services.json dans le dossier android/app/

Services Firebase à activer
Authentification

Base de données Firestore

Stockage Firebase

Firebase Cloud Messaging (optionnel)

4. Configuration de la clé API Gemini
Obtenir la clé API Google AI Studio
Rendez-vous sur : https://makersuite.google.com/app/apikey

Cliquez sur "Créer une clé API"

Copiez la clé API générée

Créer la configuration de l'environnement
Créez un fichier .env à la racine du projet :


GEMINI_API_KEY=votre_clé_api_gemini_ici
Ajoutez .env dans .gitignore pour éviter de le commettre accidentellement :


.env
Installez le package flutter_dotenv


flutter pub add flutter_dotenv
Configurez-le dans main.dart


import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
5. Dépendances du projet
Installer les dépendances
bash
Copier
Modifier
flutter pub get
Générer les fichiers requis
bash
Copier
Modifier
flutter pub run build_runner build
6. Lancer l'application
Configuration Android
Connecter un appareil Android ou démarrer un émulateur

Activer le débogage USB sur l'appareil

Exécuter l'application :

bash
Copier
Modifier
flutter run
7. Résolution des problèmes
Problèmes fréquents
Vérifier que toutes les dépendances Flutter sont installées (flutter doctor)

Vérifier la configuration Firebase

Vérifier les autorisations de la clé API

Mettre à jour les SDK Flutter et Dart

Débogage
bash
Copier
Modifier
flutter doctor -v
9. Bonnes pratiques de sécurité
Ne jamais commettre de clés API ou d'informations sensibles

Utiliser des variables d'environnement

Activer les règles de sécurité Firebase

Mettre en place une authentification appropriée

🔒 Règles de sécurité Firebase recommandées
Ajouter dans firestore.rules :


rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /transactions/{transactionId} {
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow read, update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
📝 Notes
Version Android minimale : 6.0

Version iOS minimale : 12.0

Connexion Internet stable requise

Bon codage ! 🚀

