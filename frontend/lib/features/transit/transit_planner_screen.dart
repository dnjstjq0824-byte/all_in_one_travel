import 'package:flutter/material.dart';

import '../../core/api/travel_api_client.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/bus_arrivals_section.dart';
import 'widgets/transit_route_card.dart';
import 'widgets/transit_search_form.dart';

class TransitPlannerScreen extends StatefulWidget {
  final City currentCity;
  final Place? targetPlace;

  const TransitPlannerScreen({
    super.key,
    required this.currentCity,
    this.targetPlace,
  });

  @override
  State<TransitPlannerScreen> createState() => _TransitPlannerScreenState();
}

class _TransitPlannerScreenState extends State<TransitPlannerScreen> {
  final TextEditingController _originCtrl = TextEditingController(text: 'Current Location (City Hall)');
  final TextEditingController _destCtrl = TextEditingController();

  double _originLat = 37.5657;
  double _originLng = 126.9769;
  double _destLat = 37.5796;
  double _destLng = 126.9770;

  String _preference = 'fastest';
  List<RouteOption> _options = [];
  bool _calculating = false;

  List<BusStop> _busStops = [];
  BusStop? _selectedBusStop;
  List<RealtimeArrival> _liveArrivals = [];
  bool _loadingBus = false;

  @override
  void initState() {
    super.initState();
    _applyCityDefaults();
    if (widget.targetPlace != null) {
      _destCtrl.text = widget.targetPlace!.name;
      _destLat = widget.targetPlace!.latitude;
      _destLng = widget.targetPlace!.longitude;
    }
    _searchRoutes();
    _loadBusStops();
  }

  @override
  void didUpdateWidget(covariant TransitPlannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCity.id != widget.currentCity.id) {
      _applyCityDefaults();
      _searchRoutes();
      _loadBusStops();
    } else if (widget.targetPlace != null && widget.targetPlace != oldWidget.targetPlace) {
      _destCtrl.text = widget.targetPlace!.name;
      _destLat = widget.targetPlace!.latitude;
      _destLng = widget.targetPlace!.longitude;
      _searchRoutes();
    }
  }

  void _applyCityDefaults() {
    _originLat = widget.currentCity.latitude;
    _originLng = widget.currentCity.longitude;
    _originCtrl.text = '${widget.currentCity.name} Central';

    if (widget.currentCity.id == 'seoul') {
      _destCtrl.text = '경복궁 (Gyeongbokgung Palace)';
      _destLat = 37.5796;
      _destLng = 126.9770;
    } else if (widget.currentCity.id == 'tokyo') {
      _destCtrl.text = '浅草寺 (Senso-ji Temple)';
      _destLat = 35.7148;
      _destLng = 139.7967;
    } else if (widget.currentCity.id == 'paris') {
      _destCtrl.text = 'Tour Eiffel (Eiffel Tower)';
      _destLat = 48.8584;
      _destLng = 2.2945;
    } else {
      _destCtrl.text = '${widget.currentCity.name} Landmark';
      _destLat = widget.currentCity.latitude + 0.015;
      _destLng = widget.currentCity.longitude + 0.015;
    }
  }

  Future<void> _loadBusStops() async {
    setState(() => _loadingBus = true);
    final stops = await TravelApiClient.fetchBusStops(widget.currentCity.id);
    if (mounted) {
      setState(() {
        _busStops = stops;
        if (stops.isNotEmpty) {
          _selectedBusStop = stops.first;
          _loadArrivals(stops.first.id);
        } else {
          _loadingBus = false;
        }
      });
    }
  }

  Future<void> _loadArrivals(String stopId) async {
    setState(() => _loadingBus = true);
    final arrivals = await TravelApiClient.fetchRealtimeArrivals(stopId);
    if (mounted) {
      setState(() {
        _liveArrivals = arrivals;
        _loadingBus = false;
      });
    }
  }

  Future<void> _searchRoutes() async {
    setState(() => _calculating = true);
    final opts = await TravelApiClient.planTransit(
      cityId: widget.currentCity.id,
      originLat: _originLat,
      originLng: _originLng,
      originName: _originCtrl.text,
      destLat: _destLat,
      destLng: _destLng,
      destName: _destCtrl.text,
      preference: _preference,
    );
    if (mounted) {
      setState(() {
        _options = opts;
        _calculating = false;
      });
    }
  }

  void _swapOriginDest() {
    final tText = _originCtrl.text;
    final tLat = _originLat;
    final tLng = _originLng;
    setState(() {
      _originCtrl.text = _destCtrl.text;
      _originLat = _destLat;
      _originLng = _destLng;
      _destCtrl.text = tText;
      _destLat = tLat;
      _destLng = tLng;
    });
    _searchRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocale.tr('tab_transit'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TransitSearchForm(
                  originCtrl: _originCtrl,
                  destCtrl: _destCtrl,
                  preference: _preference,
                  onSwap: _swapOriginDest,
                  onSelectPreference: (pref) {
                    setState(() => _preference = pref);
                    _searchRoutes();
                  },
                ),
                const SizedBox(height: 8),

                // Route Options Results
                if (_calculating)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_options.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No transit paths available between these locations in ${widget.currentCity.name}.',
                        style: const TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recommended Routes (${_options.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          widget.currentCity.coverageLevel,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accent),
                        ),
                      ],
                    ),
                  ),
                  ..._options.map((opt) => TransitRouteCard(option: opt, isFirst: opt == _options.first)),
                ],

                const SizedBox(height: 16),

                // Realtime Bus Arrivals
                BusArrivalsSection(
                  busStops: _busStops,
                  selectedBusStop: _selectedBusStop,
                  liveArrivals: _liveArrivals,
                  loadingBus: _loadingBus,
                  onSelectStop: (s) {
                    setState(() => _selectedBusStop = s);
                    _loadArrivals(s.id);
                  },
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
