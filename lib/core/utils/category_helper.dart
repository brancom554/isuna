import 'package:flutter/material.dart';

class CategoryHelper {
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Nourriture':
        return Icons.fastfood;
      case 'Factures':
        return Icons.receipt;
      case 'Transport':
        return Icons.directions_car;
      case 'Achat':
        return Icons.shopping_cart;
      case 'Divertissement':
        return Icons.movie;
      case 'Salaire':
        return Icons.attach_money;
      case 'Freelance':
        return Icons.work;
      case 'Investissements':
        return Icons.trending_up;
      case 'Location':
        return Icons.home;
      case 'Dépenses courantes':
        return Icons.electrical_services;
      case 'Santé':
        return Icons.health_and_safety;
      case 'Education':
        return Icons.school;
      case 'Dons':
        return Icons.card_giftcard;
      case 'Autres':
        return Icons.category;
      default:
        return Icons.help_outline;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Nourriture':
        return Colors.orange.shade300;
      case 'Factures':
        return Colors.purple.shade300;
      case 'Transport':
        return Colors.teal.shade300;
      case 'Achat':
        return Colors.green.shade300;
      case 'Divertissement':
        return Colors.cyan.shade300;
      case 'Salaire':
        return Colors.green.shade400;
      case 'Freelance':
        return Colors.blue.shade300;
      case 'Investissements':
        return Colors.indigo.shade300;
      case 'Location':
        return Colors.brown.shade300;
      case 'Dépenses courantes':
        return Colors.deepPurple.shade300;
      case 'Santé':
        return Colors.red.shade300;
      case 'Education':
        return Colors.amber.shade300;
      case 'Dons':
        return Colors.pink.shade300;
      case 'Autres':
        return Colors.blueGrey.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  static List<String> getAllCategories() {
    return [
      'Nourriture',
      'Factures',
      'Transport',
      'SAchat',
      'EDivertissement',
      'Salaire',
      'Freelance',
      'Investissements',
      'Location',
      'Dépenses courantes',
      'Santé',
      'Education',
      'Dons',
      'Autres'
    ];
  }
}
