// announcements_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/corporate_announcement_model.dart';

class AnnouncementsTab extends StatefulWidget {
  final List<CorporateAnnouncement> announcements;
  final bool hasMoreData;
  final Future<void> Function()? onLoadMore;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const AnnouncementsTab({
    super.key,
    required this.announcements,
    this.hasMoreData = false,
    this.onLoadMore,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  State<AnnouncementsTab> createState() => _AnnouncementsTabState();
}

class _AnnouncementsTabState extends State<AnnouncementsTab> {
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
    if (widget.announcements.isEmpty && !widget.isLoading) {
      return const Center(
        child: Text('No announcements available', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return Column(
      children: [
        // Header with count
        _buildHeader(),

        // Announcements list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (widget.onRefresh != null) {
                widget.onRefresh!();
              }
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.announcements.length + (_shouldShowLoader() ? 1 : 0),
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                if (index < widget.announcements.length) {
                  final announcement = widget.announcements[index];
                  return _AnnouncementCard(announcement: announcement);
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
            'Total Announcements: ${widget.announcements.length}',
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
              const Text('Loading more announcements...'),
            ] else if (!widget.hasMoreData && widget.announcements.isNotEmpty) ...[
              Icon(Icons.check_circle, color: Colors.green[400], size: 32),
              const SizedBox(height: 8),
              const Text('All announcements loaded', style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  bool _shouldShowLoader() {
    return widget.announcements.isNotEmpty && (widget.hasMoreData || _isLoadingMore || widget.isLoading);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _AnnouncementCard extends StatelessWidget {
  final CorporateAnnouncement announcement;

  const _AnnouncementCard({required this.announcement});

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    announcement.symbol,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
                _AnnouncementTypeBadge(type: announcement.desc),
              ],
            ),

            const SizedBox(height: 4),

            // Company Name
            Text(announcement.smName, style: const TextStyle(fontSize: 14, color: Colors.grey)),

            const SizedBox(height: 12),

            // Description
            Text(
              announcement.desc,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.deepPurple),
            ),

            const SizedBox(height: 8),

            // Announcement Text
            Text(
              announcement.attchmntText,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Dates and Time
            Row(
              children: [
                _TimeInfo(label: 'Announced', time: announcement.anDt),
                const SizedBox(width: 16),
                _TimeInfo(label: 'Disclosed', time: announcement.exchdisstime),
              ],
            ),

            const SizedBox(height: 8),

            // File Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (announcement.attchmntFile.isNotEmpty)
                  _FileInfo(fileSize: announcement.attFileSize, hasXbrl: announcement.hasXbrl),
                _DifferenceBadge(difference: announcement.difference),
              ],
            ),

            const SizedBox(height: 8),

            // Attachment Button
            if (announcement.attchmntFile.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _openAttachment(announcement.attchmntFile, context);
                  },
                  icon: const Icon(Icons.attachment, size: 16),
                  label: const Text('View Attachment'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openAttachment(String url, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attachment'),
        content: Text('Open: $url'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          TextButton(
            onPressed: () {
              // Implement URL launching
              Navigator.pop(context);
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementTypeBadge extends StatelessWidget {
  final String type;

  const _AnnouncementTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _getTypeColor(type), borderRadius: BorderRadius.circular(12)),
      child: Text(
        _getShortType(type),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getTypeColor(String type) {
    if (type.toLowerCase().contains('analyst') || type.toLowerCase().contains('meet')) {
      return Colors.orange;
    } else if (type.toLowerCase().contains('board')) {
      return Colors.green;
    } else if (type.toLowerCase().contains('rating')) {
      return Colors.purple;
    } else if (type.toLowerCase().contains('press')) {
      return Colors.blue;
    } else if (type.toLowerCase().contains('order')) {
      return Colors.red;
    } else if (type.toLowerCase().contains('newspaper')) {
      return Colors.teal;
    } else {
      return Colors.grey;
    }
  }

  String _getShortType(String type) {
    if (type.length > 15) {
      final words = type.split(' ');
      if (words.length > 1) {
        return words.map((word) => word[0]).join('').toUpperCase();
      }
      return type.substring(0, 3).toUpperCase();
    }
    return type;
  }
}

class _TimeInfo extends StatelessWidget {
  final String label;
  final DateTime time;

  const _TimeInfo({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd MMM yyyy HH:mm').format(time),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _FileInfo extends StatelessWidget {
  final String fileSize;
  final bool hasXbrl;

  const _FileInfo({required this.fileSize, required this.hasXbrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.description, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(fileSize, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        if (hasXbrl) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
            child: const Text(
              'XBRL',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }
}

class _DifferenceBadge extends StatelessWidget {
  final String difference;

  const _DifferenceBadge({required this.difference});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _getDifferenceColor(difference), borderRadius: BorderRadius.circular(4)),
      child: Text(
        difference,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getDifferenceColor(String difference) {
    if (difference == '00:00:00') {
      return Colors.green;
    } else if (difference.startsWith('00:00:')) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}


// class AnnouncementsTab extends StatelessWidget {
//   final List<CorporateAnnouncement> announcements;

//   const AnnouncementsTab({super.key, required this.announcements});

//   @override
//   Widget build(BuildContext context) {
//     if (announcements.isEmpty) {
//       return const Center(
//         child: Text(
//           'No announcements available',
//           style: TextStyle(fontSize: 16, color: Colors.grey),
//         ),
//       );
//     }

//     return ListView.builder(
//       itemCount: announcements.length,
//       padding: const EdgeInsets.all(16),
//       itemBuilder: (context, index) {
//         final announcement = announcements[index];
//         return _AnnouncementCard(announcement: announcement);
//       },
//     );
//   }
// }

// class _AnnouncementCard extends StatelessWidget {
//   final CorporateAnnouncement announcement;

//   const _AnnouncementCard({required this.announcement});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     announcement.symbol,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ),
//                 _AnnouncementTypeBadge(type: announcement.desc),
//               ],
//             ),
            
//             const SizedBox(height: 4),
            
//             // Company Name
//             Text(
//               announcement.smName,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
            
//             const SizedBox(height: 12),
            
//             // Description
//             Text(
//               announcement.desc,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.deepPurple,
//               ),
//             ),
            
//             const SizedBox(height: 8),
            
//             // Announcement Text
//             Text(
//               announcement.attchmntText,
//               style: const TextStyle(fontSize: 14),
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//             ),
            
//             const SizedBox(height: 12),
            
//             // Dates and Time
//             Row(
//               children: [
//                 _TimeInfo(
//                   label: 'Announced',
//                   time: announcement.anDt,
//                 ),
//                 const SizedBox(width: 16),
//                 _TimeInfo(
//                   label: 'Disclosed',
//                   time: announcement.exchdisstime,
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 8),
            
//             // File Info
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 if (announcement.attchmntFile.isNotEmpty)
//                   _FileInfo(
//                     fileSize: announcement.attFileSize,
//                     hasXbrl: announcement.hasXbrl,
//                   ),
//                 _DifferenceBadge(difference: announcement.difference),
//               ],
//             ),
            
//             const SizedBox(height: 8),
            
//             // Attachment Button
//             if (announcement.attchmntFile.isNotEmpty)
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: () {
//                     _openAttachment(announcement.attchmntFile, context);
//                   },
//                   icon: const Icon(Icons.attachment, size: 16),
//                   label: const Text('View Attachment'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.blue,
//                     side: const BorderSide(color: Colors.blue),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _openAttachment(String url, BuildContext context) {
//     // You can use url_launcher package to open the URL
//     // or show a dialog with the PDF viewer
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Attachment'),
//         content: Text('Open: $url'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//           TextButton(
//             onPressed: () {
//               // Implement URL launching
//               Navigator.pop(context);
//             },
//             child: const Text('Open'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AnnouncementTypeBadge extends StatelessWidget {
//   final String type;

//   const _AnnouncementTypeBadge({required this.type});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: _getTypeColor(type),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         _getShortType(type),
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Color _getTypeColor(String type) {
//     if (type.toLowerCase().contains('analyst') || type.toLowerCase().contains('meet')) {
//       return Colors.orange;
//     } else if (type.toLowerCase().contains('board')) {
//       return Colors.green;
//     } else if (type.toLowerCase().contains('rating')) {
//       return Colors.purple;
//     } else if (type.toLowerCase().contains('press')) {
//       return Colors.blue;
//     } else {
//       return Colors.grey;
//     }
//   }

//   String _getShortType(String type) {
//     if (type.length > 15) {
//       return type.split(' ').map((word) => word[0]).join('').toUpperCase();
//     }
//     return type;
//   }
// }

// class _TimeInfo extends StatelessWidget {
//   final String label;
//   final DateTime time;

//   const _TimeInfo({required this.label, required this.time});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             DateFormat('dd MMM yyyy HH:mm').format(time),
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _FileInfo extends StatelessWidget {
//   final String fileSize;
//   final bool hasXbrl;

//   const _FileInfo({required this.fileSize, required this.hasXbrl});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(
//           Icons.description,
//           size: 16,
//           color: Colors.grey[600],
//         ),
//         const SizedBox(width: 4),
//         Text(
//           fileSize,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//         if (hasXbrl) ...[
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//             decoration: BoxDecoration(
//               color: Colors.green,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: const Text(
//               'XBRL',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }
// }

// class _DifferenceBadge extends StatelessWidget {
//   final String difference;

//   const _DifferenceBadge({required this.difference});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: _getDifferenceColor(difference),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         difference,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Color _getDifferenceColor(String difference) {
//     if (difference == '00:00:00') {
//       return Colors.green;
//     } else if (difference.startsWith('00:00:')) {
//       return Colors.orange;
//     } else {
//       return Colors.red;
//     }
//   }
// }