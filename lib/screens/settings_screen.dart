import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/design_tokens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedCurrency = 'USD';
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'INR'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _selectedCurrency = box.get('currency', defaultValue: 'USD');
    });
  }

  Future<void> _saveCurrency(String currency) async {
    final box = await Hive.openBox('settings');
    await box.put('currency', currency);
    setState(() {
      _selectedCurrency = currency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundDark,
      appBar: AppBar(
        title: Text('Settings', style: DesignTokens.headingMedium),
        backgroundColor: DesignTokens.backgroundDark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spacing16),
        children: [
          // Currency Section
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing20),
            decoration: BoxDecoration(
              color: DesignTokens.backgroundCard,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.spacing8),
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                      ),
                      child: Icon(
                        Icons.currency_exchange,
                        color: DesignTokens.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacing12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Display Currency', style: DesignTokens.headingSmall),
                        Text(
                          'Choose your preferred currency',
                          style: DesignTokens.caption,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacing16),
                ...List.generate(_currencies.length, (index) {
                  final currency = _currencies[index];
                  final isSelected = currency == _selectedCurrency;

                  return Container(
                    margin: const EdgeInsets.only(bottom: DesignTokens.spacing8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DesignTokens.primaryPurple.withOpacity(0.1)
                          : DesignTokens.backgroundCardLight,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                      border: Border.all(
                        color: isSelected
                            ? DesignTokens.primaryPurple
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: RadioListTile<String>(
                      value: currency,
                      groupValue: _selectedCurrency,
                      onChanged: (value) {
                        if (value != null) {
                          _saveCurrency(value);
                        }
                      },
                      title: Text(
                        _getCurrencyName(currency),
                        style: DesignTokens.bodyMedium.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(currency, style: DesignTokens.caption),
                      activeColor: DesignTokens.primaryPurple,
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spacing16),

          // About Section
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing20),
            decoration: BoxDecoration(
              color: DesignTokens.backgroundCard,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.spacing8),
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryPurpleDark.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                      ),
                      child: Icon(Icons.info, color: DesignTokens.primaryPurpleDark),
                    ),
                    const SizedBox(width: DesignTokens.spacing12),
                    Text('About', style: DesignTokens.headingSmall),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacing16),
                Text(
                  'Billify',
                  style: DesignTokens.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing4),
                Text('Version 1.0.0', style: DesignTokens.caption),
                const SizedBox(height: DesignTokens.spacing12),
                Text(
                  'A bill documenting and analyser',
                  style: DesignTokens.bodyMedium.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'British Pound';
      case 'JPY':
        return 'Japanese Yen';
      case 'INR':
        return 'Indian Rupee';
      default:
        return code;
    }
  }
}
