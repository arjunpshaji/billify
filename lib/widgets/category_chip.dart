import 'package:flutter/material.dart';
import '../utils/design_tokens.dart';

/// Category chip widget for filtering bills by category
class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = category.toLowerCase() == 'all'
        ? DesignTokens.primaryPurple
        : DesignTokens.getCategoryColor(category);
    final icon = category.toLowerCase() == 'all'
        ? Icons.apps
        : DesignTokens.getCategoryIcon(category);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DesignTokens.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing16,
          vertical: DesignTokens.spacing8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? DesignTokens.primaryGradient : null,
          color: isSelected ? null : DesignTokens.backgroundCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
          border: Border.all(
            color: isSelected
                ? DesignTokens.primaryPurple
                : DesignTokens.borderPrimary,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? DesignTokens.textPrimary : color,
            ),
            const SizedBox(width: DesignTokens.spacing8),
            Text(
              category,
              style: DesignTokens.labelMedium.copyWith(
                color: isSelected
                    ? DesignTokens.textPrimary
                    : DesignTokens.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
