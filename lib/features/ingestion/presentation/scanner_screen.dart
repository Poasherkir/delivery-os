import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/l10n/generated/app_l10n.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/tokens/tokens.dart';
import '../../../shared/widgets/app_text.dart';

/// Reads the barcode on a parcel label.
///
/// **Pops with the scanned string, or with null.** It decides nothing about
/// what the code means — a tracking number's shape is a carrier question this
/// app has no answer to yet, and validating one here would reject a real
/// parcel at 07:00 to satisfy a guess.
///
/// **Manual entry is always offered, not only after a failure.** A damaged,
/// missing or unreadable label is ordinary rather than exceptional, and a
/// scanner the driver cannot escape is worse than no scanner. Same reasoning as
/// a phone number that will not parse: the validator does not get to stop the
/// morning.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  static const String path = '/scan';

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    // One format family. Narrowing the detector is the cheapest accuracy win
    // there is, and a driver holding a parcel is not scanning a QR code on a
    // poster — carrier labels are 1D.
    formats: const <BarcodeFormat>[
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.ean13,
      BarcodeFormat.qrCode,
    ],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  StreamSubscription<BarcodeCapture>? _subscription;

  /// Set the instant a code is accepted.
  ///
  /// The camera keeps delivering frames while the pop animation runs, so
  /// without this the screen can pop twice and the second pop takes the caller
  /// off its own page. `DetectionSpeed.noDuplicates` reduces the repeats; it
  /// does not make this unnecessary, because two *different* codes in one frame
  /// are also possible on a parcel carrying two labels.
  bool _handled = false;

  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _subscription = _controller.barcodes.listen(_onDetect);
    unawaited(_controller.start());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) {
      return;
    }

    // `rawValue` is null for a barcode the decoder saw but could not read.
    // Skipping rather than popping with null keeps the screen open so the
    // driver can simply hold it steadier.
    final String? value = capture.barcodes
        .map((Barcode b) => b.rawValue)
        .firstWhere(
          (String? v) => v != null && v.trim().isNotEmpty,
          orElse: () => null,
        );
    if (value == null) {
      return;
    }

    _handled = true;
    Navigator.of(context).pop(value.trim());
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (mounted) {
      setState(() => _torchOn = !_torchOn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final ColorTokens colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: AppText(l10n.scannerTitle, AppTextStyle.title),
        actions: <Widget>[
          IconButton(
            key: const Key('scanner.torch'),
            onPressed: _toggleTorch,
            tooltip: l10n.scannerTorch,
            icon: Icon(_torchOn ? Icons.flashlight_on : Icons.flashlight_off),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MobileScanner(
              key: const Key('scanner.preview'),
              controller: _controller,
              // The camera failing is not an error to swallow. Every path here
              // ends somewhere the driver can still enter the order.
              errorBuilder:
                  (BuildContext context, MobileScannerException error) =>
                      CameraUnavailable(error: error),
              overlayBuilder: (BuildContext context, BoxConstraints _) =>
                  _AimHint(text: l10n.scannerAim),
            ),
          ),
          _ManualEntryBar(
            label: l10n.scannerManualEntry,
            colors: colors,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Shown over the preview. Short, because it is read at arm's length while the
/// other hand holds a parcel.
class _AimHint extends StatelessWidget {
  const _AimHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(SpaceTokens.space24),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpaceTokens.space12,
            vertical: SpaceTokens.space8,
          ),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(RadiusTokens.small),
          ),
          child: AppText(text, AppTextStyle.body, color: Colors.white),
        ),
      ),
    );
  }
}

/// The camera could not start.
///
/// Two causes worth telling apart, because the driver's options differ: a
/// refused permission can be granted in settings, and anything else cannot be
/// acted on at all. Both offer manual entry, and both offer it first.
///
/// **Public because it is the most important state on this screen and the only
/// way to test it.** A widget test has no camera, and `MobileScanner` responds
/// to that by rendering its placeholder rather than by calling `errorBuilder` —
/// the platform channel never answers, so nothing ever errors. A test that
/// pumped the whole screen and looked for this copy would find nothing and
/// pass, which is how the first version of `scanner_screen_test` asserted the
/// copy contained no blame while the copy was not on screen at all.
class CameraUnavailable extends StatelessWidget {
  const CameraUnavailable({super.key, required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final bool denied =
        error.errorCode == MobileScannerErrorCode.permissionDenied;

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SpaceTokens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppText(
                denied
                    ? l10n.scannerPermissionTitle
                    : l10n.scannerUnavailableTitle,
                AppTextStyle.subtitle,
                color: Colors.white,
              ),
              const SizedBox(height: SpaceTokens.space8),
              AppText(
                denied
                    ? l10n.scannerPermissionBody
                    : l10n.scannerUnavailableBody,
                AppTextStyle.bodySmall,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Always present, whether the camera works or not.
class _ManualEntryBar extends StatelessWidget {
  const _ManualEntryBar({
    required this.label,
    required this.colors,
    required this.onPressed,
  });

  final String label;
  final ColorTokens colors;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(SpaceTokens.space16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.tonal(
            key: const Key('scanner.manualEntry'),
            onPressed: onPressed,
            child: AppText(label, AppTextStyle.label),
          ),
        ),
      ),
    );
  }
}
