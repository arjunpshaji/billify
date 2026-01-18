import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/currency_service.dart';
import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../utils/design_tokens.dart';

class BillDetailScreen extends StatefulWidget {
  final Bill bill;
  const BillDetailScreen({super.key, required this.bill});

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  double? _convertedAmount;
  String _targetCurrency = 'USD';
  bool _isLoadingConversion = false;
  final CurrencyService _currencyService = CurrencyService();
  String? _rateError;
  Box? _settingsBox;

  @override
  void initState() {
    super.initState();
    _loadConversionData();
    _setupSettingsListener();
  }

  @override
  void dispose() {
    _settingsBox?.close();
    super.dispose();
  }

  Future<void> _setupSettingsListener() async {
    _settingsBox = await Hive.openBox('settings');
    _settingsBox!.listenable().addListener(() {
      if (mounted) {
        _loadConversionData();
      }
    });
  }

  Future<void> _loadConversionData() async {
    setState(() => _isLoadingConversion = true);

    final settingsBox = await Hive.openBox('settings');
    _targetCurrency = settingsBox.get('currency', defaultValue: 'USD');

    final rate = await _currencyService.getExchangeRate(
      'USD',
      _targetCurrency,
      widget.bill.date,
    );

    if (mounted) {
      setState(() {
        if (rate != null) {
          _convertedAmount = widget.bill.amount * rate;
        } else {
          _rateError = 'Could not fetch rate';
        }
        _isLoadingConversion = false;
      });
    }
  }

  Future<void> _deleteBill(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text('Delete Bill?', style: AppTypography.h3),
        content: Text(
          'This action cannot be undone.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      await context.read<BillProvider>().deleteBill(widget.bill.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _shareBill() {
    final path = widget.bill.originalFilePath ?? widget.bill.imagePath;
    Share.shareXFiles([
      XFile(path),
    ], text: 'Bill: ${widget.bill.title} - \$${widget.bill.amount}');
  }

  @override
  Widget build(BuildContext context) {
    final isPdf =
        widget.bill.originalFilePath?.toLowerCase().endsWith('.pdf') ?? false;

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        backgroundColor: AppColors.bgMain,
        title: Text('Bill Details', style: AppTypography.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.textPrimary),
            onPressed: () {
              // Edit functionality placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bill Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: isPdf
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 80,
                            color: AppColors.danger,
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          Text('PDF Document', style: AppTypography.body),
                          const SizedBox(height: AppSpacing.space3),
                          OutlinedButton.icon(
                            onPressed: () =>
                                OpenFile.open(widget.bill.originalFilePath!),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('Open PDF'),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      child: Image.file(
                        File(widget.bill.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.space6),

            // Details Grid
            Container(
              padding: const EdgeInsets.all(AppSpacing.space5),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Merchant and Date Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Merchant',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space1),
                            Text(
                              widget.bill.title,
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space1),
                            Text(
                              DateFormat(
                                'MMMM dd, yyyy',
                              ).format(widget.bill.date),
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space4),

                  // Type
                  Text(
                    'Type',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    widget.bill.category,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),

                  // Original Amount
                  Text(
                    'Original Amount',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    'USD \$${widget.bill.amount.toStringAsFixed(2)}',
                    style: AppTypography.h2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Converted Amount
                  if (_targetCurrency != 'USD') ...[
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'Converted Amount',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    if (_isLoadingConversion)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (_convertedAmount != null)
                      Text(
                        '$_targetCurrency ${_convertedAmount!.toStringAsFixed(2)}',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        _rateError ?? '',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space6),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareBill,
                    icon: const Icon(Icons.share, size: 20),
                    label: const Text('Share Bill'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteBill(context),
                    icon: const Icon(Icons.delete, size: 20),
                    label: const Text('Delete Bill'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
        ),
      ),
    );
  }
}
