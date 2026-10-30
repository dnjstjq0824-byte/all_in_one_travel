import 'package:flutter/material.dart';

import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/api/travel_api_client.dart';
import '../../core/offline/offline_city_store.dart';

class MyTripScreen extends StatefulWidget {
  final City currentCity;
  final WeatherReport? weather;

  const MyTripScreen({super.key, required this.currentCity, this.weather});

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen>
    with SingleTickerProviderStateMixin {
  List<Trip> _trips = [];
  Trip? _activeTrip;
  int _selectedDayIndex = 0;
  bool _loading = true;
  final Set<String> _savingItems = {};
  bool _editingTrip = false;
  bool get _busy => _editingTrip || _savingItems.isNotEmpty;

  // Offline Packages
  List<OfflinePackage> _offlinePackages = [];
  final Set<String> _downloadedPackages = {};
  final Set<String> _packageBusy = {};
  final Map<String, String?> _packageVersions = {};

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
        _selectedDayIndex = 0;
        _loading = false;
      });
    }
  }

  Future<void> _loadOfflinePackages() async {
    final pkgs = await TravelApiClient.fetchOfflinePackages();
    final saved = await OfflineCityStore.savedCities();
    final versions = <String, String?>{};
    for (final city in saved) { versions[city] = await OfflineCityStore.version(city); }
    if (mounted) {
      setState(() {
        _offlinePackages = pkgs;
        _downloadedPackages.clear();
        _downloadedPackages.addAll(saved);
        _packageVersions.addAll(versions);
      });
    }
  }

  void _showCreateTripDialog() {
    final titleCtrl = TextEditingController(
      text: '${widget.currentCity.name} Highlights Tour',
    );
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final startCtrl = TextEditingController(text: today);
    final endCtrl = TextEditingController(text: today);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Create New Trip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Trip Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startCtrl,
              decoration: const InputDecoration(
                labelText: 'Start Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endCtrl,
              decoration: const InputDecoration(
                labelText: 'End Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: () async {
              final start = DateTime.tryParse(startCtrl.text.trim());
              final end = DateTime.tryParse(endCtrl.text.trim());
              if (titleCtrl.text.trim().isEmpty ||
                  start == null ||
                  end == null ||
                  end.isBefore(start) ||
                  end.difference(start).inDays > 365) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter a trip name and valid dates within 365 days.',
                    ),
                  ),
                );
                return;
              }
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
                  SnackBar(
                    content: Text(
                      'Trip "${created.title}" created successfully!',
                    ),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Could not create trip. Check the dates and connection.',
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
        title: const Text(
          'Add Stop to Day',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Stop / Activity Name',
                hintText: 'e.g. Afternoon Tea or Museum',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(
                labelText: 'Time (HH:MM)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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
              final updated = await TravelApiClient.addItineraryItem(
                _activeTrip!.id,
                _activeTrip!.days[_selectedDayIndex].dayNumber,
                newItem,
              );
              if (updated != null && mounted) {
                setState(() {
                  _activeTrip = updated;
                });
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Trip Header Card
                      if (_activeTrip != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  key: ValueKey(_activeTrip!.id),
                                  initialValue: _activeTrip!.id,
                                  decoration: const InputDecoration(
                                    labelText: 'Select trip',
                                    border: OutlineInputBorder(),
                                  ),
                                  isExpanded: true,
                                  items: _trips
                                      .map(
                                        (trip) => DropdownMenuItem(
                                          value: trip.id,
                                          child: Text(
                                            trip.title,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _busy
                                      ? null
                                      : (id) => setState(() {
                                          _activeTrip = _trips.firstWhere(
                                            (trip) => trip.id == id,
                                          );
                                          _selectedDayIndex = 0;
                                        }),
                                ),
                              ),
                              PopupMenuButton<String>(
                                tooltip: 'Trip actions',
                                enabled: !_busy,
                                onSelected: (action) {
                                  if (action == 'edit') {
                                    _editTrip();
                                  } else {
                                    _deleteTrip();
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit trip'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete trip'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          _activeTrip!.cityName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${_activeTrip!.startDate} ~ ${_activeTrip!.endDate}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _activeTrip!.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_activeTrip!.days.length} Days Itinerary • Linked Transit & Weather',
                                    style: TextStyle(
                                      color: Colors.blue.shade200,
                                      fontSize: 13,
                                    ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _activeTrip!.days.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (ctx, i) {
                                final isSel = _selectedDayIndex == i;
                                return ChoiceChip(
                                  label: Text(
                                    'Day ${i + 1}',
                                    style: TextStyle(
                                      fontWeight: isSel
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  selected: isSel,
                                  selectedColor: AppTheme.accent,
                                  labelStyle: TextStyle(
                                    color: isSel
                                        ? Colors.white
                                        : AppTheme.textMain,
                                  ),
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
                            _buildDayWeatherCard(
                              _activeTrip!.days[_selectedDayIndex],
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Itinerary Items for selected day
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Day ${_selectedDayIndex + 1} Schedule',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _showAddCustomItemDialog,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text(
                                    'Add Stop',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (_selectedDayIndex < _activeTrip!.days.length &&
                              _activeTrip!
                                  .days[_selectedDayIndex]
                                  .items
                                  .isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  'No stops added for this day yet. Add places from Explore or tap "Add Stop" above!',
                                  style: TextStyle(color: AppTheme.textMuted),
                                ),
                              ),
                            )
                          else if (_selectedDayIndex < _activeTrip!.days.length)
                            ..._activeTrip!.days[_selectedDayIndex].items.map(
                              (item) => _buildItineraryTimelineItem(item),
                            ),
                        ],
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.luggage_outlined,
                                  size: 48,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No travel itineraries yet.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Create your first trip or add destinations from Explore.',
                                  style: TextStyle(color: AppTheme.textMuted),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: _showCreateTripDialog,
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Create Trip',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accent,
                                  ),
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
                                Text(
                                  AppLocale.tr('offline_package'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.cloud_download_outlined,
                                  color: AppTheme.accent,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Download city transit lists and places for offline browsing. Map tiles, live arrivals and online route planning require a connection.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 12),

                            ..._offlinePackages.map(
                              (pkg) => _buildOfflinePackageCard(pkg),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.timeScheduled,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.durationMin}m',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.routeFromPrevious != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'From previous stop: ${item.routeFromPrevious!.summary}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: item.isCompleted,
                          onChanged: _busy
                              ? null
                              : (value) => _completeItem(item, value ?? false),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Activity actions',
                          enabled: !_busy,
                          onSelected: (action) {
                            if (action == 'edit') {
                              _editItem(item);
                            }
                            if (action == 'delete') {
                              _deleteItem(item);
                            }
                            if (action == 'up' || action == 'down') {
                              _moveItem(item, action == 'up' ? -1 : 1);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit activity'),
                            ),
                            PopupMenuItem(
                              value: 'up',
                              child: Text('Move earlier'),
                            ),
                            PopupMenuItem(
                              value: 'down',
                              child: Text('Move later'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete activity'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Note: ${item.notes}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.primary,
                        ),
                      ),
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

  Future<void> _completeItem(ItineraryItem item, bool value) async {
    final tripId = _activeTrip!.id;
    setState(() => _savingItems.add(item.id));
    final updated = await TravelApiClient.completeItineraryItem(
      tripId,
      item.id,
      value,
    );
    if (!mounted) return;
    setState(() {
      _savingItems.remove(item.id);
      if (updated != null) {
        final index = _trips.indexWhere((trip) => trip.id == updated.id);
        if (index >= 0) _trips[index] = updated;
        if (_activeTrip?.id == tripId) _activeTrip = updated;
      }
    });
    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save completion. Please try again.'),
        ),
      );
    }
  }

  Future<void> _saveTripChange(Future<Trip?> Function() change) async {
    if (_busy) return;
    setState(() => _editingTrip = true);
    final updated = await change();
    if (!mounted) return;
    setState(() {
      _editingTrip = false;
      if (updated != null) {
        final index = _trips.indexWhere((trip) => trip.id == updated.id);
        if (index >= 0) _trips[index] = updated;
        if (_activeTrip?.id == updated.id) {
          _activeTrip = updated;
          if (_selectedDayIndex >= updated.days.length) _selectedDayIndex = 0;
        }
      }
    });
    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save changes. Check your input and connection. Remove activities before excluding their dates.',
          ),
        ),
      );
    }
  }

  Future<bool> _confirmDelete(String title) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _deleteTrip() async {
    final id = _activeTrip!.id;
    if (!await _confirmDelete('Delete this trip?') || !mounted || _busy) return;
    setState(() => _editingTrip = true);
    final deleted = await TravelApiClient.deleteTrip(id);
    if (!mounted) return;
    setState(() {
      _editingTrip = false;
      if (deleted) {
        _trips.removeWhere((trip) => trip.id == id);
        _activeTrip = _trips.isEmpty ? null : _trips.first;
        _selectedDayIndex = 0;
      }
    });
    if (!deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete trip. Please try again.'),
        ),
      );
    }
  }

  Future<void> _deleteItem(ItineraryItem item) async {
    final id = _activeTrip!.id;
    if (!await _confirmDelete('Delete this activity?') || !mounted) return;
    await _saveTripChange(
      () => TravelApiClient.deleteItineraryItem(id, item.id),
    );
  }

  Future<void> _moveItem(ItineraryItem item, int offset) async {
    final trip = _activeTrip!;
    final day = trip.days[_selectedDayIndex];
    final ids = day.items.map((item) => item.id).toList();
    final i = ids.indexOf(item.id);
    final target = i + offset;
    if (i < 0 || target < 0 || target >= ids.length) return;
    ids.removeAt(i);
    ids.insert(target, item.id);
    await _saveTripChange(
      () => TravelApiClient.reorderItineraryItems(trip.id, day.dayNumber, ids),
    );
  }

  Future<void> _editTrip() async {
    final trip = _activeTrip!;
    var title = trip.title;
    var start = trip.startDate;
    var end = trip.endDate;
    final fields = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit trip'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: title,
                onChanged: (value) => title = value,
                decoration: const InputDecoration(labelText: 'Trip name'),
              ),
              TextFormField(
                initialValue: start,
                onChanged: (value) => start = value,
                decoration: const InputDecoration(
                  labelText: 'Start date (YYYY-MM-DD)',
                ),
              ),
              TextFormField(
                initialValue: end,
                onChanged: (value) => end = value,
                decoration: const InputDecoration(
                  labelText: 'End date (YYYY-MM-DD)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, {
                'title': title.trim(),
                'start_date': start.trim(),
                'end_date': end.trim(),
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (fields != null && mounted) {
      await _saveTripChange(() => TravelApiClient.updateTrip(trip.id, fields));
    }
  }

  Future<void> _editItem(ItineraryItem item) async {
    final tripId = _activeTrip!.id;
    var title = item.title;
    var time = item.timeScheduled;
    var duration = item.durationMin.toString();
    var notes = item.notes ?? '';
    final fields = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit activity'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: title,
                onChanged: (value) => title = value,
                decoration: const InputDecoration(labelText: 'Activity name'),
              ),
              TextFormField(
                initialValue: time,
                onChanged: (value) => time = value,
                decoration: const InputDecoration(labelText: 'Time (HH:MM)'),
              ),
              TextFormField(
                initialValue: duration,
                onChanged: (value) => duration = value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
              ),
              TextFormField(
                initialValue: notes,
                onChanged: (value) => notes = value,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final minutes = int.tryParse(duration);
              if (title.trim().isEmpty ||
                  minutes == null ||
                  minutes < 0 ||
                  minutes > 1440) {
                return;
              }
              Navigator.pop(ctx, {
                'title': title.trim(),
                'time_scheduled': time.trim(),
                'duration_min': minutes,
                'notes': notes,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (fields != null && mounted) {
      await _saveTripChange(
        () => TravelApiClient.updateItineraryItem(tripId, item.id, fields),
      );
    }
  }

  Widget _buildDayWeatherCard(TripDay day) {
    final forecast = day.dayWeather;
    final rain = forecast?.rainAlert ?? false;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: rain ? Colors.orange.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            forecast == null
                ? Icons.cloud_off_outlined
                : rain
                ? Icons.umbrella_outlined
                : Icons.cloud_outlined,
            color: rain ? Colors.orange.shade800 : AppTheme.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.dateStr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  forecast == null
                      ? 'Forecast unavailable for this date'
                      : '${forecast.condition} · ${forecast.tempMinC.round()}–${forecast.tempMaxC.round()}°C · Rain ${forecast.precipProb}%',
                ),
                if (rain && forecast?.indoorTip != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    forecast!.indoorTip!,
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePackage(OfflinePackage pkg, {bool remove = false}) async {
    if (_packageBusy.contains(pkg.cityId)) return;
    setState(() => _packageBusy.add(pkg.cityId));
    try {
      if (remove) { await OfflineCityStore.removeCity(pkg.cityId); }
      else { await TravelApiClient.downloadOfflinePackage(pkg.cityId); }
      final version = await OfflineCityStore.version(pkg.cityId);
      if (!mounted) return;
      setState(() {
        if (remove) { _downloadedPackages.remove(pkg.cityId); }
        else { _downloadedPackages.add(pkg.cityId); }
        _packageVersions[pkg.cityId] = version;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(remove ? 'Removed ${pkg.cityName} offline data' : 'Saved and verified ${pkg.cityName} offline data')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save offline data. Check connection and available storage. Existing data was kept.')));
    } finally {
      if (mounted) setState(() => _packageBusy.remove(pkg.cityId));
    }
  }

  Widget _buildOfflinePackageCard(OfflinePackage pkg) {
    final saved = _downloadedPackages.contains(pkg.cityId);
    final busy = _packageBusy.contains(pkg.cityId);
    final changed = saved && _packageVersions[pkg.cityId] != pkg.version;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(saved ? Icons.offline_pin : Icons.download, color: saved ? Colors.green : AppTheme.accent),
            const SizedBox(width: 8),
            Expanded(child: Text('${pkg.cityName} offline data', style: const TextStyle(fontWeight: FontWeight.bold))),
            if (busy) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          ]),
          const SizedBox(height: 6),
          Text('${pkg.sizeMb.toStringAsFixed(3)} MB · ${pkg.contents.join(", ")}', style: const TextStyle(fontSize: 12)),
          if (pkg.attribution.isNotEmpty) Text(pkg.attribution, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          Wrap(spacing: 8, children: [
            OutlinedButton(onPressed: busy ? null : () => _savePackage(pkg), child: Text(saved ? changed ? 'Update' : 'Refresh' : 'Download')),
            if (saved) TextButton(onPressed: busy ? null : () => _savePackage(pkg, remove: true), child: const Text('Remove')),
          ]),
        ]),
      ),
    );
  }
}