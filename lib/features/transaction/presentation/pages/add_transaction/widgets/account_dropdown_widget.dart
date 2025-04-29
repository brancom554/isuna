import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/provider/currency_provider.dart';
import '../../../../../../models/account_model.dart';

class AccountDropdownWidget extends StatelessWidget {
  final List<Account> accounts;
  final String value;
  final ValueChanged<String?> onChanged;
  final InputDecoration decoration;

  const AccountDropdownWidget({
    super.key,
    required this.accounts,
    required this.value,
    required this.onChanged,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return DropdownButtonFormField<String>(
      value: value,
      decoration: decoration,
      dropdownColor: AppTheme.cardColor, // Custom dropdown background
      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.darkTextColor,
          ),
      borderRadius: BorderRadius.circular(12),
      items: accounts.map((Account account) {
        return DropdownMenuItem<String>(
          value: account.name,
          child: Row(
            children: [
              Text(
                  '${account.name} -   ${currencyProvider.formatCurrency(account.balance)}'),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner un compte';
        }
        return null;
      },
    );
  }
}
