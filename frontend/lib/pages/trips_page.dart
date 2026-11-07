import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../core/api/travel_api_client.dart';
import '../core/models/travel_models.dart';
import '../core/responsive/adaptive_page.dart';
import '../core/state/city_scope.dart';
import '../features/trips/widgets/add_custom_item_dialog.dart';
import '../features/trips/widgets/create_trip_dialog.dart';
import '../features/trips/widgets/edit_trip_dialogs.dart';
import '../features/trips/widgets/empty_trip_view.dart';
import '../features/trips/widgets/trip_days_view.dart';
import '../features/trips/widgets/trip_header_card.dart';
import 'widgets/trips_chrome.dart';

/// Trips: itinerary ledger. Single purpose — manage trips and days.
/// Offline packages moved to their own page ([Routes.offline]).
class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  List<Trip> _trips = [];
  Trip? _active;
  int _day = 0;
  bool _loading = true;
  final Set<String> _saving = {};
  bool _editing = false;
  bool get _busy => _editing || _saving.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await TravelApiClient.fetchTrips();
    if (mounted) {
      setState(() {
        _trips = list;
        _active = list.isNotEmpty ? list.first : null;
        _day = 0;
        _loading = false;
      });
    }
  }

  Future<void> _create() async {
    final city = CityScope.read(context).current!;
    final created = await CreateTripDialog.show(context, city);
    if (created != null && mounted) {
      setState(() {
        _trips.insert(0, created);
        _active = created;
        _day = 0;
      });
    }
  }

  Future<void> _addStop() async {
    if (_active == null) return;
    final city = CityScope.read(context).current!;
    final updated = await AddCustomItemDialog.show(
      context,
      trip: _active!,
      dayNumber: _active!.days[_day].dayNumber,
      city: city,
    );
    if (updated != null && mounted) setState(() => _active = updated);
  }

  Future<void> _save(Future<Trip?> Function() change) async {
    if (_busy) return;
    setState(() => _editing = true);
    final updated = await change();
    if (!mounted) return;
    setState(() {
      _editing = false;
      if (updated != null) _replace(updated);
    });
    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save changes.')),
      );
    }
  }

  void _replace(Trip updated) {
    final i = _trips.indexWhere((t) => t.id == updated.id);
    if (i >= 0) _trips[i] = updated;
    if (_active?.id == updated.id) {
      _active = updated;
      if (_day >= updated.days.length) _day = 0;
    }
  }

  Future<bool> _confirm(String title) async =>
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

  Future<void> _delete() async {
    final id = _active!.id;
    if (!await _confirm('Delete this trip?') || !mounted || _busy) return;
    setState(() => _editing = true);
    final ok = await TravelApiClient.deleteTrip(id);
    if (!mounted) return;
    setState(() {
      _editing = false;
      if (ok) {
        _trips.removeWhere((t) => t.id == id);
        _active = _trips.isEmpty ? null : _trips.first;
        _day = 0;
      }
    });
  }

  Future<void> _complete(ItineraryItem item, bool value) async {
    final tripId = _active!.id;
    setState(() => _saving.add(item.id));
    final updated =
        await TravelApiClient.completeItineraryItem(tripId, item.id, value);
    if (!mounted) return;
    setState(() {
      _saving.remove(item.id);
      if (updated != null) _replace(updated);
    });
    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save completion. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LedgerMeasure(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TripsChrome.header(
              context,
              count: _trips.length,
              onCreate: _create,
            ),
          ),
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_active == null)
            SliverToBoxAdapter(
              child: EmptyTripView(onCreateTrip: _create),
            )
          else ...[
            SliverToBoxAdapter(
              child: TripHeaderCard(
                trip: _active!,
                trips: _trips,
                busy: _busy,
                onSelectTrip: (t) => setState(() {
                      _active = t;
                      _day = 0;
                    }),
                onEditTrip: () async {
                  final fields =
                      await EditTripDialog.show(context, _active!);
                  if (fields != null && mounted) {
                    await _save(() => TravelApiClient.updateTrip(
                          _active!.id,
                          fields,
                        ));
                  }
                },
                onDeleteTrip: _delete,
              ),
            ),
            SliverToBoxAdapter(
              child: TripDaysView(
                trip: _active!,
                selectedDayIndex: _day,
                busy: _busy,
                onSelectDay: (i) => setState(() => _day = i),
                onAddStop: _addStop,
                onCompleteItem: _complete,
                onSaveChange: _save,
                onConfirmDelete: _confirm,
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: TripsChrome.offlineLink(context),
          ),
        ],
      ),
    );
  }
}
