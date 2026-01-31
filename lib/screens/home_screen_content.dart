import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';
import '../utils/design_tokens.dart';
import '../widgets/scan_button.dart';
import 'add_bill_screen.dart';
import '../utils/page_transitions.dart';

/// Home screen content (without scaffold/navigation - used inside MainScreen)
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // User Profile Header
          _buildProfileHeader(context),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing24,
              ),
              child: Column(
                children: [
                  const SizedBox(height: DesignTokens.spacing32),

                  // BillScan AI Title
                  _buildTitle(),

                  const SizedBox(height: DesignTokens.spacing48),

                  // Large Scan Button
                  ScanButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(
                          page: const AddBillScreen(),
                          direction: AxisDirection.up,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: DesignTokens.spacing32),

                  // Input Method Buttons
                  _buildInputMethods(context),

                  const SizedBox(height: DesignTokens.spacing48),

                  // Recent Scans Section
                  _buildRecentScans(),

                  const SizedBox(height: DesignTokens.spacing24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing16),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: DesignTokens.primaryGradient,
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: DesignTokens.bodySmall.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'User',
                      style: DesignTokens.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacing8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: DesignTokens.statusVerified.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusSmall,
                        ),
                        border: Border.all(
                          color: DesignTokens.statusVerified.withValues(
                            alpha: 0.3,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'SYSTEM ACTIVE',
                        style: DesignTokens.labelSmall.copyWith(
                          color: DesignTokens.statusVerified,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: DesignTokens.textPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Billify AI',
          style: DesignTokens.displayLarge.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Text(
          'Scan, Organize, and Analyze Your Bills',
          style: DesignTokens.bodyMedium.copyWith(
            color: DesignTokens.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputMethods(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInputMethodButton(
            context: context,
            icon: Icons.camera_alt,
            label: 'Camera',
          ),
        ),
        const SizedBox(width: DesignTokens.spacing12),
        Expanded(
          child: _buildInputMethodButton(
            context: context,
            icon: Icons.photo_library,
            label: 'Gallery',
          ),
        ),
        const SizedBox(width: DesignTokens.spacing12),
        Expanded(
          child: _buildInputMethodButton(
            context: context,
            icon: Icons.picture_as_pdf,
            label: 'PDF',
          ),
        ),
      ],
    );
  }

  Widget _buildInputMethodButton({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SlidePageRoute(
            page: const AddBillScreen(),
            direction: AxisDirection.up,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing16),
        decoration: BoxDecoration(
          color: DesignTokens.backgroundCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(color: DesignTokens.borderPrimary, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: DesignTokens.primaryPurple, size: 32),
            const SizedBox(height: DesignTokens.spacing8),
            Text(
              label,
              style: DesignTokens.bodySmall.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScans() {
    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        final recentBills = billProvider.bills.take(3).toList();

        if (recentBills.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(DesignTokens.spacing24),
            decoration: BoxDecoration(
              color: DesignTokens.backgroundCard,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              border: Border.all(color: DesignTokens.borderPrimary, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: DesignTokens.textTertiary,
                ),
                const SizedBox(height: DesignTokens.spacing12),
                Text(
                  'No recent scans',
                  style: DesignTokens.bodyMedium.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing4),
                Text(
                  'Tap the scan button to get started',
                  style: DesignTokens.bodySmall.copyWith(
                    color: DesignTokens.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Scans',
                  style: DesignTokens.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${billProvider.bills.length} scans this month',
                  style: DesignTokens.bodySmall.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacing16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentBills.length,
                itemBuilder: (context, index) {
                  final bill = recentBills[index];
                  return _buildRecentScanCard(bill);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentScanCard(dynamic bill) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: DesignTokens.spacing12),
      decoration: BoxDecoration(
        color: DesignTokens.backgroundCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(color: DesignTokens.borderPrimary, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt, color: DesignTokens.primaryPurple, size: 32),
          const SizedBox(height: DesignTokens.spacing8),
          Text(
            '\$${bill.amount.toStringAsFixed(2)}',
            style: DesignTokens.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              bill.title,
              style: DesignTokens.bodySmall.copyWith(
                color: DesignTokens.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
