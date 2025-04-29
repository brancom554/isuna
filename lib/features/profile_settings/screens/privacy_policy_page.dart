import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/common/custom_appbar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  PrivacyPolicyPage({super.key});

  final Uri _githubUrl = Uri.parse('https://github.com/amandangol/finlytics');

  // Method to launch URL
  Future<void> _launchUrl() async {
    if (!await launchUrl(_githubUrl)) {
      throw Exception('Could not launch $_githubUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Politique de confidentialité"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Isuna',
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Dernière mise à jour : 10 décembre 2024\n'
                    'Bienvenue sur Isuna. Cette politique de confidentialité décrit comment nous collectons, utilisons, protégeons et partageons vos informations personnelles lorsque vous utilisez notre application de suivi financier et d\'analyse.\n'
              'Interprétation et définitions\n'
              'Définitions :\n'
              '• Application : application mobile Isuna\n'
              '• Données personnelles : informations pouvant vous identifier\n'
              '• Données d\'utilisation : informations collectées automatiquement sur l\'utilisation de l\'application\n'
              'Types de données collectées\n'
              'Données personnelles :\n'
              '• Adresse e-mail\n'
              '• Informations de profil\n'
              '• Détails des transactions financières\n'
              'Données d\'utilisation :\n'
              '• Informations sur l\'appareil\n'
              '• Adresse IP\n'
              '• Statistiques d\'utilisation de l\'application\n'
              '• Journaux de performance\n'
              'Comment nous utilisons vos informations\n'
              'Nous utilisons vos données pour :\n'
              '• Fournir et améliorer les services de l\'application\n'
              '• Générer des aperçus financiers\n'
              '• Personnaliser l\'expérience utilisateur\n'
              '• Envoyer des notifications importantes de l\'application\n'
              '• Assurer la sécurité de l\'application\n'
              'Protection des données\n'
              '• Nous mettons en œuvre des mesures de sécurité robustes\n'
              '• Toutes les données sensibles sont cryptées\n'
              '• Nous ne vendons pas d\'informations personnelles\n'
              'Droits des utilisateurs\n'
              '• Droit d\'accéder à vos données\n'
              '• Droit de supprimer votre compte\n'
              '• Option de vous désinscrire des analyses\n'
              'Confidentialité des enfants\n'
              'Isuna n\'est pas destiné aux enfants de moins de 13 ans. Nous ne collectons pas intentionnellement des données provenant d\'enfants.\n'
                'Modifications de la politique de confidentialité\n'
                'Nous pouvons mettre à jour cette politique périodiquement. L\'utilisation continue de l\'application implique l\'acceptation des termes mis à jour.\n'
                'Contactez-nous\n'
                'Pour toute question relative à la confidentialité, veuillez nous contacter :\n'
              ,
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: _launchUrl,
                child: const Text(
                  'Projet Isuna',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Email: contact@owd-express.com',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
