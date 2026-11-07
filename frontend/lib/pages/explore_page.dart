import 'package:flutter/material.dart';

import '../core/api/travel_api_client.dart';
import '../core/l10n/app_localizations.dart';
import '../core/models/travel_models.dart';
import '../core/responsive/adaptive_page.dart';
import '../core/state/city_scope.dart';
import '../core/theme/design_tokens.dart';
import 'widgets/explore_grid.dart';

/// Explore: attraction index. Single purpose — search, filter, open.
/// Details, routing and trip capture each live on their own page.
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<Place> _places = [];
  bool _loading = true;
  String _category = 'All';
  final _search = TextEditingController();
  String? _cityId;

  static const _categories = [
    'All',
    'Historic & Culture',
    'Landmark',
    'Museum & Art',
    'Nature & Park',
    'Food & Market',
    'Night View',
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = CityScope.of(context).current?.id;
    if (id != null && id != _cityId) {
      _cityId = id;
      _load(id);
    }
  }

  Future<void> _load(String cityId) async {
    setState(() => _loading = true);
    final cat = _category == 'All' ? null : _category;
    final q = _search.text.trim().isEmpty ? null : _search.text.trim();
    final list = await TravelApiClient.fetchPlaces(
      cityId,
      query: q,
      category: cat,
    );
    if (mounted && _cityId == cityId) {
      setState(() {
        _places = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      mobile: (_) => _mobile(),
      tablet: (_) => _tablet(),
      pc: (_) => _pc(),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _search,
      decoration: InputDecoration(
        hintText: AppLocale.tr('search_placeholder'),
        prefixIcon: const Icon(Icons.search, size: 19),
        suffixIcon: _search.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _search.clear();
                  _load(_cityId!);
                },
              )
            : null,
      ),
      onSubmitted: (_) => _load(_cityId!),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _categoryRow() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: LedgerTokens.s8),
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final sel = _category == cat;
          return ChoiceChip(
            label: Text(
              cat,
              style: TextStyle(
                fontSize: 12,
                fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            selected: sel,
            selectedColor: LedgerTokens.signal,
            labelStyle: TextStyle(
              color: sel ? Colors.white : LedgerTokens.ink,
            ),
            onSelected: (_) {
              setState(() => _category = cat);
              _load(_cityId!);
            },
          );
        },
      ),
    );
  }

  Widget _grid(int columns) => ExploreGrid.results(
        context,
        loading: _loading,
        places: _places,
        weather: CityScope.of(context).weather,
        columns: columns,
      );

  Widget _mobile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LedgerTokens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${CityScope.of(context).current!.name} attractions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: LedgerTokens.s12),
          _searchField(),
          const SizedBox(height: LedgerTokens.s12),
          _categoryRow(),
          const SizedBox(height: LedgerTokens.s12),
          _grid(1),
        ],
      ),
    );
  }

  Widget _tablet() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LedgerTokens.s24),
      child: LedgerMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${CityScope.of(context).current!.name} attractions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: LedgerTokens.s12),
            _searchField(),
            const SizedBox(height: LedgerTokens.s12),
            _categoryRow(),
            const SizedBox(height: LedgerTokens.s12),
            _grid(2),
          ],
        ),
      ),
    );
  }

  Widget _pc() {
    return LedgerMeasure(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(LedgerTokens.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${CityScope.of(context).current!.name} attractions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: LedgerTokens.s12),
                  _searchField(),
                  const SizedBox(height: LedgerTokens.s16),
                  const LedgerRule(label: 'CATEGORY'),
                  const SizedBox(height: LedgerTokens.s8),
                  _categoryColumn(),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(LedgerTokens.s24),
              child: _grid(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryColumn() => ExploreGrid.categoryColumn(
        categories: _categories,
        selected: _category,
        onSelect: (cat) {
          setState(() => _category = cat);
          _load(_cityId!);
        },
      );
}
