import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';

class WaterIntakeCard extends StatefulWidget {
  final double currentIntake;
  final double targetIntake;
  final Function(double) onAddWater;

  const WaterIntakeCard({
    super.key,
    required this.currentIntake,
    required this.targetIntake,
    required this.onAddWater,
  });

  @override
  State<WaterIntakeCard> createState() => _WaterIntakeCardState();
}

class _WaterIntakeCardState extends State<WaterIntakeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAddWaterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddWaterBottomSheet(),
    );
  }

  Widget _buildAddWaterBottomSheet() {
    final quickAmounts = [250, 500, 750, 1000];

    return Container(
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
            'Tambah Air Minum',
            style: AppTheme.headingSmall.copyWith(
              color: const Color(0xFF60A5FA),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacingM,
              mainAxisSpacing: AppTheme.spacingM,
              childAspectRatio: 2.5,
            ),
            itemCount: quickAmounts.length,
            itemBuilder: (context, index) {
              final amount = quickAmounts[index];
              return ElevatedButton(
                onPressed: () {
                  widget.onAddWater(amount.toDouble());
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF60A5FA,
                  ).withValues(alpha: 0.1),
                  foregroundColor: const Color(0xFF60A5FA),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    side: BorderSide(
                      color: const Color(0xFF60A5FA).withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_drink_rounded, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      '${amount}ml',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingL),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.currentIntake / widget.targetIntake;
    final remainingIntake = widget.targetIntake - widget.currentIntake;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingL,
        AppTheme.spacingS,
        AppTheme.spacingL,
        AppTheme.spacingL,
      ),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Asupan Air Harian',
                style: AppTheme.headingSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF60A5FA),
                ),
              ),
              IconButton(
                onPressed: _showAddWaterBottomSheet,
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: Color(0xFF60A5FA),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),

          // Water glass visualization
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 60,
                child: AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: FlatWaterGlassPainter(
                        fillLevel: progress.clamp(0.0, 1.0),
                        waveOffset: _waveAnimation.value,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.currentIntake.toStringAsFixed(0)}ml',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF60A5FA),
                          ),
                        ),
                        Text(
                          'dari ${widget.targetIntake.toStringAsFixed(0)}ml',
                          style: AppTheme.bodyMedium.copyWith(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.dividerColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2563EB), // biru tua
                                  Color(0xFF60A5FA), // biru muda
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      remainingIntake > 0
                          ? 'Sisa ${remainingIntake.toStringAsFixed(0)}ml lagi'
                          : 'Target tercapai! 🎉',
                      style: AppTheme.bodySmall.copyWith(
                        color: remainingIntake > 0
                            ? AppTheme.textSecondary
                            : const Color(0xFF60A5FA),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 🎨 Bentuk gelas datar realistis dengan dasar tebal dan animasi air
class FlatWaterGlassPainter extends CustomPainter {
  final double fillLevel;
  final double waveOffset;

  FlatWaterGlassPainter({required this.fillLevel, required this.waveOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF60A5FA);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF60A5FA).withValues(alpha: 0.3);

    // Bentuk gelas datar (atas sedikit melengkung, bawah tebal)
    final path = Path();

    final topCurveHeight = 4.0;
    final bottomThickness = 3.0;

    // Lebar bawah lebih kecil
    final bottomWidthFactor =
        0.7; // ubah antara 0.5–0.9 untuk menyesuaikan seberapa sempit bawahnya

    // Garis atas (melengkung ringan)
    path.moveTo(0, topCurveHeight);
    path.quadraticBezierTo(size.width / 2, 0, size.width, topCurveHeight);

    // Sisi kanan menurun ke bawah dengan sedikit menyempit
    path.lineTo(
      size.width * (1 - (1 - bottomWidthFactor) / 2),
      size.height - bottomThickness,
    );

    // Dasar gelas menyempit dan sedikit tebal
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width * ((1 - bottomWidthFactor) / 2),
      size.height - bottomThickness,
    );

    // Sisi kiri naik kembali ke atas
    path.close();

    // Gambar outline gelas
    canvas.drawPath(path, borderPaint);

    if (fillLevel > 0) {
      final waterHeight = size.height * fillLevel;
      final waterY = size.height - waterHeight;

      final waterPath = Path();
      waterPath.moveTo(0, size.height);

      // Gelombang di permukaan air
      final waveAmplitude = 2.0;
      final waveFrequency = 2.0;

      for (double x = 0; x <= size.width; x++) {
        final normalizedX = x / size.width;
        final wave =
            waveAmplitude *
            math.sin(
              waveFrequency * math.pi * normalizedX + waveOffset * 2 * math.pi,
            );
        waterPath.lineTo(x, waterY + wave);
      }

      waterPath.lineTo(size.width, size.height);
      waterPath.close();

      // Potong area air agar tetap di dalam gelas
      canvas.save();
      canvas.clipPath(path);
      canvas.drawPath(waterPath, fillPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(FlatWaterGlassPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
        oldDelegate.waveOffset != waveOffset;
  }
}
