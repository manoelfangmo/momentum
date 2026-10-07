import 'package:app/core/domain/domain.dart';
import 'package:flutter/material.dart';

/// Names the ended period a group of history goals belongs to.
///
/// T14 adds this period's completion stats under the label.
class HistoryPeriodHeader extends StatelessWidget {
  const HistoryPeriodHeader({super.key, required this.period});

  final Period period;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period.label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          // T14 adds this period's completion stats here.
        ],
      ),
    );
  }
}
