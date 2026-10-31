import 'package:flutter/material.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';

class OfflinePackageCard extends StatelessWidget {
  final OfflinePackage pkg;
  final bool downloaded;
  final bool busy;
  final String? version;
  final VoidCallback onToggleDownload;

  const OfflinePackageCard({
    super.key,
    required this.pkg,
    required this.downloaded,
    required this.busy,
    required this.version,
    required this.onToggleDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          downloaded ? Icons.download_done : Icons.cloud_download_outlined,
          color: downloaded ? AppTheme.accent : AppTheme.textMuted,
        ),
        title: Text('${pkg.cityName} (${pkg.sizeMb.toStringAsFixed(1)} MB)'),
        subtitle: Text(
          downloaded
              ? 'Saved locally (${version ?? pkg.version}) • ${pkg.contents.join(', ')}'
              : 'Available for offline travel • ${pkg.contents.join(', ')}',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: busy
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: Icon(
                  downloaded ? Icons.delete_outline : Icons.download,
                  color: downloaded ? Colors.redAccent : AppTheme.accent,
                ),
                tooltip: downloaded ? 'Remove offline data' : 'Download package',
                onPressed: onToggleDownload,
              ),
      ),
    );
  }
}

