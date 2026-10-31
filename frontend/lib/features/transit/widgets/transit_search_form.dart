import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

class TransitSearchForm extends StatelessWidget {
  final TextEditingController originCtrl;
  final TextEditingController destCtrl;
  final String preference;
  final VoidCallback onSwap;
  final ValueChanged<String> onSelectPreference;

  const TransitSearchForm({
    super.key,
    required this.originCtrl,
    required this.destCtrl,
    required this.preference,
    required this.onSwap,
    required this.onSelectPreference,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Column(
                children: [
                  CircleAvatar(radius: 6, backgroundColor: AppTheme.accent),
                  SizedBox(
                    height: 24,
                    child: VerticalDivider(
                      color: AppTheme.accent,
                      thickness: 2,
                    ),
                  ),
                  Icon(Icons.location_on, color: Colors.red, size: 16),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: originCtrl,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        hintText: 'Starting location...',
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(height: 12),
                    TextField(
                      controller: destCtrl,
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
              IconButton(
                icon: const Icon(Icons.swap_vert, color: AppTheme.accent),
                onPressed: onSwap,
              ),
            ],
          ),
          const SizedBox(height: 12),
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
    );
  }

  Widget _buildPrefChip(String key, String label) {
    final isSel = preference == key;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSel,
      selectedColor: AppTheme.accent,
      labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textMain),
      checkmarkColor: Colors.white,
      onSelected: (_) => onSelectPreference(key),
    );
  }
}

