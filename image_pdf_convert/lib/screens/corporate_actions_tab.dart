// corporate_actions_tab.dart
import 'package:flutter/material.dart';
import 'package:image_pdf_convert/models/enums_model.dart';
import 'package:intl/intl.dart';
import '../models/corporate_action_model.dart';

// class CorporateActionsTab extends StatelessWidget {
//   final List<CorporateAction> actions;

//   const CorporateActionsTab({super.key, required this.actions});

//   @override
//   Widget build(BuildContext context) {
//     if (actions.isEmpty) {
//       return const Center(
//         child: Text('No corporate actions available', style: TextStyle(fontSize: 16, color: Colors.grey)),
//       );
//     }

//     return ListView.builder(
//       itemCount: actions.length,
//       padding: const EdgeInsets.all(16),
//       itemBuilder: (context, index) {
//         final action = actions[index];
//         return _CorporateActionCard(corporateAction: action);
//       },
//     );
//   }
// }

class CorporateActionsTab extends StatefulWidget {
  final List<CorporateAction> actions;
  final bool hasMoreData;
  final Future<void> Function()? onLoadMore; // Change to Future function
  final bool isLoading;
  final VoidCallback? onRefresh;

  const CorporateActionsTab({
    super.key,
    required this.actions,
    this.hasMoreData = false,
    this.onLoadMore,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  State<CorporateActionsTab> createState() => _CorporateActionsTabState();
}

class _CorporateActionsTabState extends State<CorporateActionsTab> {
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (!_isLoadingMore && widget.hasMoreData && widget.onLoadMore != null) {
      setState(() {
        _isLoadingMore = true;
      });

      widget.onLoadMore!()
          .then((_) {
            setState(() {
              _isLoadingMore = false;
            });
          })
          .catchError((_) {
            setState(() {
              _isLoadingMore = false;
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.actions.isEmpty && !widget.isLoading) {
      return const Center(
        child: Text('No corporate actions available', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (widget.onRefresh != null) {
                widget.onRefresh!();
              }
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.actions.length + (_shouldShowLoader() ? 1 : 0),
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                if (index < widget.actions.length) {
                  final action = widget.actions[index];
                  return _CorporateActionCard(corporateAction: action);
                } else {
                  return _buildLoadingIndicator();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Corporate Actions: ${widget.actions.length}',
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          if (widget.hasMoreData) Text('More data available', style: TextStyle(color: Colors.green[700], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            if (_isLoadingMore || widget.isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Loading more corporate actions...'),
            ] else if (!widget.hasMoreData && widget.actions.isNotEmpty) ...[
              Icon(Icons.check_circle, color: Colors.green[400], size: 32),
              const SizedBox(height: 8),
              const Text('All corporate actions loaded', style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  bool _shouldShowLoader() {
    return widget.actions.isNotEmpty && (widget.hasMoreData || _isLoadingMore || widget.isLoading);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
