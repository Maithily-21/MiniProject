import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../services/backend_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/primary_button.dart';

class UploadScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onAnalyze;

  const UploadScreen({
    super.key,
    required this.onBack,
    required this.onAnalyze,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFile;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _selectedFile = picked;
      _errorMessage = null;
    });

    await _uploadAndAnalyze();
  }

  Future<void> _uploadAndAnalyze() async {
    if (_selectedFile == null) return;

    setState(() => _isLoading = true);
    try {
      final result =
          await BackendService.analyzeImage(File(_selectedFile!.path));
      if (!mounted) return;
      context.read<AppProvider>().setAnalysisResult(result);
      widget.onAnalyze();
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(title: 'Analyzing Image...', onBack: widget.onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x221E60DC),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _selectedFile == null
                          ? Image.network(
                              'https://images.unsplash.com/photo-1544253303-62505c8623b2?q=80&w=600&auto=format&fit=crop',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surfaceLight,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: AppColors.textLight,
                                    size: 64,
                                  ),
                                ),
                              ),
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: AppColors.surfaceLight,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryEnd,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Image.file(
                              File(_selectedFile!.path),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                ],
                PrimaryButton(
                  label: _isLoading ? 'Analyzing...' : 'Take a Photo',
                  icon: const Icon(Icons.camera_alt_outlined,
                      color: Colors.white, size: 22),
                  onTap:
                      _isLoading ? null : () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: _isLoading ? 'Analyzing...' : 'Choose from Gallery',
                  icon: const Icon(Icons.photo_library_outlined,
                      color: Colors.white, size: 22),
                  gradient: AppColors.primaryGradient2,
                  onTap:
                      _isLoading ? null : () => _pickImage(ImageSource.gallery),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Tips for Best Results',
                  style: TextStyle(
                    color: AppColors.primaryEnd,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...[
                  'Face camera directly',
                  'Smile clearly showing your teeth',
                  'Ensure even lighting',
                ].map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
