import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/user_model.dart';

class WelcomeCard extends StatelessWidget {
  final UserModel userModel;
  final double totalIncome;
  final double totalExpense;
  final bool isDarkMode;
  final VoidCallback? onToggleDarkMode;

  const WelcomeCard({
    super.key,
    required this.userModel,
    required this.totalIncome,
    required this.totalExpense,
    this.isDarkMode = false,
    this.onToggleDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppTheme.darkTheme.cardColor.withOpacity(0.8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Username
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userModel.username.isNotEmpty
                              ? '${userModel.username}!'
                              : 'User!',
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person_outline,
                      color:
                          isDarkMode ? Colors.white70 : AppTheme.primaryColor,
                      size: 35,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Financial Insights
              Text(
                _getInsightText(),
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.7),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.1, end: 0, duration: 600.ms),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour';
    } else if (hour < 17) {
      return 'Bon apres-midi';
    } else {
      return 'Bonsoir';
    }
  }

  String _getInsightText() {
    double netIncome = totalIncome - totalExpense;
    if (netIncome > 0) {
      return 'Superbe! Vous êtes économe.';
    } else if (netIncome == 0) {
      return 'Budget trop juste. Continuez de suivre vos dépenses.';
    } else {
      return 'Il semble que vos dépenses soient très élevées. C\'est le temps de revoir votre budget.';
    }
  }
}
