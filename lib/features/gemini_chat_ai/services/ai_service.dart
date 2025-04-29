import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finlytics/features/auth/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../models/account_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/user_model.dart';

class AiService {
  final GenerativeModel _geminiModel;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AiService()
      : _geminiModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '', // Fetch from .env
        ) {
    // Ensure API key is loaded correctly
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
          'API Key not found. Please set GEMINI_API_KEY in the .env file.');
    }
  }

  Future<String> generateResponse(String query, String? userId) async {
    try {
      userId = userId ?? getCurrentUserId();
      if (userId == null) {
        return "Veuillez vous connecter pour accéder à votre assistant financier personnalisé.";
      }

      // Build context-aware query
      String enhancedQuery = await _prepareEnhancedQuery(query, userId);

      // Send query to Gemini AI
      final content = [Content.text(enhancedQuery)];
      final response = await _geminiModel.generateContent(content);

      return response.text?.trim() ?? "Je n'ai pas pu générer de réponse.";
    } catch (e) {
      print('Erreur dans generateResponse: $e');
      return "Désolé, une erreur s'est produite lors du traitement de votre demande.";
    }
  }

  String _formatTransactionsForGemini(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) return "Aucune transaction récente à afficher.";

    return transactions.map((transaction) {
      return "- ${transaction['type']} of ${transaction['amount']} in ${transaction['category']} on ${transaction['date']}";
    }).join('\n');
  }

  Future<void> handleSpecificIntents(String query, String response) async {
    query = query.toLowerCase();
    String? userId = getCurrentUserId();
    if (userId == null) return;

    try {
      if (query.contains("add transaction")) {
        await _extractAndAddTransaction(response);
      } else if (query.contains("savings tip") ||
          query.contains("reduce expense")) {
        await _logFinancialAdvice(userId, response);
      }
    } catch (e) {
      print('Erreur dans handleSpecificIntents: $e');
    }
  }

  Future<void> _extractAndAddTransaction(String response) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    RegExp amountRegex = RegExp(r'?(\d+(\.\d+)?)');
    RegExp categoryRegex = RegExp(r'(Expense|Income)', caseSensitive: false);

    double amount =
        double.tryParse(amountRegex.firstMatch(response)?.group(1) ?? '0') ??
            0.0;
    String type = categoryRegex.firstMatch(response)?.group(1) ?? 'Expense';
    String category = _inferCategory(response);

    final transaction = TransactionModel(
      id: '',
      userId: user.uid,
      amount: amount,
      type: type,
      category: category,
      details: response,
      account: 'Main',
      havePhotos: false,
    );

    await _firestore.collection('transactions').add(transaction.toDocument());
    await _updateAccountBalance('Main', type == 'Expense' ? -amount : amount);
  }

  String _inferCategory(String response) {
    final categoryMap = {
      'food': 'Food & Dining',
      'grocery': 'Groceries',
      'travel': 'Transportation',
      'bill': 'Utilities',
      'shopping': 'Shopping',
      'movie': 'Entertainment',
    };

    for (var entry in categoryMap.entries) {
      if (response.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    return 'Other';
  }

  Future<void> _logFinancialAdvice(String userId, String advice) async {
    await _firestore.collection('financial_advice').add({
      'userId': userId,
      'advice': advice,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<List<Map<String, dynamic>>> fetchRecentTransactions(
      String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des transactions: $e');
      return [];
    }
  }

  Future<void> _updateAccountBalance(String accountName, double amount) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      UserModel userModel = UserModel.fromDocument(userDoc);
      Account? accountToUpdate = userModel.accounts.firstWhere(
        (account) => account.name == accountName,
        orElse: () => Account(name: accountName, balance: 0),
      );

      accountToUpdate.balance += amount;

      await userRef.update({
        'accounts':
            userModel.accounts.map((account) => account.toMap()).toList()
      });
    }
  }

  Future<Map<String, dynamic>> calculateFinancialMetrics(String userId) async {
    try {
      // Fetch user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return {'error': 'Utilisateur introuvable'};
      }

      UserModel userModel = UserModel.fromDocument(userDoc);

      // Fetch transactions
      List<Map<String, dynamic>> transactions =
          await fetchRecentTransactions(userId);

      // Calculate total balance across all accounts
      double totalBalance = userModel.totalBalance;

      // Income and Expense Calculations
      double totalIncome = 0.0;
      double totalExpenses = 0.0;
      Map<String, double> categoryExpenses = {};

      for (var transaction in transactions) {
        double amount = transaction['amount'] ?? 0.0;
        String type = transaction['type'] ?? '';
        String category = transaction['category'] ?? 'Uncategorized';

        if (type == 'Income') {
          totalIncome += amount;
        } else if (type == 'Expense') {
          totalExpenses += amount;
          categoryExpenses[category] =
              (categoryExpenses[category] ?? 0) + amount;
        }
      }

      // Calculate Savings Rate
      double savingsRate = totalIncome > 0
          ? ((totalIncome - totalExpenses) / totalIncome * 100)
              .clamp(0.0, 100.0)
          : 0.0;

      // Net Worth Calculation ( totalBalance represents liquid assets)
      double netWorth = totalBalance;

      // Expense Breakdown by Category
      List<Map<String, dynamic>> expenseBreakdown = categoryExpenses.entries
          .map((entry) => {
                'category': entry.key,
                'amount': entry.value,
                'percentage':
                    (entry.value / totalExpenses * 100).toStringAsFixed(2)
              })
          .toList();

      // Financial Health Score
      double financialHealthScore = _calculateFinancialHealthScore(
          savingsRate: savingsRate,
          expenseRatio: totalExpenses / totalIncome,
          balanceToIncomeRatio:
              totalBalance / (totalIncome > 0 ? totalIncome : 1));

      return {
        'totalBalance': totalBalance,
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'savingsRate': savingsRate.toStringAsFixed(2),
        'netWorth': netWorth,
        'expenseBreakdown': expenseBreakdown,
        'financialHealthScore': financialHealthScore.toStringAsFixed(2),
        'largestExpenseCategory': _findLargestExpenseCategory(categoryExpenses),
      };
    } catch (e) {
      print('Erreur lors du calcul des indicateurs financiers: $e');
      return {'error': 'Impossible de calculer les paramètres financiers'};
    }
  }

  // Helper method to find the largest expense category
  String _findLargestExpenseCategory(Map<String, double> categoryExpenses) {
    if (categoryExpenses.isEmpty) return 'Aucune dépense';

    return categoryExpenses.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Calculate a basic financial health score
  double _calculateFinancialHealthScore({
    required double savingsRate,
    required double expenseRatio,
    required double balanceToIncomeRatio,
  }) {
    // Base score components (0-100)
    double savingsScore = (savingsRate * 1.0).clamp(0.0, 40.0);

    // Lower expense ratio is better (aim for < 0.7)
    double expenseScore = expenseRatio < 0.7
        ? (40 * (1 - expenseRatio / 0.7)).clamp(0.0, 40.0)
        : 0.0;

    // Balance to income ratio (aim for > 0.5)
    double balanceScore = (balanceToIncomeRatio * 20).clamp(0.0, 20.0);

    return savingsScore + expenseScore + balanceScore;
  }

  Future<String> _prepareEnhancedQuery(
      String originalQuery, String userId) async {
    final userService = UserService();
    final userProfile = await userService.getUserById(userId);

    if (userProfile == null) {
      throw Exception('Utilisateur non trouvé');
    }
    List<Map<String, dynamic>> recentTransactions =
        await fetchRecentTransactions(userId);
    Map<String, dynamic> financialMetrics =
        await calculateFinancialMetrics(userId);

    String transactionsContext =
        _formatTransactionsForGemini(recentTransactions);
    String metricsContext = _formatMetricsForGemini(financialMetrics);
    String username = userProfile.username;

    return """
  Vous êtes IsunaAI, assistant financier personnel. Vos capacités incluent:
1. Analyser les transactions et les habitudes de dépenses
2. Fournir des conseils budgétaires basés sur l'historique de dépenses
3. Suivre les indicateurs financiers et expliquer leur signification
4. Proposer des solutions pour améliorer ses habitudes financières en fonction des données de transactions
5. Gérer les comptes et leurs soldes

Informations utilisateur actuelles:
  - Nom d'utilisateur: $username
  - Hstorique des transactions : ${transactionsContext.isEmpty ? "Aucune transaction récente trouvée." : transactionsContext}
  - Aperçu financier : ${metricsContext.isEmpty ? "Aucune mesure financière disponible." : metricsContext}

 Consignes de style:
- Se concentrer uniquement sur les fonctionnalités disponibles dans l'application
- Fournir des conseils précis en fonction de l'historique des transactions et des indicateurs
- Répondre de manière concise et exploitable
- Ne pas suggérer de fonctionnalités ou d'actions non prises en charge par l'application

  Demande de l'utilisateur: "$originalQuery"

  Fournissez une réponse qui:
1. Répond directement à la question de l'utilisateur
2. Utilise ses données financières lorsque cela est pertinent
3. Suggère uniquement des actions réalisables dans l'application
4. Est spécifique à sa situation financière
  """;
  }

  // Format financial metrics for Gemini context
  String _formatMetricsForGemini(Map<String, dynamic> metrics) {
    if (metrics.containsKey('error')) return '';

    return '''
    Aperçu financier:
    - Solde total: \$${metrics['totalBalance'].toStringAsFixed(2)}
    - Revenu total: \$${metrics['totalIncome'].toStringAsFixed(2)}
    - Dépenses totales: \$${metrics['totalExpenses'].toStringAsFixed(2)}
    - Taux d'épargne: ${metrics['savingsRate']}%
    - Valeur nette: \$${metrics['netWorth'].toStringAsFixed(2)}
    - Score de santé financière: ${metrics['financialHealthScore']}/100
    - Catégorie de dépenses la plus importante: ${metrics['largestExpenseCategory']}
    ''';
  }

  // Additional method to provide AI-powered financial recommendations
  Future<String> generateFinancialRecommendations(String userId) async {
    try {
      Map<String, dynamic> metrics = await calculateFinancialMetrics(userId);

      if (metrics.containsKey('error')) {
        return "Impossible de générer des recommandations pour le moment.";
      }

      final content = [
        Content.text("""
        Sur la base des indicateurs financiers suivants :
        - Taux d'épargne: ${metrics['savingsRate']}%
        - Dépense totale: \$${metrics['totalExpenses']}
        - Catégorie de dépenses la plus importante: ${metrics['largestExpenseCategory']}
        - Score de santé financière: ${metrics['financialHealthScore']}/100

        Fournir 3 à 5 recommandations financières personnalisées et exploitables pour améliorer la santé financière.
        """)
      ];

      final response = await _geminiModel.generateContent(content);
      return response.text?.trim() ?? "Aucune recommandation disponible.";
    } catch (e) {
      print('Erreur lors de la génération des recommandations financières: $e');
      return "Désolé, une erreur s'est produite lors de la génération des recommandations.";
    }
  }
}
