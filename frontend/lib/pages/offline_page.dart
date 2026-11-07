import 'package:flutter/material.dart';

import '../core/l10n/app_localizations.dart';
import '../core/models/travel_models.dart';
import '../core/responsive/adaptive_page.dart';
import '../core/theme/design_tokens.dart';
import '../features/trips/controllers/offline_package_controller.dart';
import '../features/trips/widgets/offline_packages_section.dart';

/// Offline: data package library. Single purpose — download or remove
/// city packages. Split out of the former merged trip screen.
class OfflinePage extends StatefulWidget {
  const OfflinePage({super.key});

  @override
  State<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  final _ctrl = OfflinePackageController();

  @override
  void initState() {
    super.initState();
    _ctrl.load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _toggle(OfflinePackage pkg, bool remove) async {
    final ok = await _ctrl.togglePackage(pkg, remove);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${remove ? 'remove' : 'download'} ${pkg.cityName}.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LedgerMeasure(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocale.tr('offline_package'),
                    style: text.titleLarge,
                  ),
                  Text(
                    'City data for disconnected travel',
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: LedgerTokens.s24),
              child: ListenableBuilder(
                listenable: _ctrl,
                builder: (ctx, _) => OfflinePackagesSection(
                  packages: _ctrl.packages,
                  downloadedPackages: _ctrl.downloaded,
                  packageBusy: _ctrl.busy,
                  packageVersions: _ctrl.versions,
                  onToggle: _toggle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
