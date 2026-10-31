import 'package:flutter/material.dart';

import '../../core/api/travel_api_client.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import 'controllers/offline_package_controller.dart';
import 'widgets/add_custom_item_dialog.dart';
import 'widgets/create_trip_dialog.dart';
import 'widgets/edit_trip_dialogs.dart';
import 'widgets/empty_trip_view.dart';
import 'widgets/offline_packages_section.dart';
import 'widgets/trip_days_view.dart';
import 'widgets/trip_header_card.dart';

class MyTripScreen extends StatefulWidget {
  final City currentCity;
  final WeatherReport? weather;

  const MyTripScreen({super.key, required this.currentCity, this.weather});

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen> with SingleTickerProviderStateMixin {
  List<Trip> _trips = [];
  Trip? _activeTrip;
  int _selectedDayIndex = 0;
  bool _loading = true;
  final Set<String> _savingItems = {};
  bool _editingTrip = false;
  bool get _busy => _editingTrip || _savingItems.isNotEmpty;
  final OfflinePackageController _offlineCtrl = OfflinePackageController();

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _offlineCtrl.load();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);
    final list = await TravelApiClient.fetchTrips();
    if (mounted) {
      setState(() {
        _trips = list;
        if (list.isNotEmpty) _activeTrip = list.first;
        _selectedDayIndex = 0;
        _loading = false;
      });
    }
  }

  void _showCreateTripDialog() async {
    final created = await CreateTripDialog.show(context, widget.currentCity);
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
  }

  void _showAddCustomItemDialog() async {
    if (_activeTrip == null) return;
    final updated = await AddCustomItemDialog.show(
      context,
      trip: _activeTrip!,
      dayNumber: _activeTrip!.days[_selectedDayIndex].dayNumber,
      city: widget.currentCity,
    );
    if (updated != null && mounted) setState(() => _activeTrip = updated);
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
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
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
        const SnackBar(content: Text('Could not delete trip. Please try again.')),
      );
    }
  }

  Future<void> _completeItem(ItineraryItem item, bool value) async {
    final tripId = _activeTrip!.id;
    setState(() => _savingItems.add(item.id));
    final updated = await TravelApiClient.completeItineraryItem(tripId, item.id, value);
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
        const SnackBar(content: Text('Could not save completion. Please try again.')),
      );
    }
  }

  Future<void> _handleTogglePackage(OfflinePackage pkg, bool remove) async {
    final ok = await _offlineCtrl.togglePackage(pkg, remove);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${remove ? "remove" : "download"} ${pkg.cityName}.')),
      );
    }
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
                      if (_activeTrip != null) ...[
                        TripHeaderCard(
                          trip: _activeTrip!,
                          trips: _trips,
                          busy: _busy,
                          onSelectTrip: (t) => setState(() {
                            _activeTrip = t;
                            _selectedDayIndex = 0;
                          }),
                          onEditTrip: () async {
                            final fields = await EditTripDialog.show(context, _activeTrip!);
                            if (fields != null && mounted) {
                              await _saveTripChange(() => TravelApiClient.updateTrip(_activeTrip!.id, fields));
                            }
                          },
                          onDeleteTrip: _deleteTrip,
                        ),
                        TripDaysView(
                          trip: _activeTrip!,
                          selectedDayIndex: _selectedDayIndex,
                          busy: _busy,
                          onSelectDay: (i) => setState(() => _selectedDayIndex = i),
                          onAddStop: _showAddCustomItemDialog,
                          onCompleteItem: _completeItem,
                          onSaveChange: _saveTripChange,
                          onConfirmDelete: _confirmDelete,
                        ),
                      ] else ...[
                        EmptyTripView(onCreateTrip: _showCreateTripDialog),
                      ],
                      const Divider(height: 36),
                      ListenableBuilder(
                        listenable: _offlineCtrl,
                        builder: (ctx, _) => OfflinePackagesSection(
                          packages: _offlineCtrl.packages,
                          downloadedPackages: _offlineCtrl.downloaded,
                          packageBusy: _offlineCtrl.busy,
                          packageVersions: _offlineCtrl.versions,
                          onToggle: _handleTogglePackage,
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
}
