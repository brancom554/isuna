import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/provider/currency_provider.dart';
import '../../../../models/account_model.dart';
import 'custom_text_field.dart';

class AccountsDialog extends StatefulWidget {
  final List<Account> accounts;
  final Function(String, double) onAddAccount;
  final Function(String, double) onUpdateBalance;
  final Function(Account) onSelectAccount;
  final Function(String) onRenameAccount;
  final Function(String) onDeleteAccount;
  final VoidCallback onSelectTotalBalance;
  final Account? selectedAccount;

  const AccountsDialog({
    super.key,
    required this.accounts,
    required this.onAddAccount,
    required this.onUpdateBalance,
    required this.onSelectAccount,
    required this.onRenameAccount,
    required this.onDeleteAccount,
    required this.onSelectTotalBalance,
    this.selectedAccount,
  });

  @override
  _AccountsDialogState createState() => _AccountsDialogState();
}

class _AccountsDialogState extends State<AccountsDialog> {
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _renameController = TextEditingController();
  bool _showAddAccountFields = false;
  String _errorMessage = "";
  final _formKey = GlobalKey<FormState>();
  final _renameFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _accountNameController.dispose();
    _balanceController.dispose();
    _renameController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (_formKey.currentState?.validate() ?? false) {
      final accountName = _accountNameController.text.trim();
      final balance = double.parse(_balanceController.text.trim());

      final accountExists = widget.accounts.any(
          (account) => account.name.toLowerCase() == accountName.toLowerCase());

      if (accountExists) {
        setState(() {
          _errorMessage = 'Un compte avec le même nom existe déjà !';
        });
        return;
      }

      if (widget.accounts.length >= 5) {
        setState(() {
          _errorMessage = 'Impossible d\'ajouter plus de 5 comptes';
        });
        return;
      }

      widget.onAddAccount(accountName, balance);
      _accountNameController.clear();
      _balanceController.clear();
      setState(() {
        _showAddAccountFields = false;
        _errorMessage = "";
      });
    }
  }

  void _showRenameAccountDialog(Account account) {
    _renameController.text = account.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: AppTheme.cardColor,
        title: Text(
          'Renommer le compte',
          style: AppTheme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: _renameFormKey,
          child: CustomTextField(
            controller: _renameController,
            labelText: 'Nouveau nom de compte',
            prefixIcon: Icons.drive_file_rename_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom du compte ne peut pas être vide';
              }
              if (value.length > 50) {
                return 'Nom du compte trop long';
              }
              final nameExists = widget.accounts.any((a) =>
                  a.name.toLowerCase() == value.trim().toLowerCase() &&
                  a.name.toLowerCase() != account.name.toLowerCase());
              if (nameExists) {
                return 'Le nom du compte existe déjà';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_renameFormKey.currentState?.validate() ?? false) {
                widget.onRenameAccount(_renameController.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Renommer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: AppTheme.cardColor,
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppTheme.errorColor),
            const SizedBox(width: 10),
            Text(
              'Supprimer le compte',
              style: AppTheme.textTheme.displayMedium?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le compte "${account.name}"? Cette action ne peut pas être annulée.',
          style: AppTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              widget.onDeleteAccount(account.name);
              Navigator.of(context).pop();
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showUpdateBalanceDialog(Account account) {
    _balanceController.text = account.balance.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: AppTheme.cardColor,
        title: Text(
          'Mettre à jour le solde',
          style: AppTheme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mettre à jour le solde pour ${account.name}',
              style: AppTheme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Form(
              key: GlobalKey<FormState>(),
              child: CustomTextField(
                controller: _balanceController,
                labelText: 'Nouveau solde',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un solde';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Montant du solde invalide';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final newBalance =
                  double.tryParse(_balanceController.text.trim());
              if (newBalance != null) {
                widget.onUpdateBalance(account.name, newBalance);
                _balanceController.clear();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: AppTheme.cardColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Gestion de comptes',
            style: AppTheme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.primaryColor),
            onPressed: () {
              _showAccountManagementHelp();
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: widget.selectedAccount == null
                      ? const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryDarkColor
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey[700]!, Colors.grey[800]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: widget.onSelectTotalBalance,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Solde total',
                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyProvider.formatCurrency(
                                  widget.accounts.fold(
                                    0.0,
                                    (sum, account) => sum + account.balance,
                                  ),
                                ),
                                style: AppTheme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Accounts List
              ...widget.accounts.map((account) {
                bool isSelected = account == widget.selectedAccount;
                return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryDarkColor
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Colors.white, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () => widget.onSelectAccount(account),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.name,
                                        style: AppTheme.textTheme.bodyLarge
                                            ?.copyWith(
                                          color:
                                              isSelected ? Colors.white : null,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currencyProvider
                                            .formatCurrency(account.balance),
                                        style: AppTheme.textTheme.bodyLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.primaryColor,
                                  ),
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit_balance':
                                        _showUpdateBalanceDialog(account);
                                        break;
                                      case 'rename':
                                        _showRenameAccountDialog(account);
                                        break;
                                      case 'delete':
                                        _showDeleteAccountConfirmation(account);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit_balance',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.edit,
                                            color: AppTheme.primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Mettre à jour le solde',
                                            style:
                                                AppTheme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'rename',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.drive_file_rename_outline,
                                            color: AppTheme.primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Renommer le compte',
                                            style:
                                                AppTheme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete,
                                            color: AppTheme.errorColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Supprimer le compte',
                                            style: AppTheme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: AppTheme.errorColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )));
              }),

              const SizedBox(height: 16),

              // Add Account Section with Improved Design
              if (_showAddAccountFields)
                Column(
                  children: [
                    CustomTextField(
                      controller: _accountNameController,
                      labelText: 'Nom du compte',
                      prefixIcon: Icons.account_circle,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom du compte ne peut pas être vide';
                        }
                        if (value.length > 50) {
                          return 'Nom du compte trop long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _balanceController,
                      labelText: 'Solde initial',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le solde ne peut pas être vide';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Montant du solde invalide';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        // Dynamic Action Buttons
        TextButton.icon(
          icon: Icon(
            _showAddAccountFields ? Icons.close : Icons.add,
            color: AppTheme.primaryColor,
          ),
          label: Text(
            _showAddAccountFields ? 'Annuler' : 'Ajouter un compte',
            style: const TextStyle(color: AppTheme.primaryColor),
          ),
          onPressed: () {
            setState(() {
              _showAddAccountFields = !_showAddAccountFields;
              _errorMessage = "";
            });
          },
        ),
        if (_showAddAccountFields)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: _saveAccount,
            child: const Text('Enregistrer le compte'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }

  void _showAccountManagementHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: AppTheme.cardColor,
        title: Text(
          'Aide à la gestion de compte',
          style: AppTheme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpSection(
                'Ajouter un compte',
                'Cliquez sur «Ajouter un compte» pour créer un nouveau compte. Vous pouvez en créer jusqu\'à cinq.',
                Icons.add_circle_outline,
              ),
              _buildHelpSection(
                'Modifier le solde',
                'Utilisez le menu à trois points pour mettre à jour le solde d\'un compte à tout moment.',
                Icons.edit,
              ),
              _buildHelpSection(
                'Renommer le compte',
                'Renommez facilement vos comptes grâce au menu à trois points. Assurez-vous d\'utiliser des noms de compte uniques.',
                Icons.drive_file_rename_outline,
              ),
              _buildHelpSection(
                'Supprimer le compte',
                'Supprimez les comptes dont vous n\'avez plus besoin. Les comptes supprimés ne peuvent pas être récupérés.',
                Icons.delete_forever,
              ),
              _buildHelpSection(
                'Solde total',
                'La vignette supérieure affiche le solde cumulé de tous vos comptes. Appuyez pour afficher plus de détails.',
                Icons.account_balance_wallet,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Helper method to build help sections
  Widget _buildHelpSection(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
