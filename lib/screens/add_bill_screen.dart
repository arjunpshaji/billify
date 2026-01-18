import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();

  File? _selectedImage;
  DateTime _selectedDate = DateTime.now();
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  bool _isSaving = false;
  bool _isScanning = false;
  File? _originalFile;
  bool _isPdf = false;

  @override
  void dispose() {
    _ocrService.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
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

        if (mounted) {
          _showVerificationDialog(details);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('OCR failed: $e')));
        }
      } finally {
        if (mounted) setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _originalFile = file;
        _isPdf = true;
        _selectedImage = null;
      });

      if (mounted) {
        _showPDFConfirmDialog();
      }
    }
  }

  Future<void> _showPDFConfirmDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Text('PDF Selected', style: AppTypography.h3),
          content: Text(
            'PDF file selected. Please enter bill details manually.',
            style: AppTypography.body,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _originalFile = null;
                  _isPdf = false;
                });
                _showImageSourceModal();
              },
              child: const Text('TRY AGAIN'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showVerificationDialog(Map<String, String> details) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Text('We scanned your bill', style: AppTypography.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merchant: ${details['title']?.isNotEmpty == true ? details['title'] : "Not found"}',
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                'Amount: ${details['amount']?.isNotEmpty == true ? "\$${details['amount']}" : "Not found"}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _selectedImage = null);
                _showImageSourceModal();
              },
              child: const Text('✏ Edit'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                if (details['title']!.isNotEmpty) {
                  _titleController.text = details['title']!;
                }
                if (details['amount']!.isNotEmpty) {
                  _amountController.text = details['amount']!;
                }
              },
              child: const Text('✔ Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt, color: AppColors.primary),
                  title: Text('Camera', style: AppTypography.body),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: AppColors.primary),
                  title: Text('Gallery', style: AppTypography.body),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: AppColors.danger),
                  title: Text('Upload PDF', style: AppTypography.body),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPDF();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null && _originalFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image or PDF')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final appDir = await getApplicationDocumentsDirectory();
      String savedImagePath;
      String? savedOriginalPath;

      if (_isPdf && _originalFile != null) {
        final pdfFileName = '${const Uuid().v4()}.pdf';
        final savedPdf = await _originalFile!.copy(
          '${appDir.path}/$pdfFileName',
        );
        savedOriginalPath = savedPdf.path;
        savedImagePath = savedPdf.path;
      } else if (_selectedImage != null) {
        final imageFileName = '${const Uuid().v4()}.jpg';
        final savedImage = await _selectedImage!.copy(
          '${appDir.path}/$imageFileName',
        );
        savedImagePath = savedImage.path;
      } else {
        throw Exception('No file selected');
      }

      final newBill = Bill(
        id: const Uuid().v4(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        imagePath: savedImagePath,
        category: _categoryController.text.isEmpty
            ? 'General'
            : _categoryController.text,
        originalFilePath: savedOriginalPath,
      );

      if (mounted) {
        await Provider.of<BillProvider>(
          context,
          listen: false,
        ).addBill(newBill);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving bill: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('Add Bill', style: AppTypography.h2),
        backgroundColor: AppColors.bgMain,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Capture Card
              GestureDetector(
                onTap: _showImageSourceModal,
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: _selectedImage != null || _isPdf
                        ? AppColors.bgCard
                        : AppColors.bgInput,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: AppColors.borderDashed,
                      width: 2,
                      style: _selectedImage == null && !_isPdf
                          ? BorderStyle.solid
                          : BorderStyle.none,
                    ),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _isScanning
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: AppSpacing.space2),
                              Text(
                                "Scanning bill...",
                                style: AppTypography.body,
                              ),
                            ],
                          ),
                        )
                      : (_selectedImage == null && !_isPdf
                            ? Padding(
                                padding: const EdgeInsets.all(
                                  AppSpacing.space6,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 50,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: AppSpacing.space3),
                                    Text(
                                      'Tap to upload bill',
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'or use your camera',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.space5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            _pickImage(ImageSource.camera);
                                          },
                                          icon: const Icon(
                                            Icons.camera_alt,
                                            size: 18,
                                          ),
                                          label: const Text('Take Photo'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            side: const BorderSide(
                                              color: AppColors.primary,
                                              width: 1.5,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.space4,
                                              vertical: AppSpacing.space3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: AppSpacing.space3,
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            _pickImage(ImageSource.gallery);
                                          },
                                          icon: const Icon(
                                            Icons.photo_library,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            'Select from Gallery',
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            side: const BorderSide(
                                              color: AppColors.primary,
                                              width: 1.5,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.space4,
                                              vertical: AppSpacing.space3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : _isPdf
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf,
                                      size: 50,
                                      color: AppColors.danger,
                                    ),
                                    const SizedBox(height: AppSpacing.space2),
                                    Text(
                                      'PDF Selected',
                                      style: AppTypography.body,
                                    ),
                                  ],
                                ),
                              )
                            : null),
                ),
              ),
              const SizedBox(height: AppSpacing.space6),

              // Merchant Field
              TextFormField(
                controller: _titleController,
                style: AppTypography.body,
                decoration: InputDecoration(
                  labelText: 'Merchant',
                  labelStyle: AppTypography.caption,
                  prefixIcon: Icon(Icons.store, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.bgInput,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter merchant name' : null,
              ),
              const SizedBox(height: AppSpacing.space4),

              // Amount and Date Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppTypography.body,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: AppTypography.caption,
                        prefixText: '\$ ',
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: AppColors.bgInput,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter amount' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          labelStyle: AppTypography.caption,
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                          ),
                          filled: true,
                          fillColor: AppColors.bgInput,
                        ),
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: AppTypography.body,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space4),

              // Category Field
              TextFormField(
                controller: _categoryController,
                style: AppTypography.body,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: AppTypography.caption,
                  prefixIcon: Icon(Icons.category, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.bgInput,
                ),
              ),
              const SizedBox(height: AppSpacing.space7),

              // Save Button with Gradient
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.floatingButton,
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, color: Colors.white),
                            const SizedBox(width: AppSpacing.space2),
                            Text(
                              'Save Bill',
                              style: AppTypography.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
