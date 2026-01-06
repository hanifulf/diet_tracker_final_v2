import 'package:flutter/material.dart';
import 'dart:io';
import '../../utils/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/food_entry_model.dart';
import 'package:provider/provider.dart';
import '../../providers/food_provider.dart';
import '../../widgets/custom_text_field.dart';

class FoodLoggingScreen extends StatefulWidget {
  final UserModel user;
  final File imageFile;
  final Map<String, dynamic> foodAnalysis;

  const FoodLoggingScreen({
    super.key,
    required this.user,
    required this.imageFile,
    required this.foodAnalysis,
  });

  @override
  State<FoodLoggingScreen> createState() => _FoodLoggingScreenState();
}

class _FoodLoggingScreenState extends State<FoodLoggingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _carbsController;
  late TextEditingController _proteinsController;
  late TextEditingController _fatsController;
  late TextEditingController _servingSizeController;

  String _selectedMealType = 'Makan Siang';
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

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

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.foodAnalysis['name']);
    _caloriesController = TextEditingController(
      text: widget.foodAnalysis['calories'].toString(),
    );
    _carbsController = TextEditingController(
      text: widget.foodAnalysis['carbohydrates'].toString(),
    );
    _proteinsController = TextEditingController(
      text: widget.foodAnalysis['proteins'].toString(),
    );
    _fatsController = TextEditingController(
      text: widget.foodAnalysis['fats'].toString(),
    );
    _servingSizeController = TextEditingController(
      text: widget.foodAnalysis['serving_size'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundNeutral,
      appBar: AppBar(
        title: Text(
          'Tambah ke Log Makanan',
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
              // Food image preview
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10.0,
                      offset: const Offset(0, 4.0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  child: Image.file(widget.imageFile, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // Food details section
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

              // Nutrition information section
              _buildSectionTitle('Informasi Gizi'),
              const SizedBox(height: AppTheme.spacingM),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _caloriesController,
                      hintText: 'Kalori (kcal)',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.local_fire_department_rounded,
                    ),
                  ),
                ],
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

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _fatsController,
                      hintText: 'Lemak (g)',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.water_drop_rounded,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Container(), // Empty space for symmetry
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // Meal timing section
              _buildSectionTitle('Waktu Makan'),
              const SizedBox(height: AppTheme.spacingM),

              // Meal type selector
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jenis Makan',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Date and time selector
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
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded),
                            const SizedBox(width: AppTheme.spacingS),
                            const Text(
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
            : AppTheme.primaryGreen.withValues(alpha: 0.3),
      ),
      showCheckmark: false,
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
      // Simulate saving to database
      await Future.delayed(const Duration(seconds: 1));

      // Create food entry model
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
        imagePath: widget.imageFile.path,
      );

      // Save to Provider
      if (mounted) {
        await Provider.of<FoodProvider>(
          context,
          listen: false,
        ).addFoodEntry(foodEntry);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${foodEntry.foodName} berhasil ditambahkan ke log makanan!',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );

        // Navigate back to main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
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
