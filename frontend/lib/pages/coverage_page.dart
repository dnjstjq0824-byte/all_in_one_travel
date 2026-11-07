import 'package:flutter/material.dart';

import '../core/api/travel_api_client.dart';
import '../core/models/travel_models.dart';
import '../core/responsive/adaptive_page.dart';
import '../core/state/city_scope.dart';
import '../core/theme/design_tokens.dart';
import 'widgets/coverage_card.dart';
import 'widgets/coverage_header.dart';

/// Coverage: admin governance registry. Same ledger design system as
/// user pages — night header, filter rail, capability matrix cards.
class CoveragePage extends StatefulWidget {
  const CoveragePage({super.key});

  @override
  State<CoveragePage> createState() => _CoveragePageState();
}

class _CoveragePageState extends State<CoveragePage> {
  final Map<String, CoverageRegistry> _data = {};
  bool _loading = true;
  String _filter = 'ALL';
  bool _loaded = false;

  static const _filters = [
    'ALL',
    'LEVEL_A',
    'LEVEL_B',
    'LEVEL_C',
    'LEVEL_D',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadAll();
    }
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final cities = CityScope.read(context).cities;
    for (final city in cities) {
      final cov = await TravelApiClient.fetchCoverage(city.id);
      if (cov != null) _data[city.id] = cov;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      mobile: (_) => _mobile(),
      tablet: (_) => _mobile(),
      pc: (_) => _pc(),
    );
  }

  List<City> _filtered(List<City> cities) {
    if (_filter == 'ALL') return cities;
    return cities.where((c) => c.coverageLevel == _filter).toList();
  }

  Widget _head(List<City> all) => CoverageHeader(
        cities: all,
        onRefresh: _loadAll,
      );

  Widget _filterRow() => CoverageFilters(
        filters: _filters,
        selected: _filter,
        onSelect: (f) => setState(() => _filter = f),
      );

  Widget _loadingSliver() => const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      );

  Widget _mobile() {
    final all = CityScope.of(context).cities;
    final cities = _filtered(all);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LedgerTokens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _head(all),
          const SizedBox(height: LedgerTokens.s12),
          _filterRow(),
          const SizedBox(height: LedgerTokens.s12),
          if (_loading)
            _loadingSliver()
          else
            for (final c in cities) ...[
              CoverageCard(city: c, coverage: _data[c.id]),
              const SizedBox(height: LedgerTokens.s12),
            ],
        ],
      ),
    );
  }

  Widget _pc() {
    final all = CityScope.of(context).cities;
    final cities = _filtered(all);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LedgerTokens.s32),
      child: LedgerMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _head(all),
            const SizedBox(height: LedgerTokens.s12),
            _filterRow(),
            const SizedBox(height: LedgerTokens.s12),
            if (_loading)
              _loadingSliver()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 300,
                  crossAxisSpacing: LedgerTokens.s12,
                  mainAxisSpacing: LedgerTokens.s12,
                ),
                itemCount: cities.length,
                itemBuilder: (ctx, i) => CoverageCard(
                  city: cities[i],
                  coverage: _data[cities[i].id],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
