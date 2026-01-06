import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';

class CalorieProgressCircle extends StatefulWidget {
  final double currentCalories;
  final double targetCalories;
  final double currentCarbs;
  final double currentProteins;
  final double currentFats;

  const CalorieProgressCircle({
    super.key,
    required this.currentCalories,
    required this.targetCalories,
    required this.currentCarbs,
    required this.currentProteins,
    required this.currentFats,
  });

  @override
  State<CalorieProgressCircle> createState() => _CalorieProgressCircleState();
}

class _CalorieProgressCircleState extends State<CalorieProgressCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation =
        Tween<double>(
          begin: 0.0,
          end: widget.currentCalories / widget.targetCalories,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(CalorieProgressCircle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentCalories != widget.currentCalories ||
        oldWidget.targetCalories != widget.targetCalories) {
      _progressAnimation =
          Tween<double>(
            begin: _progressAnimation.value,
            end: widget.currentCalories / widget.targetCalories,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            ),
          );

      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.currentCalories / widget.targetCalories;
    final remainingCalories = widget.targetCalories - widget.currentCalories;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress Circle
        SizedBox(
          width: 92,
          height: 92,
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: CalorieProgressPainter(
                  progress: _progressAnimation.value,
                  strokeWidth: 10,
                  backgroundColor: AppTheme.dividerColor,
                  progressColor: _getProgressColor(progress),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.currentCalories.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      Text(
                        'dari ${widget.targetCalories.toStringAsFixed(0)}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Status text (Sisa / Tercapai / Kelebihan)
        Text(
          _getStatusText(remainingCalories),
          style: AppTheme.bodySmall.copyWith(
            fontSize: 10,
            color: _getStatusColor(progress),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress <= 0.5) {
      return AppTheme.errorRed;
    } else if (progress <= 0.8) {
      return AppTheme.warningOrange;
    } else if (progress <= 1.0) {
      return AppTheme.primaryGreen;
    } else {
      return AppTheme.successGreen;
    }
  }

  Color _getStatusColor(double progress) {
    if (progress <= 0.5) {
      return AppTheme.errorRed;
    } else if (progress <= 0.8) {
      return AppTheme.warningOrange;
    } else if (progress <= 1.0) {
      return AppTheme.primaryGreen;
    } else {
      return AppTheme.warningOrange;
    }
  }

  String _getStatusText(double remainingCalories) {
    if (remainingCalories > 0) {
      return 'Sisa ${remainingCalories.toStringAsFixed(0)} kalori lagi';
    } else if (remainingCalories == 0) {
      return 'Target kalori tercapai! 🎉';
    } else {
      return 'Kelebihan ${remainingCalories.abs().toStringAsFixed(0)} kalori';
    }
  }
}

class CalorieProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  CalorieProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // mulai dari atas
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CalorieProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
