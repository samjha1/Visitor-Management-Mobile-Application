import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/visitor_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../visitors/screens/visitor_details_screen.dart';

/// Camera-based QR Code Scanner screen using mobile_scanner.
/// Resolves scanned visitor ID against the REST API and navigates to VisitorDetailsScreen.
/// Note: Scanning NEVER automatically checks in or checks out.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _scannerController;
  bool _isProcessingScan = false;
  bool _isTorchOn = false;
  String? _lookupErrorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Manage camera lifecycle
    if (!_scannerController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _scannerController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _scannerController.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    super.dispose();
  }

  /// Process scanned barcode payload
  Future<void> _handleBarcodeDetected(BarcodeCapture capture) async {
    // Prevent duplicate concurrent scans
    if (_isProcessingScan) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawPayload = barcodes.first.rawValue;
    final validationError = Validators.validateQrPayload(rawPayload);
    if (validationError != null) return;

    final visitorId = rawPayload!.trim();
    await _resolveVisitorId(visitorId);
  }

  /// Look up visitor record by ID via REST API
  Future<void> _resolveVisitorId(String id) async {
    if (_isProcessingScan) return;

    setState(() {
      _isProcessingScan = true;
      _lookupErrorMessage = null;
    });

    try {
      // 1. Fetch visitor via GET /visitors/{id}
      final visitor = await ref.read(visitorRepositoryProvider).getVisitorById(id);

      // 2. Sync to Riverpod visitor list
      await ref.read(visitorListProvider.notifier).fetchAndSyncVisitor(visitor.id);

      if (!mounted) return;

      // 3. Navigate to details screen (staff must explicitly initiate check-in/out)
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VisitorDetailsScreen(initialVisitor: visitor),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _lookupErrorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visitor lookup failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        // Re-enable scanner for future scans after returning
        setState(() {
          _isProcessingScan = false;
        });
      }
    }
  }

  /// Manual ID lookup dialog (valuable on Android Emulators or if QR is unreadable)
  Future<void> _showManualLookupDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final id = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Visitor ID Manually'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Visitor ID',
              hintText: 'e.g. 1 or server ID',
              prefixIcon: Icon(Icons.tag),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter a visitor ID';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: const Text('Lookup'),
          ),
        ],
      ),
    );

    if (id != null && id.isNotEmpty) {
      await _resolveVisitorId(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Visitor QR Pass'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? Colors.yellow : Colors.white,
            ),
            tooltip: 'Toggle Flashlight',
            onPressed: () async {
              await _scannerController.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_outlined),
            tooltip: 'Enter ID Manually',
            onPressed: _isProcessingScan ? null : _showManualLookupDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Camera Scanner Preview
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcodeDetected,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off, size: 54, color: Colors.white70),
                      const SizedBox(height: 16),
                      const Text(
                        'Camera Access Unavailable',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.errorCode == MobileScannerErrorCode.permissionDenied
                            ? 'Camera permission was denied. Please grant camera access in app settings to scan QR codes.'
                            : 'Unable to initialize camera preview: ${error.errorDetails?.message ?? error.toString()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Enter ID Manually',
                        icon: Icons.keyboard,
                        onPressed: _showManualLookupDialog,
                        width: 200,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Scanning Overlay Frame
          _buildScannerOverlay(),

          // 3. Loading Indicator when resolving QR ID
          if (_isProcessingScan)
            Container(
              color: Colors.black.withValues(alpha: 0.65),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Looking up visitor record...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Instructions and Error Message at bottom
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                if (_lookupErrorMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _lookupErrorMessage!,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text(
                    'Align visitor QR code within the frame to verify details.\nCheck-in/out is confirmed on the details screen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Scanning target reticle frame
  Widget _buildScannerOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanSize = constraints.maxWidth * 0.72;

        return Stack(
          children: [
            Center(
              child: Container(
                width: scanSize,
                height: scanSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentTeal, width: 2.5),
                ),
                child: Stack(
                  children: [
                    // Top-Left Corner
                    Positioned(
                      top: -2,
                      left: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white, width: 4),
                            left: BorderSide(color: Colors.white, width: 4),
                          ),
                        ),
                      ),
                    ),
                    // Top-Right Corner
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white, width: 4),
                            right: BorderSide(color: Colors.white, width: 4),
                          ),
                        ),
                      ),
                    ),
                    // Bottom-Left Corner
                    Positioned(
                      bottom: -2,
                      left: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white, width: 4),
                            left: BorderSide(color: Colors.white, width: 4),
                          ),
                        ),
                      ),
                    ),
                    // Bottom-Right Corner
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white, width: 4),
                            right: BorderSide(color: Colors.white, width: 4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
