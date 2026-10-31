import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';
import 'offline_package_card.dart';

class OfflinePackagesSection extends StatelessWidget {
  final List<OfflinePackage> packages;
  final Set<String> downloadedPackages;
  final Set<String> packageBusy;
  final Map<String, String?> packageVersions;
  final void Function(OfflinePackage pkg, bool remove) onToggle;

  const OfflinePackagesSection({
    super.key,
    required this.packages,
    required this.downloadedPackages,
    required this.packageBusy,
    required this.packageVersions,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocale.tr('offline_package'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Icon(Icons.cloud_download_outlined, color: AppTheme.accent, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Download city transit lists and places for offline browsing. Map tiles, live arrivals and online route planning require a connection.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          ...packages.map((pkg) {
            final downloaded = downloadedPackages.contains(pkg.cityId);
            return OfflinePackageCard(
              pkg: pkg,
              downloaded: downloaded,
              busy: packageBusy.contains(pkg.cityId),
              version: packageVersions[pkg.cityId],
              onToggleDownload: () => onToggle(pkg, downloaded),
            );
          }),
        ],
      ),
    );
  }
}

