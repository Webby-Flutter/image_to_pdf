// nse_data_provider.dart
import 'package:flutter/foundation.dart';
import 'package:image_pdf_convert/models/board_meeting_model.dart';
import 'package:image_pdf_convert/models/corporate_action_model.dart';
import 'package:image_pdf_convert/models/corporate_announcement_model.dart';
import 'package:image_pdf_convert/services/nse_repository.dart';

// nse_data_provider.dart
class NseDataProvider with ChangeNotifier {
  final NseRepository _repository = NseRepository();

  List<CorporateAction> _corporateActions = [];
  List<CorporateAnnouncement> _corporateAnnouncements = [];
  List<BoardMeeting> _boardMeetings = [];

  bool _isLoading = false;
  String? _error;

  // Pagination tracking
  int _corporateActionsPage = 0;
  int _announcementsPage = 0;
  int _boardMeetingsPage = 0;

  bool _hasMoreCorporateActions = true;
  bool _hasMoreAnnouncements = true;
  bool _hasMoreBoardMeetings = true;

  bool _isLoadingMoreCorporateActions = false;
  bool _isLoadingMoreAnnouncements = false;
  bool _isLoadingMoreBoardMeetings = false;

  // Getters
  List<CorporateAction> get corporateActions => _corporateActions;
  List<CorporateAnnouncement> get corporateAnnouncements => _corporateAnnouncements;
  List<BoardMeeting> get boardMeetings => _boardMeetings;

  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasMoreCorporateActions => _hasMoreCorporateActions;
  bool get hasMoreAnnouncements => _hasMoreAnnouncements;
  bool get hasMoreBoardMeetings => _hasMoreBoardMeetings;

  bool get isLoadingMoreCorporateActions => _isLoadingMoreCorporateActions;
  bool get isLoadingMoreAnnouncements => _isLoadingMoreAnnouncements;
  bool get isLoadingMoreBoardMeetings => _isLoadingMoreBoardMeetings;

  // Load initial data (first page only)
  Future<void> loadInitialData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([_loadInitialCorporateActions(), _loadInitialAnnouncements(), _loadInitialBoardMeetings()]);
    } catch (e) {
      _error = 'Failed to load data: $e';
      debugPrint('Error loading NSE data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CORPORATE ACTIONS PAGINATION
  Future<void> _loadInitialCorporateActions() async {
    _corporateActionsPage = 0;
    _hasMoreCorporateActions = true;
    _corporateActions.clear();

    await _loadMoreCorporateActions();
  }

  Future<void> loadMoreCorporateActions() async {
    if (_isLoadingMoreCorporateActions || !_hasMoreCorporateActions) return;
    await _loadMoreCorporateActions();
  }

  Future<void> _loadMoreCorporateActions() async {
    _isLoadingMoreCorporateActions = true;
    notifyListeners();

    try {
      final response = await _repository.getCorporateActionsPage(page: _corporateActionsPage);

      if (response.data.isNotEmpty) {
        // Only add new data, don't replace
        _corporateActions.addAll(response.data);
        _hasMoreCorporateActions = response.hasMore;
        _corporateActionsPage++;

        debugPrint(
          'Loaded corporate actions page $_corporateActionsPage: ${response.data.length} items. Total: ${_corporateActions.length}',
        );
      } else {
        _hasMoreCorporateActions = false;
      }
    } catch (e) {
      _error = 'Failed to load more corporate actions: $e';
      debugPrint('Error loading more corporate actions: $e');
    } finally {
      _isLoadingMoreCorporateActions = false;
      notifyListeners();
    }
  }

  Future<void> refreshCorporateActions() async {
    _corporateActionsPage = 0;
    _hasMoreCorporateActions = true;
    _corporateActions.clear();
    notifyListeners();

    await _loadMoreCorporateActions();
  }

  // ANNOUNCEMENTS PAGINATION
  Future<void> _loadInitialAnnouncements() async {
    _announcementsPage = 0;
    _hasMoreAnnouncements = true;
    _corporateAnnouncements.clear();

    await _loadMoreAnnouncements();
  }

  Future<void> loadMoreAnnouncements() async {
    if (_isLoadingMoreAnnouncements || !_hasMoreAnnouncements) return;
    await _loadMoreAnnouncements();
  }

  Future<void> _loadMoreAnnouncements() async {
    _isLoadingMoreAnnouncements = true;
    notifyListeners();

    try {
      final response = await _repository.getCorporateAnnouncementsPage(page: _announcementsPage);

      if (response.data.isNotEmpty) {
        // Only add new data, don't replace
        _corporateAnnouncements.addAll(response.data);
        _hasMoreAnnouncements = response.hasMore;
        _announcementsPage++;

        debugPrint(
          'Loaded announcements page $_announcementsPage: ${response.data.length} items. Total: ${_corporateAnnouncements.length}',
        );
      } else {
        _hasMoreAnnouncements = false;
      }
    } catch (e) {
      _error = 'Failed to load more announcements: $e';
      debugPrint('Error loading more announcements: $e');
    } finally {
      _isLoadingMoreAnnouncements = false;
      notifyListeners();
    }
  }

  Future<void> refreshAnnouncements() async {
    _announcementsPage = 0;
    _hasMoreAnnouncements = true;
    _corporateAnnouncements.clear();
    notifyListeners();

    await _loadMoreAnnouncements();
  }

  // BOARD MEETINGS PAGINATION
  Future<void> _loadInitialBoardMeetings() async {
    _boardMeetingsPage = 0;
    _hasMoreBoardMeetings = true;
    _boardMeetings.clear();

    await _loadMoreBoardMeetings();
  }

  Future<void> loadMoreBoardMeetings() async {
    if (_isLoadingMoreBoardMeetings || !_hasMoreBoardMeetings) return;
    await _loadMoreBoardMeetings();
  }

  Future<void> _loadMoreBoardMeetings() async {
    _isLoadingMoreBoardMeetings = true;
    notifyListeners();

    try {
      final response = await _repository.getBoardMeetingsPage(page: _boardMeetingsPage);

      if (response.data.isNotEmpty) {
        // Only add new data, don't replace
        _boardMeetings.addAll(response.data);
        _hasMoreBoardMeetings = response.hasMore;
        _boardMeetingsPage++;

        debugPrint(
          'Loaded board meetings page $_boardMeetingsPage: ${response.data.length} items. Total: ${_boardMeetings.length}',
        );
      } else {
        _hasMoreBoardMeetings = false;
      }
    } catch (e) {
      _error = 'Failed to load more board meetings: $e';
      debugPrint('Error loading more board meetings: $e');
    } finally {
      _isLoadingMoreBoardMeetings = false;
      notifyListeners();
    }
  }

  Future<void> refreshBoardMeetings() async {
    _boardMeetingsPage = 0;
    _hasMoreBoardMeetings = true;
    _boardMeetings.clear();
    notifyListeners();

    await _loadMoreBoardMeetings();
  }

  // Clear methods
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearAllData() {
    _corporateActions.clear();
    _corporateAnnouncements.clear();
    _boardMeetings.clear();

    _corporateActionsPage = 0;
    _announcementsPage = 0;
    _boardMeetingsPage = 0;

    _hasMoreCorporateActions = true;
    _hasMoreAnnouncements = true;
    _hasMoreBoardMeetings = true;

    notifyListeners();
  }
}



// class NseDataProvider with ChangeNotifier {
//   final NseRepository _repository = NseRepository();

//   List<CorporateAction> _corporateActions = [];
//   List<CorporateAnnouncement> _corporateAnnouncements = [];
//   List<BoardMeeting> _boardMeetings = [];
//   bool _isLoading = false;
//   String? _error;

//   List<CorporateAction> get corporateActions => _corporateActions;
//   List<CorporateAnnouncement> get corporateAnnouncements => _corporateAnnouncements;
//   List<BoardMeeting> get boardMeetings => _boardMeetings;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   Future<void> loadAllData() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       // Load data sequentially to avoid overwhelming the API
//       await _loadCorporateActions();
//       await _loadCorporateAnnouncements();
//       await _loadBoardMeetings();
//     } catch (e) {
//       _error = 'Failed to load data: $e';
//       if (kDebugMode) {
//         print('Error loading NSE data: $e');
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> _loadCorporateActions() async {
//     try {
//       _corporateActions = await _repository.getCorporateActions();
//       if (kDebugMode) {
//         print('Loaded ${_corporateActions.length} corporate actions');
//       }
//     } catch (e) {
//       _error = 'Failed to load corporate actions: $e';
//       rethrow;
//     }
//   }

//   Future<void> _loadCorporateAnnouncements() async {
//     try {
//       _corporateAnnouncements = await _repository.getCorporateAnnouncements();
//       if (kDebugMode) {
//         print('Loaded ${_corporateAnnouncements.length} corporate announcements');
//       }
//     } catch (e) {
//       _error = 'Failed to load corporate announcements: $e';
//       rethrow;
//     }
//   }

//   Future<void> _loadBoardMeetings() async {
//     try {
//       _boardMeetings = await _repository.getBoardMeetings();
//       if (kDebugMode) {
//         print('Loaded ${_boardMeetings.length} board meetings');
//       }
//     } catch (e) {
//       _error = 'Failed to load board meetings: $e';
//       rethrow;
//     }
//   }

//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }