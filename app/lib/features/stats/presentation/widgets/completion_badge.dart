import 'package:app/features/stats/domain/completion_stats.dart';
import 'package:flutter/material.dart';

/// Compact rate for a period: `"2/3 verified · 67%"` plus a thin bar, or
/// `"—"` when there are no goals.
///
/// Colour follows the rate against the theme: green at 80% and up, amber
/// from 50%, red below that. The tooltip spells out that only verified
/// completions count.
class CompletionBadge extends StatelessWidget {
  const CompletionBadge(this.stats, {super.key});

  final CompletionStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = stats.percent;
    final color = _colorFor(theme.colorScheme, percent);

    return Tooltip(
      message: 'Only verified completions count',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _labelFor(stats),
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
          if (percent != null) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 4,
                color: color,
                backgroundColor: color.withValues(alpha: 0.16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _labelFor(CompletionStats stats) {
  final percent = stats.percent;
  if (percent == null) return '—';
  return '${stats.complete}/${stats.total} verified · ${(percent * 100).round()}%';
}

/// Traffic-light from the scheme where a role exists. There is no warning
/// role, so the mid band is a fixed amber, the same way complete's green
/// is not a ColorScheme slot.
Color _colorFor(ColorScheme scheme, double? percent) {
  if (percent == null) return scheme.onSurfaceVariant;
  if (percent >= 0.80) return scheme.primary;
  if (percent >= 0.50) return _amber;
  return scheme.error;
}

const _amber = Color(0xFFF9A825);
