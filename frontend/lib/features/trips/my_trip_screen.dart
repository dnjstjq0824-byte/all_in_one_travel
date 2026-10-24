import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/api/travel_api_client.dart';

class MyTripScreen extends StatefulWidget {
  final City currentCity;
  final WeatherReport? weather;

  const MyTripScreen({
    super.key,
    required this.currentCity,
    this.weather,
  });

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen> with SingleTickerProviderStateMixin {
  List<Trip> _trips = [];
  Trip? _activeTrip;
  int _selectedDayIndex = 0;
  bool _loading = true;

  // Offline Packages
  List<OfflinePackage> _offlinePackages = [];
  final Set<String> _downloadedPackages = {};

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _loadOfflinePackages();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);
    final list = await TravelApiClient.fetchTrips();
    if (mounted) {
      setState(() {
        _trips = list;
        if (list.isNotEmpty) {
          _activeTrip = list.first;
        }
        _loading = false;
      });
    }
  }

  Future<void> _loadOfflinePackages() async {
    final pkgs = await TravelApiClient.fetchOfflinePackages();
    if (mounted) {
      setState(() {
        _offlinePackages = pkgs;
        if (pkgs.isNotEmpty) {
          // Pre-mark seoul as downloaded for demonstration
          _downloadedPackages.add('seoul');
        }
      });
    }
  }

  void _showCreateTripDialog() {
    final titleCtrl = TextEditingController(text: '${widget.currentCity.name} Highlights Tour');
    final startCtrl = TextEditingController(text: '2026-11-01');
    final endCtrl = TextEditingController(text: '2026-11-04');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Trip', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Trip Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startCtrl,
              decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endCtrl,
              decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: () async {
              Navigator.pop(ctx);
              final newTrip = Trip(
                id: '',
                title: titleCtrl.text.trim(),
                countryCode: widget.currentCity.countryCode,
                cityId: widget.currentCity.id,
                cityName: widget.currentCity.name,
                startDate: startCtrl.text.trim(),
                endDate: endCtrl.text.trim(),
                days: [],
                collaborators: [],
              );
              final created = await TravelApiClient.createTrip(newTrip);
              if (created != null && mounted) {
                setState(() {
                  _trips.insert(0, created);
                  _activeTrip = created;
                  _selectedDayIndex = 0;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Trip "${created.title}" created successfully!')),
                );
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddCustomItemDialog() {
    if (_activeTrip == null) return;
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '14:00');
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Stop to Day', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Stop / Activity Name', hintText: 'e.g. Afternoon Tea or Museum', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(labelText: 'Time (HH:MM)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final newItem = ItineraryItem(
                id: '',
                title: titleCtrl.text.trim(),
                subtitle: 'Custom Activity',
                category: 'Activity',
                order: 1,
                timeScheduled: timeCtrl.text.trim(),
                latitude: widget.currentCity.latitude,
                longitude: widget.currentCity.longitude,
                durationMin: 60,
                notes: notesCtrl.text.trim(),
                isCompleted: false,
              );
              final updated = await TravelApiClient.addItineraryItem(_activeTrip!.id, _selectedDayIndex + 1, newItem);
              if (updated != null && mounted) {
                setState(() {
                  _activeTrip = updated;
                });
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.tr('tab_my_trip')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.accent),
            tooltip: 'New Trip',
            onPressed: _showCreateTripDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Trip Header Card
                  if (_activeTrip != null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Card(
                        color: AppTheme.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                    child: Text(_activeTrip!.cityName, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                  Text(
                                    '${_activeTrip!.startDate} ~ ${_activeTrip!.endDate}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _activeTrip!.title,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${_activeTrip!.days.length} Days Itinerary • Linked Transit & Weather',
                                style: TextStyle(color: Colors.blue.shade200, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Day Tabs
                    if (_activeTrip!.days.isNotEmpty) ...[
                      SizedBox(
                        height: 48,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _activeTrip!.days.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (ctx, i) {
                            final isSel = _selectedDayIndex == i;
                            return ChoiceChip(
                              label: Text('Day ${i + 1}', style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                              selected: isSel,
                              selectedColor: AppTheme.accent,
                              labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textMain),
                              onSelected: (_) {
                                setState(() => _selectedDayIndex = i);
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Day Weather Summary
                      if (_selectedDayIndex < _activeTrip!.days.length) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.wb_sunny_outlined, size: 20, color: AppTheme.accent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _activeTrip!.days[_selectedDayIndex].weatherNote ??
                                        'Day forecast: 17°C Clear • Great day for outdoor walking',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Itinerary Items for selected day
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Day ${_selectedDayIndex + 1} Schedule', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              onPressed: _showAddCustomItemDialog,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Stop', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),

                      if (_selectedDayIndex < _activeTrip!.days.length && _activeTrip!.days[_selectedDayIndex].items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(
                            child: Text('No stops added for this day yet. Add places from Explore or tap "Add Stop" above!', style: TextStyle(color: AppTheme.textMuted)),
                          ),
                        )
                      else if (_selectedDayIndex < _activeTrip!.days.length)
                        ..._activeTrip!.days[_selectedDayIndex].items.map((item) => _buildItineraryTimelineItem(item)),
                    ],
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.luggage_outlined, size: 48, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            const Text('No travel itineraries yet.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            const Text('Create your first trip or add destinations from Explore.', style: TextStyle(color: AppTheme.textMuted)),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: _showCreateTripDialog,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('Create Trip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const Divider(height: 36),

                  // ARTICLE 14: Offline Travel Packages Section
                  Padding(
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
                        const Text('Save metro maps, bus schedules, and landmark cards for 100% offline use without data roaming.', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        const SizedBox(height: 12),

                        ..._offlinePackages.map((pkg) => _buildOfflinePackageCard(pkg)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildItineraryTimelineItem(ItineraryItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time & Order Indicator
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(item.timeScheduled, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.accent)),
                  ),
                  const SizedBox(height: 6),
                  Text('${item.durationMin}m', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                        Checkbox(
                          value: item.isCompleted,
                          onChanged: (val) {
                            setState(() {
                              // Toggle locally
                            });
                          },
                        ),
                      ],
                    ),
                    Text(item.subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Note: ${item.notes}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.primary)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflinePackageCard(OfflinePackage pkg) {
    final isDownloaded = _downloadedPackages.contains(pkg.cityId);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDownloaded ? Colors.green.shade100 : Colors.blue.shade50,
          child: Icon(
            isDownloaded ? Icons.check_circle : Icons.download,
            color: isDownloaded ? Colors.green : AppTheme.accent,
            size: 20,
          ),
        ),
        title: Text('${pkg.cityName} Package (v${pkg.version})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('${pkg.sizeMb} MB • ${pkg.contents.join(", ")}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        trailing: OutlinedButton(
          onPressed: () {
            setState(() {
              if (isDownloaded) {
                _downloadedPackages.remove(pkg.cityId);
              } else {
                _downloadedPackages.add(pkg.cityId);
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isDownloaded ? 'Removed ${pkg.cityName} offline package' : 'Saved ${pkg.cityName} offline package (${pkg.sizeMb} MB)')),
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            side: BorderSide(color: isDownloaded ? Colors.green : AppTheme.accent),
          ),
          child: Text(
            isDownloaded ? 'Saved' : 'Download',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDownloaded ? Colors.green : AppTheme.accent,
            ),
          ),
        ),
      ),
    );
  }
}

