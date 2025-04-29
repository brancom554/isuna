import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/common/custom_appbar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/provider/currency_provider.dart';
import '../../../../models/transaction_model.dart';
import '../../../../models/user_model.dart';

class FinancialInsightsPage extends StatefulWidget {
  final List<TransactionModel> allTransactions;
  final String userId;
  final UserModel userModel;
  const FinancialInsightsPage({
    super.key,
    required this.allTransactions,
    required this.userId,
    required this.userModel,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FinancialInsightsPageState createState() => _FinancialInsightsPageState();
}

class _FinancialInsightsPageState extends State<FinancialInsightsPage>
    with SingleTickerProviderStateMixin {
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  bool _isLoading = true;
  String _selectedPeriod = 'Overall';
  DateTimeRange? _customDateRange;
  String _selectedChartType = 'Expense';

  // Animation controller for smooth transitions
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _transactions = widget.allTransactions;
        _filteredTransactions = _transactions;
        _isLoading = false; // Mark loading as complete
      });
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _filterTransactions(String period) {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day, 0, 0, 0, 1);

    switch (period) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        startDate = startDate.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'Custom':
        if (_customDateRange != null) {
          startDate = _customDateRange!.start;
          setState(() {
            _filteredTransactions = _transactions.where((transaction) {
              DateTime transactionDate = transaction.date.toDate();
              return transactionDate.isAfter(startDate) &&
                  transactionDate.isBefore(_customDateRange!.end
                      .add(const Duration(hours: 23, minutes: 59)));
            }).toList();
          });
          return;
        } else {
          startDate = DateTime(1970);
        }
        break;
      default:
        startDate = DateTime(1970);
    }

    setState(() {
      _selectedPeriod = period;
      _filteredTransactions = _transactions
          .where((transaction) => transaction.date.toDate().isAfter(startDate))
          .toList();
    });
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFEF6C06),
              primary: const Color(0xFFEF6C06),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _customDateRange) {
      setState(() {
        _customDateRange = picked;
        _selectedPeriod = 'Custom';
        _filterTransactions('Custom');
      });
    }
  }

  void _toggleChartType() {
    setState(() {
      _selectedChartType =
          _selectedChartType == 'Expense' ? 'Income' : 'Expense';

      // Reset and forward the animation more gently
      _animationController.reset();
      _animationController.forward();
    });
  }

  Color _getCategoryColor(String category) {
    final categoryColors = {
      'Food': const Color(0xFFFFD507),
      'Bills': Colors.purpleAccent,
      'Transport': Colors.pink,
      'Shopping': Colors.green,
      'Entertainment': Colors.cyan,
      'Other': const Color(0xFFEF6C06),
    };
    return categoryColors[category] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: SpinKitThreeBounce(
            color: AppTheme.primaryDarkColor,
            size: 20.0,
          ),
        ),
      );
    }
    if (_transactions.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBar(title: "Perspectives financières"),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.money_off_outlined,
                color: Colors.grey.shade400,
                size: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune donnée financière disponible',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 18,
                ),
              ),
              Text(
                'Ajoutez quelques transactions pour voir des informations',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 184, 220, 245),
      appBar: const CustomAppBar(title: "Perspectives financières"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 230, 236, 241),
              Color.fromARGB(255, 220, 239, 225),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompactSummaryCard(),
            // Filter Section
            _buildFilterSection(),
            // Expandable Charts Content
            Expanded(
              child: _buildChartsContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Period Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...['Overall', 'Today', 'This Week', 'This Month', 'This Year']
                    .map((period) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(period),
                            selected: _selectedPeriod == period,
                            onSelected: (_) => _filterTransactions(period),
                            selectedColor: AppTheme.primaryLightColor,
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: _selectedPeriod == period
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: _selectedPeriod == period
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        )),
                IconButton(
                  icon: const Icon(
                    Icons.calendar_today,
                    color: AppTheme.primaryLightColor,
                  ),
                  onPressed: () => _selectCustomDateRange(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Chart Type Toggle
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedChartType != 'Expense') _toggleChartType();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedChartType == 'Expense'
                        ? Colors.redAccent
                        : Colors.grey[300],
                    foregroundColor: _selectedChartType == 'Expense'
                        ? Colors.white
                        : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Expense'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedChartType != 'Income') _toggleChartType();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedChartType == 'Income'
                        ? Colors.green
                        : Colors.grey[300],
                    foregroundColor: _selectedChartType == 'Income'
                        ? Colors.white
                        : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Income'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateSummaryMetrics() {
    if (_filteredTransactions.isEmpty) {
      return {
        'totalIncome': 0.0,
        'totalExpense': 0.0,
        'netBalance': widget.userModel.totalBalance,
        'savingsRate': 0.0,
        'highestIncome': 0.0,
        'highestExpense': 0.0,
        'highestIncomeCategory': 'N/A',
        'highestExpenseCategory': 'N/A',
        'incomeCategories': <String, double>{},
        'expenseCategories': <String, double>{},
        'totalBalance': widget.userModel.totalBalance,
      };
    }
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double highestIncome = 0.0;
    double highestExpense = 0.0;
    String highestIncomeCategory = '';
    String highestExpenseCategory = '';

    // Track category-wise totals
    Map<String, double> incomeCategories = {};
    Map<String, double> expenseCategories = {};

    for (var transaction in _filteredTransactions) {
      if (transaction.type == 'Income') {
        totalIncome += transaction.amount;
        incomeCategories.update(
            transaction.category, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);

        if (transaction.amount > highestIncome) {
          highestIncome = transaction.amount;
          highestIncomeCategory = transaction.category;
        }
      } else {
        totalExpense += transaction.amount;
        expenseCategories.update(
            transaction.category, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);

        if (transaction.amount > highestExpense) {
          highestExpense = transaction.amount;
          highestExpenseCategory = transaction.category;
        }
      }
    }

    // Total balance from user's accounts
    double totalBalance = widget.userModel.totalBalance;

    // Calculate net balance considering total balance
    // This ensures net balance reflects overall financial health
    double netBalance = totalBalance + totalIncome - totalExpense;
    double netSavings = totalIncome - totalExpense;

    // Calculate savings rate based on income
    double savingsRate = totalIncome > 0
        ? ((netSavings) / totalIncome * 100).roundToDouble()
        : 0.0;

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netBalance': netBalance,
      'savingsRate': savingsRate,
      'highestIncome': highestIncome,
      'highestExpense': highestExpense,
      'highestIncomeCategory': highestIncomeCategory,
      'highestExpenseCategory': highestExpenseCategory,
      'incomeCategories': incomeCategories,
      'expenseCategories': expenseCategories,
      'totalBalance': totalBalance,
    };
  }

  Widget _buildCompactSummaryCard() {
    final metrics = _calculateSummaryMetrics();
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Balance',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  currencyProvider.formatCurrency(metrics['totalBalance']),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: metrics['netBalance'] >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showDetailedSummaryBottomSheet(metrics),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  void _showDetailedSummaryBottomSheet(Map<String, dynamic> metrics) {
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Résumé financier détaillé',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    children: [
                      _buildMetricColumnWithIcon(
                        'Solde total',
                        currencyProvider
                            .formatCurrency(metrics['totalBalance']),
                        Icons.account_balance_wallet,
                        Colors.blue.shade300,
                      ),
                      _buildMetricColumnWithIcon(
                        'Valeur nette',
                        currencyProvider.formatCurrency(metrics['netBalance']),
                        metrics['netBalance'] >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        metrics['netBalance'] >= 0
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                      ),
                      _buildMetricColumnWithIcon(
                        'Total revenu',
                        currencyProvider.formatCurrency(metrics['totalIncome']),
                        Icons.arrow_upward,
                        Colors.green.shade300,
                      ),
                      _buildMetricColumnWithIcon(
                        'Total dépense',
                        currencyProvider
                            .formatCurrency(metrics['totalExpense']),
                        Icons.arrow_downward,
                        Colors.red.shade300,
                      ),
                      _buildMetricColumnWithIcon(
                        'Taux d\'épargne',
                        '${metrics['savingsRate'].toStringAsFixed(1)}%',
                        Icons.savings,
                        Colors.purple.shade300,
                      ),
                      _buildMetricColumnWithIcon(
                        'Dépense la plus élevée',
                        '${metrics['highestExpenseCategory']}\n${currencyProvider.formatCurrency(metrics['highestExpense'])}',
                        Icons.money_off,
                        Colors.orange.shade300,
                      ),
                      _buildMetricColumnWithIcon(
                          'Revenu le plus élevé',
                          '${metrics['highestIncomeCategory']}\n${currencyProvider.formatCurrency(metrics['highestIncome'])}',
                          Icons.money_outlined,
                          Colors.green.shade200),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumnWithIcon(
      String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.darken(0.2),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color.darken(0.4),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsContent() {
    if (_filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              color: Colors.grey.shade400,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune transaction trouvée',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 18,
              ),
            ),
            Text(
              'Essayez de sélectionner une période différente ou d\'ajouter des transactions',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildChartCard(
          'Revenus vs dépenses',
          _buildIncomeExpenseBarChart(),
        ),
        _buildChartCard(
          'Transactions mensuelles',
          _buildMonthlyLineChart(),
        ),
        _buildChartCard(
          'Répartition des catégories',
          _buildCategoryBarChart(),
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 1,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryDarkColor,
              ),
            ),
          ),
          chart,
        ],
      ),
    );
  }

  Widget _buildCategoryBarChart() {
    Map<String, double> categoryTotals = {};

    for (var transaction in _filteredTransactions) {
      if (_selectedChartType == 'Expense' && transaction.type == 'Expense') {
        categoryTotals.update(
            transaction.category, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      } else if (_selectedChartType == 'Income' &&
          transaction.type == 'Income') {
        categoryTotals.update(
            transaction.category, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      }
    }

    // If no transactions or no category totals, show an empty state
    if (categoryTotals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Aucune transaction dans la catégorie sélectionnée',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    List<BarChartGroupData> barGroups = categoryTotals.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key.hashCode,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: _getCategoryColor(entry.key),
            width: 20,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              color: _getCategoryColor(entry.key).withOpacity(0.3),
            ),
          ),
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    String category = categoryTotals.keys.firstWhere(
                      (key) => key.hashCode == value.toInt(),
                      orElse: () => '',
                    );
                    return Transform.rotate(
                      angle: -pi / 6,
                      child: Text(category,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black87)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: 1000,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 1000,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.black12,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Colors.black12,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
            minY: 0,
            maxY: categoryTotals.values.isNotEmpty
                ? categoryTotals.values.reduce(max) * 1.1
                : 1000,
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseBarChart() {
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var transaction in _filteredTransactions) {
      if (transaction.type == 'Income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    // If no transactions, show an empty state
    if (_filteredTransactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Aucune transaction disponible',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return const Text('Income');
                      case 1:
                        return const Text('Expense');
                      default:
                        return const Text('');
                    }
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: 1000,
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: totalIncome,
                    color: Colors.green.shade300,
                    width: 40,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      color: Colors.green.shade100,
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: totalExpense,
                    color: Colors.redAccent.shade200,
                    width: 40,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      color: Colors.red.shade100,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyLineChart() {
    Map<int, double> monthlyTotals = {};
    for (var transaction in _transactions) {
      if (_selectedChartType == 'Expense' && transaction.type == 'Expense') {
        int month = transaction.date.toDate().month;
        monthlyTotals.update(month, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      } else if (_selectedChartType == 'Income' &&
          transaction.type == 'Income') {
        int month = transaction.date.toDate().month;
        monthlyTotals.update(month, (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount);
      }
    }

    // If no monthly transactions, show an empty state
    if (monthlyTotals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Aucune transaction mensuelle disponible',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    List<FlSpot> spots = List.generate(12, (index) {
      double total = monthlyTotals[index + 1] ?? 0.0;
      return FlSpot(index.toDouble(), total);
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    const monthNames = [
                      'Jan',
                      'Fev',
                      'Mar',
                      'Avr',
                      'Mai',
                      'Juin',
                      'Juil',
                      'Aout',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec'
                    ];
                    return Text(
                      monthNames[value.toInt()],
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1000,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    );
                  },
                  reservedSize: 50,
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 1000,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.black12,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Colors.black12,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: _selectedChartType == 'Expense'
                    ? Colors.redAccent
                    : Colors.green,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: (_selectedChartType == 'Expense'
                          ? Colors.redAccent
                          : Colors.green)
                      .withOpacity(0.3),
                ),
              ),
            ],
            minX: 0,
            maxX: 11,
            minY: 0,
            maxY: monthlyTotals.values.isNotEmpty
                ? monthlyTotals.values.reduce(max) * 1.1
                : 1000,
          ),
        ),
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}
