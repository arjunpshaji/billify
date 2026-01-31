import 'package:flutter/material.dart';
import '../utils/design_tokens.dart';
import '../widgets/main_navigation.dart';
import 'home_screen_content.dart';
import 'spend_analysis_screen.dart';
import 'settings_screen.dart';
import 'add_bill_screen.dart';

/// Main screen wrapper that manages bottom navigation and screen switching
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenContent(),
    const SpendAnalysisScreen(),
    const SyncScreen(), // Placeholder
    const SettingsScreen(),
  ];

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundDark,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: MainNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
        onCenterButtonTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBillScreen()),
          );
        },
      ),
    );
  }
}

/// Placeholder for Sync screen
class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundDark,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_sync,
                size: 80,
                color: DesignTokens.primaryPurple,
              ),
              const SizedBox(height: DesignTokens.spacing24),
              Text(
                'Sync Feature',
                style: DesignTokens.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing8),
              Text(
                'Coming Soon',
                style: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
