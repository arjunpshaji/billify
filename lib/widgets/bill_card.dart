import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../utils/design_tokens.dart';
import 'status_badge.dart';
import 'package:intl/intl.dart';

/// Bill card widget for displaying bill information in a list
class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onTap;

  const BillCard({super.key, required this.bill, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');
    final categoryColor = DesignTokens.getCategoryColor(bill.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.spacing12),
        padding: const EdgeInsets.all(DesignTokens.spacing16),
        decoration: BoxDecoration(
          color: DesignTokens.backgroundCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(color: DesignTokens.borderPrimary, width: 1),
        ),
        child: Row(
          children: [
            // Receipt thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: DesignTokens.backgroundCardLight,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                border: Border.all(
                  color: categoryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: bill.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMedium - 2,
                      ),
                      child: Image.network(
                        bill.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderIcon(categoryColor),
                      ),
                    )
                  : _buildPlaceholderIcon(categoryColor),
            ),
            const SizedBox(width: DesignTokens.spacing16),
            // Bill details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$${bill.amount.toStringAsFixed(2)}',
                          style: DesignTokens.headingMedium,
                        ),
                      ),
                      // Status badge
                      StatusBadge(status: _getStatus(), showIcon: false),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  Text(
                    '${dateFormat.format(bill.date)} • ${bill.title}',
                    style: DesignTokens.bodySmall,
                  ),
                  if (_getStatus().isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spacing4),
                    Text(
                      _getStatusLabel(),
                      style: DesignTokens.labelSmall.copyWith(
                        color: DesignTokens.getCategoryColor(bill.category),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.spacing8),
            // Chevron
            Icon(
              Icons.chevron_right,
              color: DesignTokens.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(Color color) {
    return Center(child: Icon(Icons.receipt_long, color: color, size: 28));
  }

  String _getStatus() {
    // This is a placeholder - in a real app, this would come from the Bill model
    // For now, we'll return a random status based on the category
    if (bill.category.toLowerCase() == 'groceries') {
      return 'VERIFIED AI';
    } else if (bill.category.toLowerCase() == 'tech') {
      return 'TECH ASSET';
    } else if (bill.amount > 100) {
      return 'REVIEWING';
    }
    return 'RECURRING';
  }

  String _getStatusLabel() {
    final status = _getStatus();
    switch (status) {
      case 'TECH ASSET':
        return 'TECH ASSET';
      case 'REVIEWING':
        return 'REVIEWING';
      case 'RECURRING':
        return 'RECURRING';
      default:
        return status;
    }
  }
}
