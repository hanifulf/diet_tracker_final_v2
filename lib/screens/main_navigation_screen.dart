import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/user_model.dart';
import 'home/beranda_screen.dart';
import 'statistics/statistik_screen.dart';
import 'history/riwayat_screen.dart';
import 'settings/pengaturan_screen.dart';
import 'scan/scan_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserModel user;

  const MainNavigationScreen({super.key, required this.user});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      BerandaScreen(user: widget.user),
      StatistikScreen(user: widget.user),
      // ❌ Hapus ScanScreen dari stack (biar gak tampil di bawah)
      RiwayatScreen(user: widget.user),
      PengaturanScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // 📸 Kalau index 2 (tombol kamera), buka ScanScreen full screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanScreen(user: widget.user),
              ),
            );
          } else {
            // Index yang lain tetap normal
            setState(() {
              // Karena ScanScreen dihapus dari list, kita geser index di bawah ini
              _currentIndex = index > 2 ? index - 1 : index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.cardBackground,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Statistik',
          ),
          // === Tombol Kamera (khusus buka layar baru) ===
          BottomNavigationBarItem(
            icon: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            activeIcon: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            activeIcon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            activeIcon: Icon(Icons.settings_rounded),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
