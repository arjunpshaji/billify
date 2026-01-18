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
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.h2),
        backgroundColor: AppColors.bgMain,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          // Currency Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.space5),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.currency_exchange,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Display Currency', style: AppTypography.h3),
                        Text(
                          'Choose your preferred currency',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),
                ...List.generate(_currencies.length, (index) {
                  final currency = _currencies[index];
                  final isSelected = currency == _selectedCurrency;

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.space2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.bgInput,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
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
                        style: AppTypography.body.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(currency, style: AppTypography.caption),
                      activeColor: AppColors.primary,
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.space4),

          // About Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.space5),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(Icons.info, color: AppColors.secondary),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Text('About', style: AppTypography.h3),
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'Catch Your Bill',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text('Version 1.0.0', style: AppTypography.caption),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  'A modern bill management app with OCR, PDF support, and currency conversion.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
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
