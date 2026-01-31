import 'package:flutter/material.dart';
import '../utils/design_tokens.dart';

/// Bottom navigation bar with floating design and elevated center button
class MainNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onCenterButtonTap;

  const MainNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCenterButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing12,
        vertical: DesignTokens.spacing8,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Floating nav bar
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: DesignTokens.backgroundCard.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              border: Border.all(
                color: DesignTokens.borderPrimary.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 50,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left side nav items
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: Icons.home,
                        label: 'Home',
                        isSelected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                      _NavItem(
                        icon: Icons.trending_up,
                        label: 'Insights',
                        isSelected: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                    ],
                  ),
                ),

                // Spacer for center button
                const SizedBox(width: 80),

                // Right side nav items
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: Icons.account_balance_wallet,
                        label: 'Bills',
                        isSelected: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                      _NavItem(
                        icon: Icons.person,
                        label: 'Settings',
                        isSelected: currentIndex == 3,
                        onTap: () => onTap(3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Elevated center scan button
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glow effect
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.primaryPurple.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  // Button with gradient border
                  Transform.translate(
                    offset: const Offset(0, -60),
                    child: GestureDetector(
                      onTap: onCenterButtonTap,
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              DesignTokens.primaryPurple,
                              DesignTokens.accentCyan,
                            ],
                          ),
                          boxShadow: DesignTokens.shadowPurple,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: DesignTokens.backgroundDark,
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: DesignTokens.textPrimary.withValues(
                                alpha: 0.05,
                              ),
                              border: Border.all(
                                color: DesignTokens.textPrimary.withValues(
                                  alpha: 0.1,
                                ),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Label
                  Transform.translate(
                    offset: const Offset(0, -55),
                    child: Text(
                      'SCAN',
                      style: DesignTokens.labelSmall.copyWith(
                        color: DesignTokens.accentCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing12,
          vertical: DesignTokens.spacing8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? DesignTokens.primaryPurple
                  : DesignTokens.textSecondary,
              fill: isSelected ? 1.0 : 0.0,
            ),
            const SizedBox(height: DesignTokens.spacing4),
            Text(
              label.toUpperCase(),
              style: DesignTokens.labelSmall.copyWith(
                color: isSelected
                    ? DesignTokens.primaryPurple
                    : DesignTokens.textSecondary,
                fontWeight: FontWeight.w900,
                fontSize: 9,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
