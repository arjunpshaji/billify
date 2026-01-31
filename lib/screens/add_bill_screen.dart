import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../services/ocr_service.dart';
import '../utils/design_tokens.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();

  File? _selectedImage;
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Groceries';
  String _selectedCurrency = 'USD';
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  bool _isSaving = false;
  bool _isScanning = false;

  // Line items extracted from receipt
  List<Map<String, dynamic>> _lineItems = [];

  // Total amount from bill (extracted from OCR)
  String _totalAmount = '0.00';

  final List<String> _categories = [
    'Groceries',
    'Tech',
    'Dining',
    'Utilities',
    'Transport',
    'Health',
  ];

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'INR',
    'JPY',
    'CAD',
    'AUD',
  ];

  @override
  void dispose() {
    _ocrService.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final file = File(image.path);
      setState(() {
        _selectedImage = file;
        _isScanning = true;
      });

      try {
        final text = await _ocrService.processImage(file);
        final details = _ocrService.extractBillDetails(text);
        final items = _ocrService.extractLineItems(text);
        final currency = _ocrService.detectCurrency(text);

        if (mounted) {
          setState(() {
            _merchantController.text = details['merchant'] ?? '';
            if (details['category'] != null) {
              _selectedCategory = details['category']!;
            }
            _selectedCurrency = currency;

            // Use total from OCR extraction
            if (details['amount'] != null && details['amount']!.isNotEmpty) {
              _totalAmount = details['amount']!;
            }

            // Convert line items to editable format
            _lineItems = items
                .map(
                  (item) => <String, dynamic>{
                    'name': item['name'] ?? '',
                    'price': item['price'] ?? '0.00',
                    'controller_name': TextEditingController(
                      text: item['name'] ?? '',
                    ),
                    'controller_price': TextEditingController(
                      text: item['price'] ?? '',
                    ),
                  },
                )
                .toList();

            _isScanning = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isScanning = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AI extraction failed: $e'),
              backgroundColor: DesignTokens.statusError,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF processing coming soon')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: DesignTokens.primaryPurple,
              onPrimary: Colors.white,
              surface: DesignTokens.backgroundCard,
              onSurface: DesignTokens.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addLineItem() {
    setState(() {
      _lineItems.add({
        'name': '',
        'price': '',
        'controller_name': TextEditingController(),
        'controller_price': TextEditingController(),
      });
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      // Dispose controllers
      (_lineItems[index]['controller_name'] as TextEditingController).dispose();
      (_lineItems[index]['controller_price'] as TextEditingController)
          .dispose();
      _lineItems.removeAt(index);
    });
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var item in _lineItems) {
      final controller = item['controller_price'] as TextEditingController;
      final price = double.tryParse(controller.text) ?? 0.0;
      total += price;
    }
    return total;
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Convert line items to saveable format
      final items = _lineItems.map((item) {
        final nameController = item['controller_name'] as TextEditingController;
        final priceController =
            item['controller_price'] as TextEditingController;
        return {
          'name': nameController.text,
          'price': double.tryParse(priceController.text) ?? 0.0,
        };
      }).toList();

      final bill = Bill(
        id: const Uuid().v4(),
        title: _merchantController.text,
        amount: _calculateTotal(),
        date: _selectedDate,
        category: _selectedCategory,
        imagePath: _selectedImage?.path ?? '',
        items: items,
      );

      if (mounted) {
        await Provider.of<BillProvider>(context, listen: false).addBill(bill);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving bill: $e'),
            backgroundColor: DesignTokens.statusError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Groceries':
        return DesignTokens.categoryGroceries;
      case 'Tech':
        return DesignTokens.categoryTech;
      case 'Dining':
        return DesignTokens.categoryDining;
      case 'Utilities':
        return DesignTokens.categoryUtilities;
      case 'Transport':
        return DesignTokens.categoryTransport;
      case 'Health':
        return DesignTokens.categoryHealth;
      default:
        return DesignTokens.primaryPurple;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Groceries':
        return Icons.shopping_cart;
      case 'Tech':
        return Icons.devices;
      case 'Dining':
        return Icons.restaurant;
      case 'Utilities':
        return Icons.bolt;
      case 'Transport':
        return Icons.directions_car;
      case 'Health':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
      case 'CAD':
      case 'AUD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'JPY':
        return '¥';
      default:
        return '\$';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DesignTokens.spacing24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Receipt Preview
                      if (_selectedImage != null) _buildReceiptPreview(),

                      // Scan Options (if no image)
                      if (_selectedImage == null) _buildScanOptions(),

                      const SizedBox(height: DesignTokens.spacing32),

                      // AI Extracted Data Header
                      if (_selectedImage != null) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: DesignTokens.accentCyan.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                color: DesignTokens.accentCyan,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: DesignTokens.spacing12),
                            Text(
                              'AI EXTRACTED DATA',
                              style: DesignTokens.labelSmall.copyWith(
                                color: DesignTokens.accentCyan,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spacing24),
                      ],

                      // Merchant & Date
                      _buildMerchantField(),
                      const SizedBox(height: DesignTokens.spacing20),

                      _buildDateField(),
                      const SizedBox(height: DesignTokens.spacing20),

                      _buildCategoryField(),
                      const SizedBox(height: DesignTokens.spacing20),

                      _buildCurrencyField(),
                      const SizedBox(height: DesignTokens.spacing32),

                      // Line Items Section
                      _buildLineItemsSection(),

                      const SizedBox(height: DesignTokens.spacing32),

                      // Action Buttons
                      if (_selectedImage != null) _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing16),
      decoration: BoxDecoration(
        color: DesignTokens.backgroundCard.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: DesignTokens.borderPrimary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            color: DesignTokens.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: DesignTokens.spacing8),
          Text(
            _selectedImage == null ? 'SCAN RECEIPT' : 'CONFIRM DETAILS',
            style: DesignTokens.headingSmall.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          if (_isScanning)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  DesignTokens.accentCyan,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReceiptPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: DesignTokens.backgroundCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: Border.all(color: DesignTokens.borderPrimary, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(_selectedImage!, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedImage = null;
                  _lineItems.clear();
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.statusError.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'RETRY',
                        style: DesignTokens.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOptions() {
    return Column(
      children: [
        const SizedBox(height: DesignTokens.spacing32),
        Icon(
          Icons.document_scanner,
          size: 80,
          color: DesignTokens.primaryPurple.withValues(alpha: 0.3),
        ),
        const SizedBox(height: DesignTokens.spacing24),
        Text(
          'Choose Scan Method',
          style: DesignTokens.headingMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Text(
          'Capture or upload your receipt',
          style: DesignTokens.bodyMedium.copyWith(
            color: DesignTokens.textSecondary,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing32),
        Row(
          children: [
            Expanded(
              child: _buildScanOptionButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                color: DesignTokens.accentCyan,
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: DesignTokens.spacing12),
            Expanded(
              child: _buildScanOptionButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                color: DesignTokens.primaryPurple,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
            const SizedBox(width: DesignTokens.spacing12),
            Expanded(
              child: _buildScanOptionButton(
                icon: Icons.picture_as_pdf,
                label: 'PDF',
                color: DesignTokens.categoryTech,
                onTap: _pickPDF,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScanOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing20),
        decoration: BoxDecoration(
          color: DesignTokens.backgroundCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(color: DesignTokens.borderPrimary, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: DesignTokens.spacing8),
            Text(
              label.toUpperCase(),
              style: DesignTokens.labelSmall.copyWith(
                color: DesignTokens.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MERCHANT',
          style: DesignTokens.labelSmall.copyWith(
            color: DesignTokens.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        TextFormField(
          controller: _merchantController,
          style: DesignTokens.bodyMedium.copyWith(
            color: DesignTokens.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Enter merchant name',
            hintStyle: DesignTokens.bodyMedium.copyWith(
              color: DesignTokens.textTertiary,
            ),
            filled: true,
            fillColor: DesignTokens.backgroundCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              borderSide: BorderSide(color: DesignTokens.borderPrimary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              borderSide: BorderSide(color: DesignTokens.borderPrimary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              borderSide: BorderSide(
                color: DesignTokens.primaryPurple,
                width: 2,
              ),
            ),
            prefixIcon: Icon(Icons.store, color: DesignTokens.textSecondary),
            suffixIcon: _selectedImage != null
                ? Icon(
                    Icons.auto_awesome,
                    color: DesignTokens.accentCyan,
                    size: 20,
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter merchant name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE',
          style: DesignTokens.labelSmall.copyWith(
            color: DesignTokens.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spacing16),
            decoration: BoxDecoration(
              color: DesignTokens.backgroundCard,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(color: DesignTokens.borderPrimary),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: DesignTokens.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: DesignTokens.spacing12),
                Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: DesignTokens.bodyMedium.copyWith(
                    color: DesignTokens.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: DesignTokens.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORY',
          style: DesignTokens.labelSmall.copyWith(
            color: DesignTokens.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing16,
            vertical: DesignTokens.spacing4,
          ),
          decoration: BoxDecoration(
            color: DesignTokens.backgroundCard,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            border: Border.all(color: DesignTokens.borderPrimary),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: DesignTokens.textSecondary,
              ),
              dropdownColor: DesignTokens.backgroundCard,
              style: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textPrimary,
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: _getCategoryColor(category),
                        size: 20,
                      ),
                      const SizedBox(width: DesignTokens.spacing12),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURRENCY',
          style: DesignTokens.labelSmall.copyWith(
            color: DesignTokens.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing16,
            vertical: DesignTokens.spacing4,
          ),
          decoration: BoxDecoration(
            color: DesignTokens.backgroundCard,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            border: Border.all(color: DesignTokens.borderPrimary),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCurrency,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: DesignTokens.textSecondary,
              ),
              dropdownColor: DesignTokens.backgroundCard,
              style: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textPrimary,
              ),
              items: _currencies.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Row(
                    children: [
                      Text(
                        _getCurrencySymbol(currency),
                        style: TextStyle(
                          color: DesignTokens.accentCyan,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing12),
                      Text(currency),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCurrency = newValue;
                  });
                }
              },
            ),
          ),
        ),
        if (_selectedImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: DesignTokens.accentCyan,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  'Auto-detected (tap to change)',
                  style: DesignTokens.labelSmall.copyWith(
                    color: DesignTokens.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLineItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LINE ITEMS',
              style: DesignTokens.labelSmall.copyWith(
                color: DesignTokens.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            TextButton.icon(
              onPressed: _addLineItem,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'ADD ITEM',
                style: DesignTokens.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: DesignTokens.primaryPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacing12),

        // Line items list
        if (_lineItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing24),
            decoration: BoxDecoration(
              color: DesignTokens.backgroundCard,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(color: DesignTokens.borderPrimary),
            ),
            child: Center(
              child: Text(
                'No items added yet',
                style: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.textTertiary,
                ),
              ),
            ),
          )
        else
          ..._lineItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildLineItemRow(index, item);
          }).toList(),

        // Total
        if (_lineItems.isNotEmpty) ...[
          const SizedBox(height: DesignTokens.spacing16),
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing16),
            decoration: BoxDecoration(
              color: DesignTokens.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(
                color: DesignTokens.primaryPurple.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: DesignTokens.headingSmall.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '${_getCurrencySymbol(_selectedCurrency)}$_totalAmount',
                  style: DesignTokens.headingMedium.copyWith(
                    color: DesignTokens.primaryPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLineItemRow(int index, Map<String, dynamic> item) {
    final nameController = item['controller_name'] as TextEditingController;
    final priceController = item['controller_price'] as TextEditingController;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing12),
      padding: const EdgeInsets.all(DesignTokens.spacing12),
      decoration: BoxDecoration(
        color: DesignTokens.backgroundCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(color: DesignTokens.borderPrimary),
      ),
      child: Row(
        children: [
          // Item number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DesignTokens.primaryPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: DesignTokens.bodySmall.copyWith(
                  color: DesignTokens.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing12),

          // Item name field
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: nameController,
              style: DesignTokens.bodySmall.copyWith(
                color: DesignTokens.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Item name',
                hintStyle: DesignTokens.bodySmall.copyWith(
                  color: DesignTokens.textTertiary,
                ),
                filled: true,
                fillColor: DesignTokens.backgroundDark,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing8),

          // Price field
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: DesignTokens.bodySmall.copyWith(
                color: DesignTokens.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: DesignTokens.bodySmall.copyWith(
                  color: DesignTokens.textTertiary,
                ),
                filled: true,
                fillColor: DesignTokens.backgroundDark,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                prefixText: _getCurrencySymbol(_selectedCurrency),
                prefixStyle: DesignTokens.bodySmall.copyWith(
                  color: DesignTokens.accentCyan,
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}), // Recalculate total
            ),
          ),
          const SizedBox(width: DesignTokens.spacing8),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: DesignTokens.statusError,
            onPressed: () => _removeLineItem(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Confirm & Save Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveBill,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'CONFIRM & SAVE',
                    style: DesignTokens.bodyMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
