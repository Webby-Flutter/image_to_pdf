// announcements_tab.dart
import 'package:flutter/material.dart';
import 'package:image_pdf_convert/screens/other_screens/pdf_viewer_screen.dart';
import 'package:intl/intl.dart';
import '../models/corporate_announcement_model.dart';

class AnnouncementsTab extends StatelessWidget {
  final List<CorporateAnnouncement> announcements;

  const AnnouncementsTab({super.key, required this.announcements});

  @override
  Widget build(BuildContext context) {
    if (announcements.isEmpty) {
      return const Center(
        child: Text('No announcements available', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: announcements.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final announcement = announcements[index];
        return _AnnouncementCard(announcement: announcement);
      },
    );
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PdfViewerScreen(url: announcement.attchmntFile)),
                    );
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
    } else {
      return Colors.grey;
    }
  }

  String _getShortType(String type) {
    if (type.length > 15) {
      return type.split(' ').map((word) => word[0]).join('').toUpperCase();
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
