import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onEditTap;

  const ProfileHeader({super.key, required this.user, this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration.copyWith(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.1),
            AppTheme.accentTeaGreen.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          // ===== PROFILE IMAGE =====
          Stack(
            children: [
              _buildProfileImage(),

              if (onEditTap != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onEditTap,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: AppTheme.spacingL),

          // ===== USER INFO =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  _getGenderText(user.gender),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Row(
                  children: [
                    _buildStatItem('Umur', '${user.age}'),
                    const SizedBox(width: AppTheme.spacingL),
                    _buildStatItem(
                      'Tinggi',
                      '${user.height.toStringAsFixed(0)} cm',
                    ),
                    const SizedBox(width: AppTheme.spacingL),
                    _buildStatItem(
                      'Berat',
                      '${user.currentWeight.toStringAsFixed(1)} kg',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================
  // PROFILE IMAGE HANDLER (AMAN TOTAL)
  // ===================================================

  Widget _buildProfileImage() {
    final String? path = user.profileImagePath;
    final bool hasValidImage =
        path != null && path.isNotEmpty && File(path).existsSync();

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryGreen, AppTheme.accentTeaGreen],
        ),
      ),
      child: ClipOval(
        child: hasValidImage
            ? Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _defaultAvatar(),
              )
            : _defaultAvatar(),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: 42,
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }

  // ===================================================
  // HELPERS
  // ===================================================

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getGenderText(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
      case 'laki-laki':
        return 'Laki-laki';
      case 'female':
      case 'perempuan':
        return 'Perempuan';
      default:
        return gender;
    }
  }
}
