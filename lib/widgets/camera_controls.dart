import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onFlashToggle;
  final VoidCallback onCameraSwitch;
  final bool isFlashOn;
  final bool canSwitchCamera;
  final bool isProcessing;

  const CameraControls({
    super.key,
    required this.onCapture,
    required this.onGallery,
    required this.onFlashToggle,
    required this.onCameraSwitch,
    required this.isFlashOn,
    required this.canSwitchCamera,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppTheme.spacingL,
        right: AppTheme.spacingL,
        bottom: MediaQuery.of(context).padding.bottom + AppTheme.spacingL,
        top: AppTheme.spacingL,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingL,
              vertical: AppTheme.spacingM,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  'Arahkan kamera ke makanan',
                  style: AppTheme.bodySmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery button
              _buildControlButton(
                icon: Icons.photo_library_rounded,
                label: 'Galeri',
                onTap: isProcessing ? null : onGallery,
              ),

              // Capture button
              GestureDetector(
                onTap: isProcessing ? null : onCapture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isProcessing
                        ? AppTheme.textSecondary.withValues(alpha: 0.5)
                        : AppTheme.primaryGreen,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: isProcessing
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
                      : Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),

              // Flash/Switch button
              canSwitchCamera
                  ? _buildControlButton(
                      icon: Icons.flip_camera_ios_rounded,
                      label: 'Putar',
                      onTap: isProcessing ? null : onCameraSwitch,
                    )
                  : _buildControlButton(
                      icon: isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      label: 'Flash',
                      onTap: isProcessing ? null : onFlashToggle,
                      isActive: isFlashOn,
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppTheme.primaryGreen.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.6),
              border: Border.all(
                color: isActive
                    ? AppTheme.primaryGreen
                    : Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.8),
              size: 24,
            ),
          ),

          const SizedBox(height: AppTheme.spacingS),

          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
