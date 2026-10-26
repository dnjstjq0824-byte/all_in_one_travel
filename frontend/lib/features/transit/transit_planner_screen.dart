import 'package:flutter/material.dart';
import '../../core/models/travel_models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/api/travel_api_client.dart';

class TransitPlannerScreen extends StatefulWidget {
  final City currentCity;
  final Place? targetPlace; // Pre-filled destination from Explore or Map

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

  // Real-time bus arrivals section
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

    // Default destination
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
    setState(() {
      final tmpText = _originCtrl.text;
      _originCtrl.text = _destCtrl.text;
      _destCtrl.text = tmpText;

      final tmpLat = _originLat;
      final tmpLng = _originLng;
      _originLat = _destLat;
      _originLng = _destLng;
      _destLat = tmpLat;
      _destLng = tmpLng;
    });
    _searchRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.currentCity.name} ${AppLocale.tr('tab_transit')}'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            child: Column(
              children: [
            // Search Input Box
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      // Origin & Dest Indicators
                      const Column(
                        children: [
                          Icon(Icons.radio_button_checked, size: 18, color: AppTheme.accent),
                          SizedBox(height: 24, child: VerticalDivider(color: Colors.grey)),
                          Icon(Icons.location_on, size: 20, color: Colors.red),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Text Fields
                      Expanded(
                        child: Column(
                          children: [
                            TextField(
                              controller: _originCtrl,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                                hintText: 'Starting location...',
                                border: InputBorder.none,
                              ),
                            ),
                            const Divider(height: 12),
                            TextField(
                              controller: _destCtrl,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                                hintText: 'Destination or landmark...',
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Swap button
                      IconButton(
                        icon: const Icon(Icons.swap_vert, color: AppTheme.accent),
                        onPressed: _swapOriginDest,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Preference Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPrefChip('fastest', AppLocale.tr('fastest')),
                        const SizedBox(width: 6),
                        _buildPrefChip('min_transfers', AppLocale.tr('min_transfers')),
                        const SizedBox(width: 6),
                        _buildPrefChip('least_walking', AppLocale.tr('least_walking')),
                        const SizedBox(width: 6),
                        _buildPrefChip('accessible', AppLocale.tr('accessible')),
                      ],
                    ),
                  ),
                ],
              ),
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
                    Text('Recommended Routes (${_options.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(widget.currentCity.coverageLevel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                  ],
                ),
              ),
              ..._options.map((opt) => _buildRouteCard(opt)),
            ],

            const SizedBox(height: 16),

            // ARTICLE 6: Live Bus Arrivals Section
            if (_busStops.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocale.tr('bus_arrivals'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('GTFS Realtime', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              // Stop Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<BusStop>(
                        isExpanded: true,
                        value: _selectedBusStop,
                        items: _busStops.map((s) => DropdownMenuItem(value: s, child: Text('${s.name} (${s.code})'))).toList(),
                        onChanged: (s) {
                          if (s != null) {
                            setState(() => _selectedBusStop = s);
                            _loadArrivals(s.id);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Arrivals Cards
              if (_loadingBus)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
              else if (_liveArrivals.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No real-time buses currently en-route for this stop.', style: TextStyle(color: AppTheme.textMuted)),
                )
              else
                ..._liveArrivals.map((arr) => _buildArrivalCard(arr)),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
    ),
  );
}

  Widget _buildPrefChip(String key, String label) {
    final isSel = _preference == key;
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
      selected: isSel,
      selectedColor: AppTheme.accent,
      labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textMain),
      checkmarkColor: Colors.white,
      onSelected: (val) {
        setState(() => _preference = key);
        _searchRoutes();
      },
    );
  }

  Widget _buildRouteCard(RouteOption opt) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ExpansionTile(
        initiallyExpanded: opt == _options.first,
        title: Row(
          children: [
            Text('${opt.totalMinutes} min', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accent)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
              child: Text('${opt.walkMinutes} min walk', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
              child: Text('${opt.transfers} transfers', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ),
            const Spacer(),
            Text(opt.estimatedFare, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textMain)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(opt.summary, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                ...opt.legs.map((leg) => _buildLegRow(leg)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegRow(TransitLeg leg) {
    IconData icon;
    Color color;
    if (leg.type == 'METRO') {
      icon = Icons.subway;
      color = leg.lineColorHex != null ? _parseColor(leg.lineColorHex!) : AppTheme.accent;
    } else if (leg.type == 'BUS') {
      icon = Icons.directions_bus;
      color = Colors.indigo;
    } else {
      icon = Icons.directions_walk;
      color = AppTheme.textMuted;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(leg.instruction, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Text('${leg.fromStationName} ➔ ${leg.toStationName} (${leg.durationMinutes} min)', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalCard(RealtimeArrival arr) {
    Color statusColor;
    if (arr.status == 'LIVE') {
      statusColor = AppTheme.liveGreen;
    } else if (arr.status == 'SCHEDULED') {
      statusColor = AppTheme.accent;
    } else {
      statusColor = AppTheme.warnAmber;
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accent.withValues(alpha: 0.12),
          child: Text(arr.routeNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent, fontSize: 13)),
        ),
        title: Text('Towards ${arr.destination}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('Crowding: ${arr.crowdingLevel} • ${arr.stopsRemaining} stops away', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${arr.minutesAway} min', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
              child: Text(arr.status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor)),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('0xFF$clean'));
    }
    return AppTheme.accent;
  }
}

