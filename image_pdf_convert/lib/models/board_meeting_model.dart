// board_meeting_model.dart
import 'package:image_pdf_convert/models/enums_model.dart';
import 'package:intl/intl.dart';

class BoardMeeting {
  final String bmSymbol;
  final DateTime bmDate;
  final MeetingPurpose bmPurpose;
  final String bmDesc;
  final String smIndustry;
  final DateTime bmTimestamp;
  final String smName;
  final String smIsin;
  final String attachment;
  final String? ixbrl;
  final String diff;
  final DateTime sysTime;
  final String attFileSize;
  final String? ixbrlFileSize;
  final String? meetingType;
  final String? intimationType;
  final DateTime? originalMeetingDate;
  final DateTime? proposedMeetingDate;

  BoardMeeting({
    required this.bmSymbol,
    required this.bmDate,
    required this.bmPurpose,
    required this.bmDesc,
    required this.smIndustry,
    required this.bmTimestamp,
    required this.smName,
    required this.smIsin,
    required this.attachment,
    this.ixbrl,
    required this.diff,
    required this.sysTime,
    required this.attFileSize,
    this.ixbrlFileSize,
    this.meetingType,
    this.intimationType,
    this.originalMeetingDate,
    this.proposedMeetingDate,
  });

  factory BoardMeeting.fromJson(Map<String, dynamic> json) {
    return BoardMeeting(
      bmSymbol: json['bm_symbol'] ?? '',
      bmDate: _parseDate(json['bm_date']),
      bmPurpose: _parseMeetingPurpose(json['bm_purpose']),
      bmDesc: json['bm_desc'] ?? '',
      smIndustry: json['sm_indusrty'] ?? '-',
      bmTimestamp: _parseDateTime(json['bm_timestamp']),
      smName: json['sm_name'] ?? '',
      smIsin: json['sm_isin'] ?? '',
      attachment: json['attachment'] ?? '',
      ixbrl: json['ixbrl'],
      diff: json['diff'] ?? '',
      sysTime: _parseDateTime(json['sysTime']),
      attFileSize: json['attFileSize'] ?? '',
      ixbrlFileSize: json['ixbrlFileSize'],
      meetingType: json['meetingType'],
      intimationType: json['intimationType'],
      originalMeetingDate: json['oriiginalMeetingDate'] != null ? _parseDate(json['oriiginalMeetingDate']) : null,
      proposedMeetingDate: json['proposedMeetingDate'] != null ? _parseDate(json['proposedMeetingDate']) : null,
    );
  }

  static MeetingPurpose _parseMeetingPurpose(String purpose) {
    switch (purpose) {
      case 'Fund Raising':
        return MeetingPurpose.fundRaising;
      case 'Financial Results':
        return MeetingPurpose.financialResults;
      case 'Dividend/Other business matters':
      case 'Dividend/Other business':
        return MeetingPurpose.dividend;
      case 'Bonus':
        return MeetingPurpose.bonus;
      case 'Stock Split':
        return MeetingPurpose.stockSplit;
      case 'Buyback/Other business matters':
      case 'Buyback/Other business':
        return MeetingPurpose.buyback;
      case 'Board Meeting Intimation':
        return MeetingPurpose.boardMeetingIntimation;
      default:
        return MeetingPurpose.boardMeetingIntimation;
    }
  }

  static DateTime _parseDate(String dateString) {
    try {
      return DateFormat('dd-MMM-yyyy').parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  static DateTime _parseDateTime(String dateString) {
    try {
      return DateFormat('dd-MMM-yyyy HH:mm:ss').parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'bm_symbol': bmSymbol,
      'bm_date': DateFormat('dd-MMM-yyyy').format(bmDate),
      'bm_purpose': bmPurpose.toString(),
      'bm_desc': bmDesc,
      'sm_indusrty': smIndustry,
      'bm_timestamp': DateFormat('dd-MMM-yyyy HH:mm:ss').format(bmTimestamp),
      'sm_name': smName,
      'sm_isin': smIsin,
      'attachment': attachment,
      'ixbrl': ixbrl,
      'diff': diff,
      'sysTime': DateFormat('dd-MMM-yyyy HH:mm:ss').format(sysTime),
      'attFileSize': attFileSize,
      'ixbrlFileSize': ixbrlFileSize,
      'meetingType': meetingType,
      'intimationType': intimationType,
      'oriiginalMeetingDate': originalMeetingDate != null
          ? DateFormat('dd-MMM-yyyy').format(originalMeetingDate!)
          : null,
      'proposedMeetingDate': proposedMeetingDate != null
          ? DateFormat('dd-MMM-yyyy').format(proposedMeetingDate!)
          : null,
    };
  }
}
