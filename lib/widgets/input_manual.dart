import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/food_entry_model.dart';
import 'package:provider/provider.dart';
import '../../providers/food_provider.dart';
import '../../widgets/custom_text_field.dart';

class InputManualScreen extends StatefulWidget {
  final UserModel user;

  const InputManualScreen({super.key, required this.user});

  @override
  State<InputManualScreen> createState() => _InputManualScreenState();
}

class _InputManualScreenState extends State<InputManualScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _carbsController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _servingSizeController = TextEditingController();

  String _selectedMealType = 'Makan Siang';
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;
  String? _selectedImagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _carbsController.dispose();
    _proteinsController.dispose();
    _fatsController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundNeutral,
      appBar: AppBar(
        title: Text(
          'Input Manual',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.primaryGreen),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
              // Area gambar
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Center(
                    child: _selectedImagePath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 50,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambah Foto',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusL,
                            ),
                            child: Image.file(
                              File(_selectedImagePath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingXL),

              _buildSectionTitle('Detail Makanan'),
              const SizedBox(height: AppTheme.spacingM),

              CustomTextField(
                controller: _nameController,
                hintText: 'Nama makanan',
                prefixIcon: Icons.restaurant_rounded,
              ),

              const SizedBox(height: AppTheme.spacingL),

              CustomTextField(
                controller: _servingSizeController,
                hintText: 'Ukuran porsi (contoh: 1 porsi, 250g)',
                prefixIcon: Icons.straighten_rounded,
              ),

              const SizedBox(height: AppTheme.spacingXL),

              _buildSectionTitle('Informasi Gizi'),
              const SizedBox(height: AppTheme.spacingM),

              CustomTextField(
                controller: _caloriesController,
                hintText: 'Kalori (kcal)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.local_fire_department_rounded,
              ),

              const SizedBox(height: AppTheme.spacingL),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _carbsController,
                      hintText: 'Karbohidrat (g)',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.grain_rounded,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: CustomTextField(
                      controller: _proteinsController,
                      hintText: 'Protein (g)',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.fitness_center_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingL),

              CustomTextField(
                controller: _fatsController,
                hintText: 'Lemak (g)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.water_drop_rounded,
              ),

              const SizedBox(height: AppTheme.spacingXL),

              _buildSectionTitle('Waktu Makan'),
              const SizedBox(height: AppTheme.spacingM),

              Wrap(
                spacing: AppTheme.spacingS,
                children: [
                  'Sarapan',
                  'Makan Siang',
                  'Makan Malam',
                  'Camilan',
                ].map((type) => _buildMealTypeChip(type)).toList(),
              ),

              const SizedBox(height: AppTheme.spacingXL),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waktu Konsumsi',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundNeutral,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusM,
                                ),
                                border: Border.all(
                                  color: AppTheme.dividerColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: AppTheme.primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppTheme.spacingS),
                                  Text(
                                    _formatDate(_selectedDateTime),
                                    style: AppTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: GestureDetector(
                            onTap: _selectTime,
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundNeutral,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusM,
                                ),
                                border: Border.all(
                                  color: AppTheme.dividerColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    color: AppTheme.primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppTheme.spacingS),
                                  Text(
                                    _formatTime(_selectedDateTime),
                                    style: AppTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXXL),
              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFoodEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.save_rounded),
                            SizedBox(width: 8),
                            Text(
                              'Simpan ke Log Makanan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

  Widget _buildMealTypeChip(String type) {
    final isSelected = _selectedMealType == type;
    return FilterChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedMealType = type;
        });
      },
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.primaryGreen,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? AppTheme.primaryGreen
            : AppTheme.primaryGreen.withOpacity(0.3),
      ),
      showCheckmark: false,
    );
  }

  void _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil dari Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedImagePath = picked.path;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedImagePath = picked.path;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: AppTheme.cardBackground,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: AppTheme.cardBackground,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _saveFoodEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      final foodEntry = FoodEntryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.user.id,
        foodName: _nameController.text.trim(),
        calories: double.tryParse(_caloriesController.text) ?? 0,
        carbohydrates: double.tryParse(_carbsController.text) ?? 0,
        proteins: double.tryParse(_proteinsController.text) ?? 0,
        fats: double.tryParse(_fatsController.text) ?? 0,
        consumedAt: _selectedDateTime,
        createdAt: DateTime.now(),
        imagePath: _selectedImagePath,
      );

      if (mounted) {
        await Provider.of<FoodProvider>(context, listen: false)
            .addFoodEntry(foodEntry);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${foodEntry.foodName} Berhasil ditambahkan ke Log Makanan!',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan makanan: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Hari Ini';
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return 'Kemarin';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
