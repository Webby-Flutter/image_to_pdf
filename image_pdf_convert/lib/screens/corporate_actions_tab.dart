// corporate_actions_tab.dart
import 'package:flutter/material.dart';
import 'package:image_pdf_convert/models/enums_model.dart';
import 'package:intl/intl.dart';
import '../models/corporate_action_model.dart';

class CorporateActionsTab extends StatelessWidget {
  final List<CorporateAction> actions;

  const CorporateActionsTab({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const Center(
        child: Text('No corporate actions available', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: actions.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _CorporateActionCard(corporateAction: action);
      },
    );
  }
}

class _CorporateActionCard extends StatelessWidget {
  final CorporateAction corporateAction;

  const _CorporateActionCard({required this.corporateAction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    corporateAction.symbol,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeriesColor(corporateAction.series),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    corporateAction.series.value,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Company Name
            Text(corporateAction.comp, style: const TextStyle(fontSize: 14, color: Colors.grey)),

            const SizedBox(height: 12),

            // Subject
            Text(corporateAction.subject, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),

            const SizedBox(height: 12),

            // Dates Row
            Row(
              children: [
                _DateInfo(label: 'Ex-Date', date: corporateAction.exDate),
                const SizedBox(width: 16),
                _DateInfo(label: 'Record Date', date: corporateAction.recDate),
              ],
            ),

            const SizedBox(height: 8),

            // Additional Info
            Row(
              children: [
                _InfoChip(label: 'Face Value', value: '₹${corporateAction.faceVal}'),
                const SizedBox(width: 8),
                _InfoChip(label: 'ISIN', value: corporateAction.isin),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeriesColor(SeriesType series) {
    switch (series) {
      case SeriesType.eq:
        return Colors.green;
      case SeriesType.gs:
        return Colors.orange;
      case SeriesType.be:
        return Colors.red;
      case SeriesType.sm:
        return Colors.purple;
    }
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final DateTime date;

  const _DateInfo({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd MMM yyyy').format(date),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
      child: Text('$label: $value', style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }
}
