import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/bill_provider.dart';
import '../services/currency_service.dart';
import '../utils/design_tokens.dart';
import 'add_bill_screen.dart';
import 'bill_detail_screen.dart';
import 'settings_screen.dart';
import 'spend_analysis_screen.dart';
import '../utils/page_transitions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Icons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bills Icon (Left) or Search Bar
                  if (!_isSearching)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                  else
                    Expanded(
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.only(right: AppSpacing.space2),
                        decoration: BoxDecoration(
                          color: AppColors.bgInput,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.borderInput,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: AppTypography.body,
                          decoration: InputDecoration(
                            hintText: 'Search bills...',
                            hintStyle: AppTypography.body.copyWith(
                              color: AppColors.textMuted,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space2,
                              vertical: AppSpacing.space2,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                    ),

                  // Right Icons
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: _toggleSearch,
                      ),
                      if (!_isSearching) ...[
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              SlidePageRoute(page: const SettingsScreen()),
                            );
                          },
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.filter_list,
                            color: AppColors.textPrimary,
                          ),
                          onSelected: (value) {
                            if (value == 'analysis') {
                              Navigator.push(
                                context,
                                SlidePageRoute(
                                  page: const SpendAnalysisScreen(),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'analysis',
                              child: Row(
                                children: [
                                  Icon(Icons.analytics, size: 20),
                                  SizedBox(width: 8),
                                  Text('Spend Analysis'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'newest',
                              child: Text('Newest First'),
                            ),
                            const PopupMenuItem(
                              value: 'oldest',
                              child: Text('Oldest First'),
                            ),
                            const PopupMenuItem(
                              value: 'high',
                              child: Text('Amount: High to Low'),
                            ),
                            const PopupMenuItem(
                              value: 'low',
                              child: Text('Amount: Low to High'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.space2),

            // Bills List
            Expanded(
              child: Consumer<BillProvider>(
                builder: (context, billProvider, child) {
                  if (billProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filter bills based on search query
                  final filteredBills = _searchQuery.isEmpty
                      ? billProvider.bills
                      : billProvider.bills.where((bill) {
                          return bill.title.toLowerCase().contains(
                                _searchQuery,
                              ) ||
                              bill.category.toLowerCase().contains(
                                _searchQuery,
                              );
                        }).toList();

                  if (filteredBills.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isEmpty
                                ? Icons.receipt_long
                                : Icons.search_off,
                            size: 80,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No bills found'
                                : 'No bills match your search',
                            style: AppTypography.h3.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Tap the + button to add your first bill'
                                : 'Try a different search term',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredBills.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                      vertical: AppSpacing.space2,
                    ),
                    itemBuilder: (context, index) {
                      final bill = filteredBills[index];
                      final isPdf =
                          bill.originalFilePath?.toLowerCase().endsWith(
                            '.pdf',
                          ) ??
                          false;

                      return ModernBillCard(bill: bill, isPdf: isPdf);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: AppShadows.floatingButton,
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              SlidePageRoute(
                page: const AddBillScreen(),
                direction: AxisDirection.up,
              ),
            );
          },
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}

class ModernBillCard extends StatefulWidget {
  final dynamic bill;
  final bool isPdf;

  const ModernBillCard({super.key, required this.bill, required this.isPdf});

  @override
  State<ModernBillCard> createState() => _ModernBillCardState();
}

class _ModernBillCardState extends State<ModernBillCard> {
  String _targetCurrency = 'USD';
  double? _convertedAmount;
  final CurrencyService _currencyService = CurrencyService();

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final settingsBox = await Hive.openBox('settings');
    final currency = settingsBox.get('currency', defaultValue: 'USD');

    if (currency != 'USD') {
      final rate = await _currencyService.getExchangeRate(
        'USD',
        currency,
        widget.bill.date,
      );
      if (mounted && rate != null) {
        setState(() {
          _targetCurrency = currency;
          _convertedAmount = widget.bill.amount * rate;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: () {
            Navigator.push(
              context,
              SlidePageRoute(page: BillDetailScreen(bill: widget.bill)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Merchant Name
                      Text(
                        widget.bill.title,
                        style: AppTypography.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.space1),
                      // Date
                      Text(
                        DateFormat('MMM dd, yyyy').format(widget.bill.date),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Original Amount (strikethrough)
                    if (_targetCurrency != 'USD' && _convertedAmount != null)
                      Text(
                        '\$${widget.bill.amount.toStringAsFixed(2)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.strikethrough,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.strikethrough,
                        ),
                      ),
                    const SizedBox(height: 2),
                    // Converted Amount (blue, large)
                    Text(
                      _targetCurrency != 'USD' && _convertedAmount != null
                          ? '€${_convertedAmount!.toStringAsFixed(2)}'
                          : '\$${widget.bill.amount.toStringAsFixed(2)}',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
