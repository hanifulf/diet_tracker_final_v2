import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_theme.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/selection_card.dart';
import '../../models/UserStorage.dart';
import 'package:path_provider/path_provider.dart';


class ProfileEditScreen extends StatefulWidget {
  final UserModel user;

  const ProfileEditScreen({super.key, required this.user});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;

  late String _selectedGender;
  bool _hasChanges = false;
  File? _profileImageFile; // <- file sementara sebelum disimpan

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.user.name);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _heightController = TextEditingController(
      text: widget.user.height.toStringAsFixed(0),
    );
    _weightController = TextEditingController(
      text: widget.user.currentWeight.toStringAsFixed(1),
    );
    _targetWeightController = TextEditingController(
      text: widget.user.targetWeight.toStringAsFixed(1),
    );
    _selectedGender = widget.user.gender;

    // Listener
    _nameController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
    _heightController.addListener(_onFieldChanged);
    _weightController.addListener(_onFieldChanged);
    _targetWeightController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundNeutral,
      appBar: AppBar(
        title: Text(
          'Edit Profil',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.primaryGreen),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: _onBackPressed,
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.primaryGreen),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryGreen,
                            AppTheme.accentTeaGreen,
                          ],
                        ),
                      ),
                      child: ClipOval(
                        child: _profileImageFile != null
                            ? Image.file(_profileImageFile!, fit: BoxFit.cover)
                            : widget.user.profileImagePath != null
                            ? Image.file(
                                File(widget.user.profileImagePath!),
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _changeProfilePicture,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),

              // Personal Info
              _buildSectionTitle('Informasi Pribadi'),
              const SizedBox(height: AppTheme.spacingM),
              CustomTextField(
                controller: _nameController,
                hintText: 'Masukkan nama lengkap',
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Gender
              Text(
                'Jenis Kelamin',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: SelectionCard(
                      title: 'Laki-laki',
                      icon: Icons.male_rounded,
                      isSelected: _selectedGender == 'Laki-laki',
                      onTap: () {
                        setState(() {
                          _selectedGender = 'Laki-laki';
                          _hasChanges = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: SelectionCard(
                      title: 'Perempuan',
                      icon: Icons.female_rounded,
                      isSelected: _selectedGender == 'Perempuan',
                      onTap: () {
                        setState(() {
                          _selectedGender = 'Perempuan';
                          _hasChanges = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),

              Text(
                'Umur',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              CustomTextField(
                controller: _ageController,
                hintText: 'Masukkan umur (tahun)',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // Physical Info
              _buildSectionTitle('Informasi Fisik'),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Tinggi Badan',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              CustomTextField(
                controller: _heightController,
                hintText: 'Masukkan tinggi badan (cm)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Berat Badan',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              CustomTextField(
                controller: _weightController,
                hintText: 'Masukkan berat badan saat ini (kg)',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'Target ',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              CustomTextField(
                controller: _targetWeightController,
                hintText: 'Masukkan target berat badan (kg)',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXXL),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _hasChanges ? _saveChanges : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasChanges
                        ? AppTheme.primaryGreen
                        : AppTheme.textSecondary.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                  ),
                  child: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.headingSmall.copyWith(
        color: AppTheme.primaryGreen,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ----------------------------
  // Pick Image Functions
  // ----------------------------
  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Ganti Foto Profil',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  Icons.camera_alt_rounded,
                  'Kamera',
                  () => _pickImage(ImageSource.camera),
                ),
                _buildPhotoOption(
                  Icons.photo_library_rounded,
                  'Galeri',
                  () => _pickImage(ImageSource.gallery),
                ),
                _buildPhotoOption(
                  Icons.delete_rounded,
                  'Hapus',
                  _removeProfileImage,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryGreen),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
        _hasChanges = true;
      });
    }
  }

  void _removeProfileImage() {
    setState(() {
      _profileImageFile = null;
      widget.user.profileImagePath = null;
      _hasChanges = true;
    });
  }

  // ----------------------------
  // Save Changes
  // ----------------------------
  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      String? savedPath = widget.user.profileImagePath;

      if (_profileImageFile != null) {
        savedPath = await _saveImageToLocalDir(_profileImageFile!);
      }

      final updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        gender: _selectedGender,
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        currentWeight: double.parse(_weightController.text),
        targetWeight: double.parse(_targetWeightController.text),
        updatedAt: DateTime.now(),
        profileImagePath: savedPath,
      );

      await UserStorage.saveUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      Navigator.pop(context, updatedUser);
    }
  }

  Future<String> _saveImageToLocalDir(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.png';
    final savedImage = await imageFile.copy('${appDir.path}/$fileName');
    return savedImage.path;
  }

  void _onBackPressed() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          title: Text(
            'Simpan Perubahan?',
            style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryGreen),
          ),
          content: Text(
            'Anda memiliki perubahan yang belum disimpan. Apakah Anda ingin menyimpannya?',
            style: AppTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Buang', style: TextStyle(color: AppTheme.errorRed)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveChanges();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }
}
