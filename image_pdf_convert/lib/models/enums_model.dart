// enums.dart
enum SeriesType { eq, gs, be, sm }

enum CorporateActionType {
  interestPayment,
  faceValueSplit,
  bonus,
  demerger,
  dividend,
  buyback,
  stockSplit
}

enum AnnouncementType {
  analystMeeting,
  boardMeetingOutcome,
  creditRating,
  pressRelease,
  newspaperPublication,
  orderBagging,
  allotment,
  volumeSpurt,
  productLaunch,
  rumourVerification
}

enum MeetingPurpose {
  fundRaising,
  financialResults,
  dividend,
  bonus,
  stockSplit,
  buyback,
  boardMeetingIntimation
}

extension SeriesTypeExtension on SeriesType {
  String get value {
    switch (this) {
      case SeriesType.eq:
        return 'EQ';
      case SeriesType.gs:
        return 'GS';
      case SeriesType.be:
        return 'BE';
      case SeriesType.sm:
        return 'SM';
    }
  }
  
  static SeriesType fromString(String value) {
    switch (value) {
      case 'EQ':
        return SeriesType.eq;
      case 'GS':
        return SeriesType.gs;
      case 'BE':
        return SeriesType.be;
      case 'SM':
        return SeriesType.sm;
      default:
        return SeriesType.eq;
    }
  }
}