import 'package:flutter/material.dart';
import '../utils/design_tokens.dart';

/// Status badge widget for displaying bill status
/// Used in bill cards to show verification status
class StatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;

  const StatusBadge({super.key, required this.status, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    final color = DesignTokens.getStatusColor(status);
    final icon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing8,
        vertical: DesignTokens.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: DesignTokens.spacing4),
          ],
          Text(
            status.toUpperCase(),
            style: DesignTokens.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'verified ai':
        return Icons.check_circle;
      case 'reviewing':
        return Icons.pending;
      case 'recurring':
        return Icons.repeat;
      case 'error':
      case 'failed':
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}
