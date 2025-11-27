import 'package:image_pdf_convert/models/enums_model.dart';
import 'package:intl/intl.dart';

// corporate_action_model.dart
class CorporateAction {
  final String symbol;
  final SeriesType series;
  final String ind;
  final String faceVal;
  final String subject;
  final DateTime exDate;
  final DateTime recDate;
  final String bcStartDate;
  final String bcEndDate;
  final String ndStartDate;
  final String comp;
  final String isin;
  final String ndEndDate;
  final DateTime? caBroadcastDate;

  CorporateAction({
    required this.symbol,
    required this.series,
    required this.ind,
    required this.faceVal,
    required this.subject,
    required this.exDate,
    required this.recDate,
    required this.bcStartDate,
    required this.bcEndDate,
    required this.ndStartDate,
    required this.comp,
    required this.isin,
    required this.ndEndDate,
    this.caBroadcastDate,
  });

  factory CorporateAction.fromJson(Map<String, dynamic> json) {
    return CorporateAction(
      symbol: json['symbol'] ?? '',
      series: SeriesTypeExtension.fromString(json['series'] ?? 'EQ'),
      ind: json['ind'] ?? '-',
      faceVal: json['faceVal'] ?? '',
      subject: json['subject'] ?? '',
      exDate: _parseDate(json['exDate']),
      recDate: _parseDate(json['recDate']),
      bcStartDate: json['bcStartDate'] ?? '-',
      bcEndDate: json['bcEndDate'] ?? '-',
      ndStartDate: json['ndStartDate'] ?? '-',
      comp: json['comp'] ?? '',
      isin: json['isin'] ?? '',
      ndEndDate: json['ndEndDate'] ?? '-',
      caBroadcastDate: json['caBroadcastDate'] != null ? _parseDate(json['caBroadcastDate']) : null,
    );
  }

  static DateTime _parseDate(String dateString) {
    try {
      return DateFormat('dd-MMM-yyyy').parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'series': series.value,
      'ind': ind,
      'faceVal': faceVal,
      'subject': subject,
      'exDate': DateFormat('dd-MMM-yyyy').format(exDate),
      'recDate': DateFormat('dd-MMM-yyyy').format(recDate),
      'bcStartDate': bcStartDate,
      'bcEndDate': bcEndDate,
      'ndStartDate': ndStartDate,
      'comp': comp,
      'isin': isin,
      'ndEndDate': ndEndDate,
      'caBroadcastDate': caBroadcastDate != null ? DateFormat('dd-MMM-yyyy').format(caBroadcastDate!) : null,
    };
  }
}
