import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/bill_provider.dart';
import '../utils/design_tokens.dart';

class SpendAnalysisScreen extends StatefulWidget {
  const SpendAnalysisScreen({super.key});

  @override
  State<SpendAnalysisScreen> createState() => _SpendAnalysisScreenState();
}

class _SpendAnalysisScreenState extends State<SpendAnalysisScreen> {
  String _selectedPeriod = 'Month';
  final List<String> _periods = ['Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);
    final bills = billProvider.bills;

    // Calculate spending by category
    final Map<String, double> categorySpending = {};
    double totalSpending = 0;

    for (var bill in bills) {
      final category = bill.category;
      final amount = bill.amount;
      categorySpending[category] = (categorySpending[category] ?? 0) + amount;
      totalSpending += amount;
    }

    // Sort categories by spending
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: DesignTokens.backgroundCard,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignTokens.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Spend Analysis', style: DesignTokens.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.file_download_outlined,
              color: DesignTokens.textPrimary,
            ),
            onPressed: () {
              // Export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: bills.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  _buildPeriodSelector(),
                  const SizedBox(height: DesignTokens.spacing24),

                  // Total Spending Card
                  _buildTotalSpendingCard(totalSpending),
                  const SizedBox(height: DesignTokens.spacing24),

                  // Pie Chart
                  _buildPieChart(categorySpending, totalSpending),
                  const SizedBox(height: DesignTokens.spacing24),

                  // Category Breakdown
                  _buildCategoryBreakdown(sortedCategories, totalSpending),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: DesignTokens.textTertiary,
          ),
          const SizedBox(height: DesignTokens.spacing16),
          Text(
            'No bills to analyze',
            style: DesignTokens.headingSmall.copyWith(
              color: DesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing8),
          Text(
            'Add some bills to see your spending analysis',
            style: DesignTokens.caption.copyWith(
              color: DesignTokens.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: DesignTokens.backgroundCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DesignTokens.primaryPurple
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusMedium,
                  ),
                ),
                child: Text(
                  period,
                  style: DesignTokens.bodyMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : DesignTokens.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalSpendingCard(double totalSpending) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.spacing24),
      decoration: BoxDecoration(
        gradient: DesignTokens.primaryGradient,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Spending',
            style: DesignTokens.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing8),
          Text(
            '\$${totalSpending.toStringAsFixed(2)}',
            style: DesignTokens.displayLarge.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing4),
          Text(
            'This $_selectedPeriod',
            style: DesignTokens.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    Map<String, double> categorySpending,
    double totalSpending,
  ) {
    if (categorySpending.isEmpty) return const SizedBox.shrink();

    final colors = [
      DesignTokens.primaryPurple,
      DesignTokens.categoryGroceries,
      DesignTokens.categoryTech,
      DesignTokens.categoryDining,
      DesignTokens.categoryUtilities,
      DesignTokens.categoryTransport,
      DesignTokens.categoryHealth,
      const Color(0xFF00F5FF),
    ];

    int colorIndex = 0;
    final sections = categorySpending.entries.map((entry) {
      final percentage = (entry.value / totalSpending * 100);
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 100,
        titleStyle: DesignTokens.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing24),
      decoration: BoxDecoration(
        color: DesignTokens.backgroundCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending by Category', style: DesignTokens.headingSmall),
          const SizedBox(height: DesignTokens.spacing24),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    List<MapEntry<String, double>> sortedCategories,
    double totalSpending,
  ) {
    final colors = [
      DesignTokens.primaryPurple,
      DesignTokens.categoryGroceries,
      DesignTokens.categoryTech,
      DesignTokens.categoryDining,
      DesignTokens.categoryUtilities,
      DesignTokens.categoryTransport,
      DesignTokens.categoryHealth,
      const Color(0xFF00F5FF),
    ];

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing24),
      decoration: BoxDecoration(
        color: DesignTokens.backgroundCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Breakdown', style: DesignTokens.headingSmall),
          const SizedBox(height: DesignTokens.spacing16),
          ...sortedCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value.key;
            final amount = entry.value.value;
            final percentage = (amount / totalSpending * 100);
            final color = colors[index % colors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spacing8),
                          Text(
                            category,
                            style: DesignTokens.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${amount.toStringAsFixed(2)}',
                        style: DesignTokens.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacing8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: DesignTokens.backgroundCardLight,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing8),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: DesignTokens.caption,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
