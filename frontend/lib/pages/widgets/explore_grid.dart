import 'package:flutter/material.dart';

import '../../core/models/travel_models.dart';
import '../../core/theme/design_tokens.dart';
import '../../features/explore/widgets/explore_place_card.dart';
import 'trip_actions.dart';

/// Explore result grid and the PC category rail.
class ExploreGrid {
  ExploreGrid._();

  static Widget results(
    BuildContext context, {
    required bool loading,
    required List<Place> places,
    required WeatherReport? weather,
    required int columns,
  }) {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (places.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Text(
            'No attractions found. Try another search.',
            style: TextStyle(color: LedgerTokens.inkFaint),
          ),
        ),
      );
    }
    Widget card(int i) => ExplorePlaceCard(
          place: places[i],
          weather: weather,
          onPlanRoute: (p) => TripActions.planRoute(context, p),
          onAddToTrip: (p) => TripActions.addToTrip(context, p),
        );
    if (columns == 1) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: places.length,
        itemBuilder: (ctx, i) => card(i),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 0.78,
        crossAxisSpacing: LedgerTokens.s12,
        mainAxisSpacing: LedgerTokens.s12,
      ),
      itemCount: places.length,
      itemBuilder: (ctx, i) => card(i),
    );
  }

  static Widget categoryColumn({
    required List<String> categories,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      children: [
        for (final cat in categories)
          Padding(
            padding: const EdgeInsets.only(bottom: LedgerTokens.s4),
            child: ListTile(
              dense: true,
              selected: selected == cat,
              selectedTileColor: LedgerTokens.signalWash,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  LedgerTokens.radiusChip,
                ),
              ),
              title: Text(
                cat,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected == cat
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: selected == cat
                      ? LedgerTokens.signalDeep
                      : LedgerTokens.ink,
                ),
              ),
              trailing: selected == cat
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: LedgerTokens.signal,
                    )
                  : null,
              onTap: () => onSelect(cat),
            ),
          ),
      ],
    );
  }
}
