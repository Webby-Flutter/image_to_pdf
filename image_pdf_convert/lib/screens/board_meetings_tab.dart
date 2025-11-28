// board_meetings_tab.dart
import 'package:flutter/material.dart';
import 'package:image_pdf_convert/models/enums_model.dart';
import 'package:image_pdf_convert/screens/other_screens/pdf_viewer_screen.dart';
import 'package:intl/intl.dart';
import '../models/board_meeting_model.dart';

class BoardMeetingsTab extends StatelessWidget {
  final List<BoardMeeting> meetings;

  const BoardMeetingsTab({super.key, required this.meetings});

  @override
  Widget build(BuildContext context) {
    if (meetings.isEmpty) {
      return const Center(
        child: Text('No board meetings available', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    // Group meetings by date
    final groupedMeetings = _groupMeetingsByDate(meetings);

    return ListView.builder(
      itemCount: groupedMeetings.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final date = groupedMeetings.keys.elementAt(index);
        final dateMeetings = groupedMeetings[date]!;

        return _DateGroup(date: date, meetings: dateMeetings);
      },
    );
  }

  Map<DateTime, List<BoardMeeting>> _groupMeetingsByDate(List<BoardMeeting> meetings) {
    final Map<DateTime, List<BoardMeeting>> grouped = {};

    for (final meeting in meetings) {
      final date = DateTime(meeting.bmDate.year, meeting.bmDate.month, meeting.bmDate.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(meeting);
    }

    // Sort dates in ascending order
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedMap = <DateTime, List<BoardMeeting>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }
}

class _DateGroup extends StatelessWidget {
  final DateTime date;
  final List<BoardMeeting> meetings;

  const _DateGroup({required this.date, required this.meetings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            DateFormat('EEEE, MMMM d, yyyy').format(date),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),

        // Meetings for this date
        ...meetings.map((meeting) => _BoardMeetingCard(meeting: meeting)),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _BoardMeetingCard extends StatelessWidget {
  final BoardMeeting meeting;

  const _BoardMeetingCard({required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    meeting.bmSymbol,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
                _MeetingPurposeBadge(purpose: meeting.bmPurpose),
              ],
            ),

            const SizedBox(height: 4),

            // Company Name
            Text(meeting.smName, style: const TextStyle(fontSize: 14, color: Colors.grey)),

            const SizedBox(height: 8),

            // Purpose
            Text(
              meeting.bmPurpose.toString().split('.').last,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.deepPurple),
            ),

            const SizedBox(height: 8),

            // Description
            Text(meeting.bmDesc, style: const TextStyle(fontSize: 14), maxLines: 3, overflow: TextOverflow.ellipsis),

            const SizedBox(height: 8),

            // Meeting Time
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm').format(meeting.bmTimestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Attachment and XBRL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (meeting.attachment.isNotEmpty)
                  _AttachmentInfo(fileSize: meeting.attFileSize, hasXbrl: meeting.ixbrl != null),
                _TimeDiffBadge(diff: meeting.diff),
              ],
            ),

            const SizedBox(height: 8),

            // Action Buttons
            Row(
              children: [
                if (meeting.attachment.isNotEmpty)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PdfViewerScreen(url: meeting.attachment)),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('View Notice', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                if (meeting.ixbrl != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _openXbrl(meeting.ixbrl!, context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('View XBRL', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ],
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
        title: const Text('Board Meeting Notice'),
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

  void _openXbrl(String url, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('XBRL Document'),
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

class _MeetingPurposeBadge extends StatelessWidget {
  final MeetingPurpose purpose;

  const _MeetingPurposeBadge({required this.purpose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _getPurposeColor(purpose), borderRadius: BorderRadius.circular(4)),
      child: Text(
        _getPurposeText(purpose),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getPurposeColor(MeetingPurpose purpose) {
    switch (purpose) {
      case MeetingPurpose.fundRaising:
        return Colors.orange;
      case MeetingPurpose.financialResults:
        return Colors.green;
      case MeetingPurpose.dividend:
        return Colors.blue;
      case MeetingPurpose.bonus:
        return Colors.purple;
      case MeetingPurpose.stockSplit:
        return Colors.teal;
      case MeetingPurpose.buyback:
        return Colors.red;
      case MeetingPurpose.boardMeetingIntimation:
        return Colors.grey;
    }
  }

  String _getPurposeText(MeetingPurpose purpose) {
    switch (purpose) {
      case MeetingPurpose.fundRaising:
        return 'Fund Raising';
      case MeetingPurpose.financialResults:
        return 'Results';
      case MeetingPurpose.dividend:
        return 'Dividend';
      case MeetingPurpose.bonus:
        return 'Bonus';
      case MeetingPurpose.stockSplit:
        return 'Split';
      case MeetingPurpose.buyback:
        return 'Buyback';
      case MeetingPurpose.boardMeetingIntimation:
        return 'Intimation';
    }
  }
}

class _AttachmentInfo extends StatelessWidget {
  final String fileSize;
  final bool hasXbrl;

  const _AttachmentInfo({required this.fileSize, required this.hasXbrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.attachment, size: 14, color: Colors.grey[600]),
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

class _TimeDiffBadge extends StatelessWidget {
  final String diff;

  const _TimeDiffBadge({required this.diff});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: _getDiffColor(diff), borderRadius: BorderRadius.circular(4)),
      child: Text(
        diff,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getDiffColor(String diff) {
    if (diff == '00:00:00') {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }
}
