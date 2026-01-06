// import 'package:diet_tracker/screens/home/beranda_screen.dart';
import 'package:diet_tracker/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/app_theme.dart';
import '../../models/user_model.dart';
import '../../widgets/camera_controls.dart';
import '../../widgets/food_details_panel.dart';
import 'food_logging_screen.dart';
import '../../services/food_analyzer_service.dart';

class ScanScreen extends StatefulWidget {
  final UserModel user;

  const ScanScreen({super.key, required this.user});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isRearCamera = true;
  File? _capturedImage;
  bool _isProcessing = false;
  Map<String, dynamic>? _foodAnalysis;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showErrorSnackBar('Tidak ada kamera yang tersedia');
        return;
      }

      final camera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Gagal menginisialisasi kamera: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile photo = await _cameraController!.takePicture();
      final File imageFile = File(photo.path);

      setState(() {
        _capturedImage = imageFile;
      });

      // Simulate ML processing
      await _analyzeFood(imageFile);
    } catch (e) {
      _showErrorSnackBar('Gagal mengambil foto: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        setState(() {
          _capturedImage = imageFile;
        });

        await _analyzeFood(imageFile);
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih gambar: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _analyzeFood(File imageFile) async {
    try {
      final result = await FoodAnalyzerService.analyzeFoodImage(imageFile);
      setState(() {
        _foodAnalysis = result;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal menganalisis makanan: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    try {
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.off : FlashMode.torch,
      );
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal mengubah flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    try {
      setState(() {
        _isCameraInitialized = false;
      });

      await _cameraController?.dispose();

      final newCamera = _cameras.firstWhere(
        (camera) =>
            camera.lensDirection ==
            (_isRearCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back),
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      setState(() {
        _isCameraInitialized = true;
        _isRearCamera = !_isRearCamera;
        _isFlashOn = false; // Reset flash when switching cameras
      });
    } catch (e) {
      _showErrorSnackBar('Gagal mengganti kamera: $e');
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _foodAnalysis = null;
    });
  }

  void _proceedToLogging() {
    if (_foodAnalysis != null && _capturedImage != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FoodLoggingScreen(
            user: widget.user,
            imageFile: _capturedImage!,
            foodAnalysis: _foodAnalysis!,
          ),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or captured image
          Positioned.fill(child: _buildCameraView()),

          // 🔧 Tambahan: blok area status bar dengan warna hitam solid
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top,
            child: Container(color: Colors.white),
          ),

          // Top overlay with title and close button
          Positioned(top: 0, left: 0, right: 0, child: _buildTopOverlay()),

          // Camera controls or food analysis panel
          if (_capturedImage == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CameraControls(
                onCapture: _capturePhoto,
                onGallery: _pickFromGallery,
                onFlashToggle: _toggleFlash,
                onCameraSwitch: _switchCamera,
                isFlashOn: _isFlashOn,
                canSwitchCamera: _cameras.length > 1,
                isProcessing: _isProcessing,
              ),
            )
          else
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FoodDetailsPanel(
                foodAnalysis: _foodAnalysis,
                isProcessing: _isProcessing,
                onRetake: _retakePhoto,
                user: widget.user, // ✅ sudah sinkron
                imageFile: _capturedImage!,
                onAddToLog: (entry) {
                  debugPrint("Makanan ditambahkan: ${entry.foodName}");
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text(
                  //       "${entry.foodName} berhasil ditambahkan ke log!",
                  //     ),
                  //     backgroundColor: AppTheme.successGreen,
                  //   ),
                  // );
                },
              ),
            ),

          // Processing overlay
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 400,
                      ), // naikkan posisi
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                          Text(
                            'Menganalisis makanan...',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXS),
                          Text(
                            'Mohon tunggu sebentar',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (_capturedImage != null) {
      return Image.file(
        _capturedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                'Menginisialisasi kamera...',
                style: AppTheme.bodyLarge.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return CameraPreview(_cameraController!);
  }

  Widget _buildTopOverlay() {
    final paddingTop = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: paddingTop + AppTheme.spacingS,
        left: AppTheme.spacingL,
        right: AppTheme.spacingL,
        bottom: AppTheme.spacingM,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.85),
            Colors.black.withOpacity(0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Tombol close di kiri
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                if (_capturedImage == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MainNavigationScreen(user: widget.user),
                    ),
                  );
                } else {
                  setState(() {
                    _capturedImage = null;
                    _foodAnalysis = null;
                  });
                }
              },
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // Judul di tengah
          Center(
            child: Text(
              _capturedImage == null ? 'Scan Makanan' : 'Hasil Scan',
              style: AppTheme.headingMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Flash button di kanan (kalau kamera aktif dan belum ambil foto)
          if (_capturedImage == null && _isCameraInitialized)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: _toggleFlash,
                icon: Icon(
                  _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: _isFlashOn ? AppTheme.primaryGreen : Colors.white,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // if (_cameras.length > 1)
  //   IconButton(
  //     onPressed: _switchCamera,
  //     icon: Icon(
  //       Icons.flip_camera_ios_rounded,
  //       color: Colors.white,
  //       size: 24,
  //     ),
  //   ),
}
