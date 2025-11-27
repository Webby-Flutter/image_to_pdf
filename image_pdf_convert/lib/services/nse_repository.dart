// nse_repository.dart
import 'package:image_pdf_convert/models/board_meeting_model.dart';
import 'package:image_pdf_convert/models/corporate_action_model.dart';
import 'package:image_pdf_convert/models/corporate_announcement_model.dart';
import 'package:image_pdf_convert/models/pagination_model.dart';
// import 'package:image_pdf_convert/models/enums_model.dart';
import 'package:image_pdf_convert/services/nse_api_service.dart';

// nse_repository.dart
class NseRepository {
  final NseApiServiceWithPagination _apiService = NseApiServiceWithPagination();

  // Get single page of corporate actions
  Future<PaginatedResponse<CorporateAction>> getCorporateActionsPage({
    int page = 0,
    String? fromDate,
    String? toDate,
  }) async {
    return await _apiService.getCorporateActionsPage(page: page, fromDate: fromDate, toDate: toDate);
  }

  // Get single page of announcements
  Future<PaginatedResponse<CorporateAnnouncement>> getCorporateAnnouncementsPage({
    int page = 0,
    String? fromDate,
    String? toDate,
  }) async {
    return await _apiService.getCorporateAnnouncementsPage(page: page, fromDate: fromDate, toDate: toDate);
  }

  // Get single page of board meetings
  Future<PaginatedResponse<BoardMeeting>> getBoardMeetingsPage({int page = 0, String? fromDate, String? toDate}) async {
    return await _apiService.getBoardMeetingsPage(page: page, fromDate: fromDate, toDate: toDate);
  }

  // Get latest data only (single page)
  Future<List<CorporateAction>> getLatestCorporateActions() async {
    return await _apiService.getLatestCorporateActions();
  }

  Future<List<CorporateAnnouncement>> getLatestCorporateAnnouncements() async {
    return await _apiService.getLatestCorporateAnnouncements();
  }

  Future<List<BoardMeeting>> getLatestBoardMeetings() async {
    return await _apiService.getLatestBoardMeetings();
  }

  Future<List<BoardMeeting>> getAllBoardMeetings({int maxPages = 5}) async {
    return await _apiService.getBoardMeetings(maxPages: maxPages);
  }
}



// class NseRepository {
//   // Use the direct approach with the cookie from Postman
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
// }