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
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        ),
        title: Text('Delete Bill?', style: DesignTokens.headingSmall),
        content: Text(
          'This action cannot be undone.',
          style: DesignTokens.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: DesignTokens.statusError),
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
      backgroundColor: DesignTokens.backgroundDark,
      appBar: AppBar(
        backgroundColor: DesignTokens.backgroundDark,
        title: Text('Bill Details', style: DesignTokens.headingMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignTokens.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: DesignTokens.textPrimary),
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
        padding: const EdgeInsets.all(DesignTokens.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bill Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: DesignTokens.backgroundCard,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
              ),
              child: isPdf
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 80,
                            color: DesignTokens.statusError,
                          ),
                          const SizedBox(height: DesignTokens.spacing8),
                          Text('PDF Document', style: DesignTokens.bodyMedium),
                          const SizedBox(height: DesignTokens.spacing12),
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
                      borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                      child: Image.file(
                        File(widget.bill.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: DesignTokens.textTertiary,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: DesignTokens.spacing24),

            // Details Grid
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacing20),
              decoration: BoxDecoration(
                color: DesignTokens.backgroundCard,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
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
                              style: DesignTokens.caption.copyWith(
                                color: DesignTokens.textSecondary,
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spacing4),
                            Text(
                              widget.bill.title,
                              style: DesignTokens.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: DesignTokens.caption.copyWith(
                                color: DesignTokens.textSecondary,
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spacing4),
                            Text(
                              DateFormat(
                                'MMMM dd, yyyy',
                              ).format(widget.bill.date),
                              style: DesignTokens.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacing16),

                  // Type
                  Text(
                    'Type',
                    style: DesignTokens.caption.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  Text(
                    widget.bill.category,
                    style: DesignTokens.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing16),

                  // Original Amount
                  Text(
                    'Original Amount',
                    style: DesignTokens.caption.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  Text(
                    'USD \$${widget.bill.amount.toStringAsFixed(2)}',
                    style: DesignTokens.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Converted Amount
                  if (_targetCurrency != 'USD') ...[
                    const SizedBox(height: DesignTokens.spacing16),
                    Text(
                      'Converted Amount',
                      style: DesignTokens.caption.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing4),
                    if (_isLoadingConversion)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (_convertedAmount != null)
                      Text(
                        '$_targetCurrency ${_convertedAmount!.toStringAsFixed(2)}',
                        style: DesignTokens.headingMedium.copyWith(
                          color: DesignTokens.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        _rateError ?? '',
                        style: DesignTokens.caption.copyWith(
                          color: DesignTokens.statusError,
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacing24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareBill,
                    icon: const Icon(Icons.share, size: 20),
                    label: const Text('Share Bill'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.primaryPurple,
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spacing16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacing12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteBill(context),
                    icon: const Icon(Icons.delete, size: 20),
                    label: const Text('Delete Bill'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.statusError,
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spacing16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacing16),
          ],
        ),
      ),
    );
  }
}
