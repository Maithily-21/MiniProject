import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/primary_button.dart';

class PatientRegistrationScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const PatientRegistrationScreen({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final patient = context.read<AppProvider>().patient;
    final hasSavedData = patient.name.isNotEmpty ||
        patient.age.isNotEmpty ||
        patient.phone.isNotEmpty;

    _nameController.text = patient.name;
    _ageController.text = patient.age;
    _phoneController.text = patient.phone;
    _selectedGender = hasSavedData
        ? (patient.gender.isNotEmpty ? patient.gender : null)
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final patient = PatientModel(
        name: _nameController.text,
        gender: _selectedGender ?? '',
        age: _ageController.text,
        phone: _phoneController.text,
      );
      context.read<AppProvider>().updatePatient(patient);
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(title: 'Patient Details', onBack: widget.onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'YOUR INFORMATION',
                    style: TextStyle(
                      color: AppColors.primaryEnd,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FormField(
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                    hintText: 'Full Name',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  _GenderDropdown(
                    value: _selectedGender,
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    controller: _ageController,
                    icon: Icons.calendar_today_outlined,
                    hintText: 'Age',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Age is required';
                      }
                      final age = int.tryParse(v);
                      if (age == null || age < 1 || age > 120) {
                        return 'Enter valid age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    hintText: 'Contact Number',
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Phone is required' : null,
                  ),
                  const SizedBox(height: 36),
                  PrimaryButton(
                    label: 'Continue to Photo',
                    onTap: _submit,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
              color: Color(0x061E60DC), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                errorStyle: const TextStyle(fontSize: 11),
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _GenderDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
              color: Color(0x061E60DC), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          const Icon(Icons.group_outlined,
              color: AppColors.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                onChanged: onChanged,
                hint: const Text(
                  'Select Gender',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textLight),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
