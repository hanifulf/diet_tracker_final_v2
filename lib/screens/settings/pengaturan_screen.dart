import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_preferences.dart';
import '../../models/user_model.dart';
import '../../widgets/settings_section.dart';
import '../../widgets/settings_tile.dart';
import '../../widgets/profile_header.dart';
import 'profile_edit_screen.dart';
import '../../main.dart';

class PengaturanScreen extends StatefulWidget {
  final UserModel user;

  const PengaturanScreen({super.key, required this.user});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Bahasa Indonesia';
  String _selectedUnit = 'Metrik (kg, cm)';

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  // Async load dark mode preference
  void _loadDarkModePreference() async {
    final isDark = await ThemePreferences.loadTheme();
    setState(() {
      _darkModeEnabled = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundNeutral,
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.primaryGreen),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            ProfileHeader(user: widget.user),

            const SizedBox(height: AppTheme.spacingXL),

            // Account Section
            SettingsSection(
              title: 'Akun',
              children: [
                SettingsTile(
                  icon: Icons.person_rounded,
                  title: 'Edit Profil',
                  subtitle: 'Ubah informasi pribadi',
                  onTap: _navigateToProfileEdit,
                ),
                // SettingsTile(
                //   icon: Icons.track_changes_rounded,
                //   title: 'Target & Tujuan',
                //   subtitle: 'Atur target kalori dan berat badan',
                //   onTap: _showTargetSettings,
                // ),
                SettingsTile(
                  icon: Icons.history_rounded,
                  title: 'Riwayat Data',
                  subtitle: 'Lihat dan kelola data historis',
                  onTap: _showDataHistory,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingL),

            // App Preferences Section
            SettingsSection(
              title: 'Preferensi Aplikasi',
              children: [
                SettingsTile(
                  icon: Icons.notifications_rounded,
                  title: 'Notifikasi',
                  subtitle: _notificationsEnabled ? 'Aktif' : 'Nonaktif',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeColor: AppTheme.primaryGreen,
                  ),
                ),
                SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Mode Gelap',
                  subtitle: _darkModeEnabled ? 'Aktif' : 'Nonaktif',
                  trailing: Switch(
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });

                      // 🔑 Ganti tema via ThemeController
                      ThemeController.of(context).changeTheme(value);
                    },
                    activeColor: AppTheme.primaryGreen,
                  ),
                ),
                SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Bahasa',
                  subtitle: _selectedLanguage,
                  onTap: _showLanguageSelector,
                ),
                SettingsTile(
                  icon: Icons.straighten_rounded,
                  title: 'Unit Pengukuran',
                  subtitle: _selectedUnit,
                  onTap: _showUnitSelector,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Security Section
            // SettingsSection(
            //   title: 'Keamanan & Privasi',
            //   children: [
            //     SettingsTile(
            //       icon: Icons.fingerprint_rounded,
            //       title: 'Biometrik',
            //       subtitle: _biometricEnabled ? 'Aktif' : 'Nonaktif',
            //       trailing: Switch(
            //         value: _biometricEnabled,
            //         onChanged: (value) {
            //           setState(() {
            //             _biometricEnabled = value;
            //           });
            //           _showComingSoonSnackBar('Autentikasi Biometrik');
            //         },
            //         activeColor: AppTheme.primaryGreen,
            //       ),
            //     ),
            //     SettingsTile(
            //       icon: Icons.lock_rounded,
            //       title: 'Ubah PIN',
            //       subtitle: 'Ganti kode keamanan aplikasi',
            //       onTap: () => _showComingSoonSnackBar('Ubah PIN'),
            //     ),
            //     SettingsTile(
            //       icon: Icons.privacy_tip_rounded,
            //       title: 'Kebijakan Privasi',
            //       subtitle: 'Baca kebijakan privasi kami',
            //       onTap: _showPrivacyPolicy,
            //     ),
            //   ],
            // ),
            // const SizedBox(height: AppTheme.spacingL),

            // Data Management Section
            SettingsSection(
              title: 'Pengelolaan Data',
              children: [
                SettingsTile(
                  icon: Icons.backup_rounded,
                  title: 'Backup Data',
                  subtitle: 'Cadangkan data ke cloud',
                  onTap: () => _showComingSoonSnackBar('Backup Data'),
                ),
                SettingsTile(
                  icon: Icons.download_rounded,
                  title: 'Export Data',
                  subtitle: 'Unduh data dalam format CSV',
                  onTap: _exportData,
                ),
                SettingsTile(
                  icon: Icons.delete_forever_rounded,
                  title: 'Hapus Semua Data',
                  subtitle: 'Hapus permanen semua data',
                  onTap: _showDeleteAllDataDialog,
                  textColor: AppTheme.errorRed,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Support Section
            SettingsSection(
              title: 'Dukungan',
              children: [
                SettingsTile(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Kebijakan Privasi',
                  subtitle: 'Baca kebijakan privasi kami',
                  onTap: _showPrivacyPolicy,
                ),
                SettingsTile(
                  icon: Icons.help_rounded,
                  title: 'Bantuan & FAQ',
                  subtitle: 'Dapatkan bantuan penggunaan aplikasi',
                  onTap: _showHelp,
                ),
                SettingsTile(
                  icon: Icons.feedback_rounded,
                  title: 'Kirim Masukan',
                  subtitle: 'Berikan feedback untuk aplikasi',
                  onTap: _showFeedbackForm,
                ),
                SettingsTile(
                  icon: Icons.info_rounded,
                  title: 'Tentang Aplikasi',
                  subtitle: 'Versi 1.0.0',
                  onTap: _showAboutDialog,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _showLogoutDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorRed,
                  side: BorderSide(color: AppTheme.errorRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded),
                    const SizedBox(width: AppTheme.spacingS),
                    const Text(
                      'Keluar',
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
    );
  }

  void _navigateToProfileEdit() async {
    final updatedUser = await Navigator.of(context).push<UserModel>(
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(user: widget.user),
      ),
    );

    if (updatedUser != null) {
      setState(() {
        widget.user.updateFrom(updatedUser);
      });
    }
  }

  void _showTargetSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildTargetSettingsSheet(),
    );
  }

  void _showDataHistory() {
    _showComingSoonSnackBar('Riwayat Data');
  }

  void _showLanguageSelector() {
    final languages = ['Bahasa Indonesia', 'English'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          'Pilih Bahasa',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryGreen),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              activeColor: AppTheme.primaryGreen,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.of(context).pop();
                if (language != 'Bahasa Indonesia') {
                  _showComingSoonSnackBar('Bahasa $language');
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUnitSelector() {
    final units = ['Metrik (kg, cm)', 'Imperial (lbs, ft)'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          'Unit Pengukuran',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryGreen),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: units.map((unit) {
            return RadioListTile<String>(
              title: Text(unit),
              value: unit,
              groupValue: _selectedUnit,
              activeColor: AppTheme.primaryGreen,
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value!;
                });
                Navigator.of(context).pop();
                if (unit != 'Metrik (kg, cm)') {
                  _showComingSoonSnackBar('Unit Imperial');
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          'Kebijakan Privasi',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryGreen),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Santapora menghormati privasi pengguna dan berkomitmen untuk melindungi data pribadi Anda.\n\n'
            '• Data makanan dan kesehatan disimpan secara lokal di perangkat Anda\n'
            '• Kami tidak membagikan informasi pribadi kepada pihak ketiga\n'
            '• Fitur backup bersifat opsional dan dienkripsi\n'
            '• Anda dapat menghapus semua data kapan saja\n\n'
            'Untuk informasi lengkap, kunjungi website kami.',
            style: AppTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tutup',
              style: TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          'Export Data',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryGreen),
        ),
        content: Text(
          'Data Anda akan diekspor dalam format CSV dan disimpan ke folder Download.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoonSnackBar('Export Data');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          'Hapus Semua Data',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.errorRed),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus SEMUA data? Tindakan ini tidak dapat dibatalkan.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoonSnackBar('Hapus Semua Data');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    _showComingSoonSnackBar('Bantuan & FAQ');
  }

  void _showFeedbackForm() {
    _showComingSoonSnackBar('Kirim Masukan');
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Santapora',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
        ),
      ),
      children: [
        Text(
          'Aplikasi pelacak diet yang membantu Anda mencapai tujuan kesehatan dengan mudah dan menyenangkan.',
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          'Keluar Aplikasi',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.errorRed),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoonSnackBar('Logout');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSettingsSheet() {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusL),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          Text(
            'Target & Tujuan',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.primaryGreen,
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Current targets display
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Column(
              children: [
                _buildTargetRow(
                  'Target Kalori Harian',
                  '${widget.user.dailyCalorieTarget.toStringAsFixed(0)} kcal',
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildTargetRow(
                  'Target Berat Badan',
                  '${widget.user.targetWeight.toStringAsFixed(1)} kg',
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildTargetRow(
                  'Target Air Harian',
                  '${widget.user.dailyWaterTarget.toStringAsFixed(0)} ml',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoonSnackBar('Edit Target');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Edit Target'),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan segera hadir!'),
        backgroundColor: AppTheme.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
