import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/common/custom_appbar.dart';

class TermsOfServicePage extends StatelessWidget {
  TermsOfServicePage({super.key});

  final Uri _githubUrl = Uri.parse('https://github.com/brancom554/isuna');

  // Method to launch URL
  Future<void> _launchUrl() async {
    if (!await launchUrl(_githubUrl)) {
      throw Exception('Impossible de charger $_githubUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Conditions d'utilisation"),
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
                ' Dernière mise à jour : 10 décembre 2024 \n\n'

                  'Acceptation des conditions\n\n'

                  'En téléchargeant, installant ou utilisant l\'application mobile Isuna (l\'« Application »), \n\n'
              'vous acceptez d\'être lié par ces Conditions d\'utilisation (« Conditions »). Si vous n\'êtes pas d\'accord avec ces Conditions, ne utilisez pas l\'Application.'

      'Description du service'

      'Isuna est une application mobile conçue pour aider les utilisateurs à suivre, analyser et gérer leurs informations financières.'
                'L\'Application propose des outils pour obtenir des aperçus financiers, suivre les transactions et gérer les finances personnelles.'

     ' Éligibilité des utilisateurs'

      '• L\'utilisateur doit avoir au moins 13 ans pour utiliser cette Application\n\n'
      '• L\'utilisateur doit fournir des informations exactes, actuelles et complètes lors de l\'enregistrement'
      '• L\'utilisateur est responsable du maintien de la confidentialité de son compte\n\n'

     ' Compte utilisateur '

      '• L\'utilisateur peut créer un compte en utilisant une adresse e-mail \n\n'
     ' • L\'utilisateur recevra les communications essentielles relatives à l\'Application par e-mail\n'
      ' • L\'utilisateur peut supprimer son compte à tout moment via les paramètres de l\'Application\n'

     ' Conduite et responsabilités de l\'utilisateur '

      '  En utilisant Isuna, vous acceptez de : '

     ' • Utiliser l\'Application uniquement à des fins légales '
     ' • Ne pas tenter de violer la sécurité de l\'Application'
      '• Ne pas partager les identifiants de compte '
      ' • Ne pas utiliser l\'Application pour stocker des informations financières frauduleuses ou illégales '
     ' • Respecter la confidentialité et les données des autres utilisateurs '

    '  Utilisation et protection des données '

    '  • Toutes les données des utilisateurs sont cryptées et protégées '
    '  • Nous ne vendons pas les informations financières personnelles à des tiers '
    '  • Les utilisateurs peuvent exporter ou supprimer leurs données financières à tout moment '

     ' Avertissement sur les données financières '

     ' • Isuna fournit des aperçus financiers et des outils de suivi '
    '  • L\'Application ne constitue pas un conseil financier '
    '  • Les utilisateurs doivent consulter des conseillers financiers professionnels '
    '  • Nous ne sommes pas responsables des décisions financières basées sur les informations de l\'Application '

     ' Propriété intellectuelle '

     ' • Tout le contenu et les fonctionnalités sont la propriété d\'Isuna '
     ' • Protégés par les lois sur le droit d\'auteur et la propriété intellectuelle '
     ' • Les utilisateurs ne peuvent pas reproduire ou distribuer le contenu de l\'Application sans consentement '

     ' Limitation de responsabilité '

     '   • L\'Application est fournie « en l\'état », sans garanties '
      '  • Nous ne sommes pas responsables des dommages directs ou indirects '
     ' • La responsabilité totale est limitée au montant payé pour l\'Application '

    '  Modifications des Conditions '

    '  • Nous nous réservons le droit de modifier ces Conditions '
    '  • L\'utilisation continue implique l\'acceptation des nouvelles Conditions '
     ' • Les changements importants seront communiqués par e-mail ou notification dans l\'Application '

      '  Loi applicable '

      '  Ces Conditions sont régies par les lois de notre juridiction principale, sans tenir compte des principes de conflit de lois.'

     ' Informations de contact '

      '  Pour toute question concernant ces Conditions, veuillez contacter :',




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
              const SizedBox(height: 20.0),
              Text(
                'En utilisant Isuna, vous reconnaissez avoir lu, compris et acceptez d\'être lié par ces Conditions d\'utilisation.',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
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
