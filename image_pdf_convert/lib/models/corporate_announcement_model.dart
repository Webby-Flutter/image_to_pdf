import 'package:intl/intl.dart';

// corporate_announcement_model.dart
class CorporateAnnouncement {
  final String symbol;
  final String desc;
  final DateTime dt;
  final String attchmntFile;
  final String smName;
  final String smIsin;
  final DateTime anDt;
  final DateTime sortDate;
  final String seqId;
  final String? smIndustry;
  final String? orgid;
  final String attchmntText;
  final String? bflag;
  final String? oldNew;
  final String? csvName;
  final DateTime exchdisstime;
  final String difference;
  final String fileSize;
  final String attFileSize;
  final bool hasXbrl;

  CorporateAnnouncement({
    required this.symbol,
    required this.desc,
    required this.dt,
    required this.attchmntFile,
    required this.smName,
    required this.smIsin,
    required this.anDt,
    required this.sortDate,
    required this.seqId,
    this.smIndustry,
    this.orgid,
    required this.attchmntText,
    this.bflag,
    this.oldNew,
    this.csvName,
    required this.exchdisstime,
    required this.difference,
    required this.fileSize,
    required this.attFileSize,
    required this.hasXbrl,
  });

  factory CorporateAnnouncement.fromJson(Map<String, dynamic> json) {
    return CorporateAnnouncement(
      symbol: json['symbol'] ?? '',
      desc: json['desc'] ?? '',
      dt: _parseDateTimeFromNumber(json['dt']),
      attchmntFile: json['attchmntFile'] ?? '',
      smName: json['sm_name'] ?? '',
      smIsin: json['sm_isin'] ?? '',
      anDt: _parseDateTime(json['an_dt']),
      sortDate: _parseDateTime(json['sort_date']),
      seqId: json['seq_id'] ?? '',
      smIndustry: json['smIndustry'],
      orgid: json['orgid'],
      attchmntText: json['attchmntText'] ?? '',
      bflag: json['bflag'],
      oldNew: json['old_new'],
      csvName: json['csvName'],
      exchdisstime: _parseDateTime(json['exchdisstime']),
      difference: json['difference'] ?? '',
      fileSize: json['fileSize'] ?? '',
      attFileSize: json['attFileSize'] ?? '',
      hasXbrl: json['hasXbrl'] ?? false,
    );
  }

  static DateTime _parseDateTime(String dateString) {
    try {
      return DateFormat('dd-MMM-yyyy HH:mm:ss').parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  static DateTime _parseDateTimeFromNumber(dynamic dtValue) {
    try {
      if (dtValue is String) {
        // Format: 27112025111526 -> 27-11-2025 11:15:26
        final str = dtValue.toString();
        if (str.length == 14) {
          final day = str.substring(0, 2);
          final month = str.substring(2, 4);
          final year = str.substring(4, 8);
          final hour = str.substring(8, 10);
          final minute = str.substring(10, 12);
          final second = str.substring(12, 14);
          return DateFormat('dd-MM-yyyy HH:mm:ss')
              .parse('$day-$month-$year $hour:$minute:$second');
        }
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'desc': desc,
      'dt': dt.millisecondsSinceEpoch,
      'attchmntFile': attchmntFile,
      'sm_name': smName,
      'sm_isin': smIsin,
      'an_dt': DateFormat('dd-MMM-yyyy HH:mm:ss').format(anDt),
      'sort_date': DateFormat('dd-MMM-yyyy HH:mm:ss').format(sortDate),
      'seq_id': seqId,
      'smIndustry': smIndustry,
      'orgid': orgid,
      'attchmntText': attchmntText,
      'bflag': bflag,
      'old_new': oldNew,
      'csvName': csvName,
      'exchdisstime': DateFormat('dd-MMM-yyyy HH:mm:ss').format(exchdisstime),
      'difference': difference,
      'fileSize': fileSize,
      'attFileSize': attFileSize,
      'hasXbrl': hasXbrl,
    };
  }
}