import 'package:flutter/material.dart';
import '../../../core/api/travel_api_client.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/offline/offline_city_store.dart';

class OfflinePackageController extends ChangeNotifier {
  List<OfflinePackage> packages = [];
  final Set<String> downloaded = {};
  final Set<String> busy = {};
  final Map<String, String?> versions = {};

  Future<void> load() async {
    final pkgs = await TravelApiClient.fetchOfflinePackages();
    final saved = await OfflineCityStore.savedCities();
    final vers = <String, String?>{};
    for (final city in saved) {
      vers[city] = await OfflineCityStore.version(city);
    }
    packages = pkgs;
    downloaded.clear();
    downloaded.addAll(saved);
    versions.clear();
    versions.addAll(vers);
    notifyListeners();
  }

  Future<bool> togglePackage(OfflinePackage pkg, bool remove) async {
    busy.add(pkg.cityId);
    notifyListeners();
    try {
      if (remove) {
        await OfflineCityStore.removeCity(pkg.cityId);
      } else {
        await TravelApiClient.downloadOfflinePackage(pkg.cityId);
      }
      await load();
      return true;
    } catch (_) {
      return false;
    } finally {
      busy.remove(pkg.cityId);
      notifyListeners();
    }
  }
}
