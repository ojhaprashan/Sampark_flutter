import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/colors.dart';

const String _kRegionKey = 'selected_region';
const String _kRegionIndia = 'india';
const String _kRegionGlobal = 'global';

class RegionSelectionDialog extends StatelessWidget {
  /// Whether the dialog is shown before login (non-dismissible, no close button)
  final bool preLogin;

  const RegionSelectionDialog({super.key, this.preLogin = false});

  // ─────────────────────── Static helpers ───────────────────────

  /// Returns the stored region string, or null if not yet selected.
  static Future<String?> getSelectedRegion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRegionKey);
  }

  /// Save the chosen region locally.
  static Future<void> saveRegion(String region) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRegionKey, region);
  }

  /// Show the dialog before login (non-dismissible).
  /// Returns the chosen region string: 'india' or 'global'.
  static Future<String> showBeforeLogin(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RegionSelectionDialog(preLogin: true),
    );
    return result ?? _kRegionIndia;
  }

  /// Check and show AFTER login (only once, if not already shown before).
  /// Kept for backward-compat with the header dropdown path.
  static Future<void> checkAndShow(BuildContext context) async {
    final region = await getSelectedRegion();
    // Already chosen before login → don't show again
    if (region != null) return;

    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const RegionSelectionDialog(),
      );
    }
  }

  /// Show from the header dropdown (dismissible, allows re-selection).
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const RegionSelectionDialog(),
    );
  }

  // ─────────────────────── Build ───────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !preLogin, // block back-button during pre-login
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Close button only when NOT pre-login
          if (!preLogin)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.grey, size: 20),
                ),
              ],
            ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.activeYellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.language,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            "Choose your region",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            "We're available worldwide. Select your location to see prices and options in the right format.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 24.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildRegionOption(
                  context: context,
                  flag: '🌍',
                  title: 'Global',
                  subtitle: 'For users outside India',
                  borderColor: Colors.grey.shade200,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  onTap: () async {
                    await saveRegion(_kRegionGlobal);
                    if (context.mounted) {
                      Navigator.of(context).pop(_kRegionGlobal);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRegionOption(
                  context: context,
                  flag: '🇮🇳',
                  title: 'India',
                  subtitle: 'Best experience for Indian users',
                  borderColor: AppColors.activeYellow.withOpacity(0.5),
                  backgroundColor: AppColors.activeYellow.withOpacity(0.05),
                  textColor: Colors.deepOrange.shade800,
                  onTap: () async {
                    await saveRegion(_kRegionIndia);
                    if (context.mounted) {
                      Navigator.of(context).pop(_kRegionIndia);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Trusted by drivers in ",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const Text(
                "🇮🇳 🇳🇪 🇺🇸 🇬🇧 🇦🇪 🇪🇸 🇨🇦 🇸🇷",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegionOption({
    required BuildContext context,
    required String flag,
    required String title,
    required String subtitle,
    required Color borderColor,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor == Colors.black ? Colors.black87 : textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.8),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
