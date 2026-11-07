import 'package:flutter/widgets.dart';

import '../api/travel_api_client.dart';
import '../models/travel_models.dart';

/// Shared city/weather session for all routes.
///
/// Loaded once at startup; every page reads the same instance so route
/// changes never refetch the city list. Same contract as before — only the
/// delivery mechanism changed from constructor drilling to scoped state.
class CitySession extends ChangeNotifier {
  List<City> cities = const [];
  City? current;
  WeatherReport? weather;
  bool loading = true;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final list = await TravelApiClient.fetchCities();
      cities = list;
      if (list.isNotEmpty) {
        current = list.first;
        await refreshWeather();
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> select(City city) async {
    if (current?.id == city.id) return;
    current = city;
    weather = null;
    notifyListeners();
    await refreshWeather();
  }

  Future<void> refreshWeather() async {
    final id = current?.id;
    if (id == null) return;
    final report = await TravelApiClient.fetchWeather(id);
    weather = report;
    notifyListeners();
  }
}

class CityScope extends InheritedNotifier<CitySession> {
  const CityScope({
    super.key,
    required CitySession super.notifier,
    required super.child,
  });

  static CitySession of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<CityScope>();
    assert(scope != null, 'CityScope ancestor missing');
    return scope!.notifier!;
  }

  static CitySession read(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<CityScope>();
    assert(element != null, 'CityScope ancestor missing');
    return (element!.widget as CityScope).notifier!;
  }
}
