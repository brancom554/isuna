import 'package:flutter/material.dart';

class ErrorUtils {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    bool isError = true,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onVisible,
    Color? color,
    IconData? icon,
  }) {
    // Remove any existing SnackBars
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon!),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onVisible: onVisible,
      ),
    );
  }

  // Handle specific Firebase Authentication errors
  static String getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Aucun utilisateur avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'invalid-email':
        return 'Format de mail invalide';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'La sécurité du mot de passe est trop faible';
      case 'network-request-failed':
        return 'Erreur réseau. Veuillez vérifier votre connexion internet';
      case 'too-many-requests':
        return 'Trop de tentatives de connexion. Veuillez réessayer plus tard';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'operation-not-allowed':
        return 'Méthode de connexion non autorisée';
      case 'invalid-credential':
        return 'Identifiants de connexion non valides. Veuillez vérifier et réessayer.';
      default:
        return 'Une erreur inattendue s\'est produite. Veuillez réessayer.';
    }
  }
}
