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
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        backgroundColor: AppColors.bgMain,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Spend Analysis', style: AppTypography.h2),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.file_download_outlined,
              color: AppColors.textPrimary,
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
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  _buildPeriodSelector(),
                  const SizedBox(height: AppSpacing.space6),

                  // Total Spending Card
                  _buildTotalSpendingCard(totalSpending),
                  const SizedBox(height: AppSpacing.space6),

                  // Pie Chart
                  _buildPieChart(categorySpending, totalSpending),
                  const SizedBox(height: AppSpacing.space6),

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
          Icon(Icons.analytics_outlined, size: 80, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.space4),
          Text(
            'No bills to analyze',
            style: AppTypography.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Add some bills to see your spending analysis',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
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
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  period,
                  style: AppTypography.body.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
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
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Spending',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            '\$${totalSpending.toStringAsFixed(2)}',
            style: AppTypography.h1.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            'This $_selectedPeriod',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withOpacity(0.8),
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
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
      const Color(0xFFFF6B9D),
      const Color(0xFFC77DFF),
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
        titleStyle: AppTypography.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending by Category', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.space6),
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
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
      const Color(0xFFFF6B9D),
      const Color(0xFFC77DFF),
      const Color(0xFF00F5FF),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Breakdown', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.space4),
          ...sortedCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value.key;
            final amount = entry.value.value;
            final percentage = (amount / totalSpending * 100);
            final color = colors[index % colors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space4),
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
                          const SizedBox(width: AppSpacing.space2),
                          Text(
                            category,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${amount.toStringAsFixed(2)}',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: AppColors.bgInput,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: AppTypography.caption,
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
