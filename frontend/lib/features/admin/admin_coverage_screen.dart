import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/api/travel_api_client.dart';

class AdminCoverageScreen extends StatefulWidget {
  final List<City> cities;

  const AdminCoverageScreen({
    super.key,
    required this.cities,
  });

  @override
  State<AdminCoverageScreen> createState() => _AdminCoverageScreenState();
}

class _AdminCoverageScreenState extends State<AdminCoverageScreen> {
  final Map<String, CoverageRegistry> _coverageData = {};
  bool _loading = true;
  String _filter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadAllCoverage();
  }

  Future<void> _loadAllCoverage() async {
    setState(() => _loading = true);
    for (final city in widget.cities) {
      final cov = await TravelApiClient.fetchCoverage(city.id);
      if (cov != null) {
        _coverageData[city.id] = cov;
      }
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.cities.where((c) {
      if (_filter == 'ALL') return true;
      return c.coverageLevel == _filter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.tr('admin_console')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllCoverage,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header summary card
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_user, color: AppTheme.accent, size: 20),
                    SizedBox(width: 8),
                    Text('Global Data Registry (Article 15)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Strict governance: Real-time and schedules are only surfaced where legally licensed and verified. Unsupported regions are clearly designated.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),

                // Filter Buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All (${widget.cities.length})'),
                      const SizedBox(width: 6),
                      _buildFilterChip('LEVEL_A', 'Level A (Full)'),
                      const SizedBox(width: 6),
                      _buildFilterChip('LEVEL_B', 'Level B (Schedule)'),
                      const SizedBox(width: 6),
                      _buildFilterChip('LEVEL_C', 'Level C (Map)'),
                      const SizedBox(width: 6),
                      _buildFilterChip('LEVEL_D', 'Level D (Dest)'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Registry List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final city = filtered[i];
                      final cov = _coverageData[city.id];
                      return _buildCityCoverageCard(city, cov);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String level, String label) {
    final isSel = _filter == level;
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
      selected: isSel,
      selectedColor: AppTheme.accent,
      labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textMain),
      onSelected: (val) {
        setState(() => _filter = level);
      },
    );
  }

  Widget _buildCityCoverageCard(City city, CoverageRegistry? cov) {
    Color badgeColor;
    if (city.coverageLevel == 'LEVEL_A') {
      badgeColor = AppTheme.liveGreen;
    } else if (city.coverageLevel == 'LEVEL_B') {
      badgeColor = AppTheme.accent;
    } else if (city.coverageLevel == 'LEVEL_C') {
      badgeColor = AppTheme.warnAmber;
    } else {
      badgeColor = Colors.purple;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${city.name} (${city.countryCode})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(city.coverageLevel, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(city.description, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 10),

            // Capability Matrix
            if (cov != null) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _buildMatrixBadge('Metro Map', cov.metroMapAvailable),
                  _buildMatrixBadge('Metro Route', cov.metroRoutesAvailable),
                  _buildMatrixBadge('Bus Route', cov.busRoutesAvailable),
                  _buildMatrixBadge('Schedule', cov.scheduleAvailable),
                  _buildMatrixBadge('Realtime (Live)', cov.realtimeAvailable),
                  _buildMatrixBadge('Fares', cov.faresAvailable),
                  _buildMatrixBadge('Accessibility', cov.accessibilityAvailable),
                ],
              ),
              const Divider(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.source_outlined, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Provider: ${cov.officialDataProvider}\nLicense: ${cov.dataLicense}\nAttribution: ${cov.attribution}',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, height: 1.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Validation: ${cov.validationStatus}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  Text('Freshness: ${cov.dataFreshnessMinutes}m sync', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ],
              ),
            ] else
              const Text('Connecting to data registry...', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixBadge(String label, bool supported) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: supported ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: supported ? Colors.green.shade200 : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(supported ? Icons.check : Icons.close, size: 10, color: supported ? Colors.green : Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: supported ? Colors.green.shade800 : Colors.grey.shade600, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

