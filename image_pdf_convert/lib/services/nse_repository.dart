// nse_repository.dart
import 'package:image_pdf_convert/models/board_meeting_model.dart';
import 'package:image_pdf_convert/models/corporate_action_model.dart';
import 'package:image_pdf_convert/models/corporate_announcement_model.dart';
import 'package:image_pdf_convert/models/enums_model.dart';
import 'package:image_pdf_convert/services/nse_api_service.dart';

// nse_repository.dart
class NseRepository {
  // Use the direct approach with the cookie from Postman
  final NseApiService _apiService = NseApiService();

  Future<List<CorporateAction>> getCorporateActions() async {
    return await _apiService.getCorporateActions();
  }

  Future<List<CorporateAnnouncement>> getCorporateAnnouncements() async {
    return await _apiService.getCorporateAnnouncements();
  }

  Future<List<BoardMeeting>> getBoardMeetings() async {
    return await _apiService.getBoardMeetings();
  }
}

// class NseRepository {
//   final NseApiService _apiService = NseApiService();

//   Future<List<CorporateAction>> getCorporateActions() async {
//     return await _apiService.getCorporateActions();
//   }

//   Future<List<CorporateAnnouncement>> getCorporateAnnouncements() async {
//     return await _apiService.getCorporateAnnouncements();
//   }

//   Future<List<BoardMeeting>> getBoardMeetings() async {
//     return await _apiService.getBoardMeetings();
//   }

//   // Filter methods
//   Future<List<CorporateAction>> getCorporateActionsBySymbol(String symbol) async {
//     final actions = await getCorporateActions();
//     return actions.where((action) => action.symbol == symbol).toList();
//   }

//   Future<List<CorporateAction>> getUpcomingCorporateActions() async {
//     final actions = await getCorporateActions();
//     final now = DateTime.now();
//     return actions.where((action) => action.exDate.isAfter(now)).toList();
//   }

//   Future<List<CorporateAnnouncement>> getAnnouncementsByType(String type) async {
//     final announcements = await getCorporateAnnouncements();
//     return announcements.where((announcement) => announcement.desc == type).toList();
//   }

//   Future<List<BoardMeeting>> getBoardMeetingsByPurpose(MeetingPurpose purpose) async {
//     final meetings = await getBoardMeetings();
//     return meetings.where((meeting) => meeting.bmPurpose == purpose).toList();
//   }
// }
