import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../core/api/travel_api_client.dart';
import '../core/models/travel_models.dart';
import '../core/responsive/adaptive_page.dart';
import '../core/state/city_scope.dart';
import '../core/theme/design_tokens.dart';
import '../features/transit/widgets/transit_search_form.dart';
import 'widgets/transit_results.dart';

/// Transit: multimodal route planner. Single purpose — plan a journey.
/// Live bus arrivals moved to their own page ([Routes.arrivals]).
class TransitPage extends StatefulWidget {
  final Place? initialTarget;

  const TransitPage({super.key, this.initialTarget});

  @override
  State<TransitPage> createState() => _TransitPageState();
}

class _TransitPageState extends State<TransitPage> {
  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();

  double _originLat = 0;
  double _originLng = 0;
  double _destLat = 0;
  double _destLng = 0;

  String _preference = 'fastest';
  List<RouteOption> _options = [];
  bool _calculating = false;
  String? _cityId;
  bool _seeded = false;

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final city = CityScope.of(context).current!;
    if (_cityId != city.id) {
      _cityId = city.id;
      _seeded = false;
    }
    if (!_seeded) {
      _seeded = true;
      _applyDefaults(city);
      final target = widget.initialTarget;
      if (target != null) {
        _destCtrl.text = target.name;
        _destLat = target.latitude;
        _destLng = target.longitude;
      }
      _search(city.id);
    }
  }

  void _applyDefaults(City city) {
    _originLat = city.latitude;
    _originLng = city.longitude;
    _originCtrl.text = '${city.name} Central';
    if (city.id == 'seoul') {
      _destCtrl.text = 'Gyeongbokgung Palace';
      _destLat = 37.5796;
      _destLng = 126.9770;
    } else if (city.id == 'tokyo') {
      _destCtrl.text = 'Senso-ji Temple';
      _destLat = 35.7148;
      _destLng = 139.7967;
    } else if (city.id == 'paris') {
      _destCtrl.text = 'Eiffel Tower';
      _destLat = 48.8584;
      _destLng = 2.2945;
    } else {
      _destCtrl.text = '${city.name} Landmark';
      _destLat = city.latitude + 0.015;
      _destLng = city.longitude + 0.015;
    }
  }

  Future<void> _search(String cityId) async {
    setState(() => _calculating = true);
    final opts = await TravelApiClient.planTransit(
      cityId: cityId,
      originLat: _originLat,
      originLng: _originLng,
      originName: _originCtrl.text,
      destLat: _destLat,
      destLng: _destLng,
      destName: _destCtrl.text,
      preference: _preference,
    );
    if (mounted && _cityId == cityId) {
      setState(() {
        _options = opts;
        _calculating = false;
      });
    }
  }

  void _swap() {
    final t = _originCtrl.text;
    final tLat = _originLat;
    final tLng = _originLng;
    setState(() {
      _originCtrl.text = _destCtrl.text;
      _originLat = _destLat;
      _originLng = _destLng;
      _destCtrl.text = t;
      _destLat = tLat;
      _destLng = tLng;
    });
    _search(_cityId!);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      mobile: (_) => _mobile(),
      tablet: (_) => _mobile(),
      pc: (_) => _pc(),
    );
  }

  Widget _form() {
    return TransitSearchForm(
      originCtrl: _originCtrl,
      destCtrl: _destCtrl,
      preference: _preference,
      onSwap: _swap,
      onSelectPreference: (pref) {
        setState(() => _preference = pref);
        _search(_cityId!);
      },
    );
  }

  Widget _results(City city) => TransitResults.list(
        context,
        city,
        calculating: _calculating,
        options: _options,
      );

  Widget _mobile() {
    final city = CityScope.of(context).current!;
    return SingleChildScrollView(
      child: Column(
        children: [
          _form(),
          _results(city),
          TransitResults.arrivalsLink(context),
        ],
      ),
    );
  }

  Widget _pc() {
    final city = CityScope.of(context).current!;
    return LedgerMeasure(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 380,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(LedgerTokens.s16),
              child: Column(
                children: [
                  _form(),
                  TransitResults.arrivalsLink(context),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: LedgerTokens.s16),
              child: _results(city),
            ),
          ),
        ],
      ),
    );
  }
}
