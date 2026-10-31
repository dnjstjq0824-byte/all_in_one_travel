import 'package:flutter/material.dart';
import '../../../core/api/travel_api_client.dart';
import '../../../core/models/travel_models.dart';
import '../../../core/theme/app_theme.dart';
import 'edit_trip_dialogs.dart';
import 'itinerary_item_card.dart';
import 'trip_weather_card.dart';

class TripDaysView extends StatelessWidget {
  final Trip trip;
  final int selectedDayIndex;
  final bool busy;
  final ValueChanged<int> onSelectDay;
  final VoidCallback onAddStop;
  final void Function(ItineraryItem item, bool value) onCompleteItem;
  final void Function(Future<Trip?> Function() change) onSaveChange;
  final Future<bool> Function(String title) onConfirmDelete;

  const TripDaysView({
    super.key,
    required this.trip,
    required this.selectedDayIndex,
    required this.busy,
    required this.onSelectDay,
    required this.onAddStop,
    required this.onCompleteItem,
    required this.onSaveChange,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (trip.days.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day Tabs
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: trip.days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final isSel = selectedDayIndex == i;
              return ChoiceChip(
                label: Text('Day ${i + 1}', style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                selected: isSel,
                selectedColor: AppTheme.accent,
                labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textMain),
                onSelected: (_) => onSelectDay(i),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Weather Card
        if (selectedDayIndex < trip.days.length) ...[
          TripWeatherCard(day: trip.days[selectedDayIndex]),
          const SizedBox(height: 12),
        ],

        // Schedule Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Day ${selectedDayIndex + 1} Schedule', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: onAddStop,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Stop', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),

        // Items List
        _buildItemsList(context),
      ],
    );
  }

  Widget _buildItemsList(BuildContext context) {
    if (selectedDayIndex >= trip.days.length || trip.days[selectedDayIndex].items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'No stops added for this day yet. Add places from Explore or tap "Add Stop" above!',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ),
      );
    }

    final day = trip.days[selectedDayIndex];
    return Column(
      children: day.items.map((item) {
        return ItineraryItemCard(
          item: item,
          busy: busy,
          onComplete: (v) => onCompleteItem(item, v),
          onEdit: () async {
            final fields = await EditItemDialog.show(context, item);
            if (fields != null) {
              onSaveChange(() => TravelApiClient.updateItineraryItem(trip.id, item.id, fields));
            }
          },
          onDelete: () async {
            if (await onConfirmDelete('Delete this activity?')) {
              onSaveChange(() => TravelApiClient.deleteItineraryItem(trip.id, item.id));
            }
          },
          onMove: (offset) {
            final ids = day.items.map((it) => it.id).toList();
            final i = ids.indexOf(item.id);
            final target = i + offset;
            if (i >= 0 && target >= 0 && target < ids.length) {
              ids.removeAt(i);
              ids.insert(target, item.id);
              onSaveChange(() => TravelApiClient.reorderItineraryItems(trip.id, day.dayNumber, ids));
            }
          },
        );
      }).toList(),
    );
  }
}

