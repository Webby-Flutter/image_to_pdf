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

  List<CorporateAction> get corporateActions => _corporateActions;
  List<CorporateAnnouncement> get corporateAnnouncements => _corporateAnnouncements;
  List<BoardMeeting> get boardMeetings => _boardMeetings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load data sequentially to avoid overwhelming the API
      await _loadCorporateActions();
      await _loadCorporateAnnouncements();
      await _loadBoardMeetings();
    } catch (e) {
      _error = 'Failed to load data: $e';
      if (kDebugMode) {
        print('Error loading NSE data: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCorporateActions() async {
    try {
      _corporateActions = await _repository.getCorporateActions();
      if (kDebugMode) {
        print('Loaded ${_corporateActions.length} corporate actions');
      }
    } catch (e) {
      _error = 'Failed to load corporate actions: $e';
      rethrow;
    }
  }

  Future<void> _loadCorporateAnnouncements() async {
    try {
      _corporateAnnouncements = await _repository.getCorporateAnnouncements();
      if (kDebugMode) {
        print('Loaded ${_corporateAnnouncements.length} corporate announcements');
      }
    } catch (e) {
      _error = 'Failed to load corporate announcements: $e';
      rethrow;
    }
  }

  Future<void> _loadBoardMeetings() async {
    try {
      _boardMeetings = await _repository.getBoardMeetings();
      if (kDebugMode) {
        print('Loaded ${_boardMeetings.length} board meetings');
      }
    } catch (e) {
      _error = 'Failed to load board meetings: $e';
      rethrow;
    }
  }

  void clearError() {
    _error = null;
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
//       await Future.wait([_loadCorporateActions(), _loadCorporateAnnouncements(), _loadBoardMeetings()]);
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> _loadCorporateActions() async {
//     try {
//       _corporateActions = await _repository.getCorporateActions();
//     } catch (e) {
//       _error = 'Failed to load corporate actions: $e';
//     }
//   }

//   Future<void> _loadCorporateAnnouncements() async {
//     try {
//       _corporateAnnouncements = await _repository.getCorporateAnnouncements();
//     } catch (e) {
//       _error = 'Failed to load corporate announcements: $e';
//     }
//   }

//   Future<void> _loadBoardMeetings() async {
//     try {
//       _boardMeetings = await _repository.getBoardMeetings();
//     } catch (e) {
//       _error = 'Failed to load board meetings: $e';
//     }
//   }

//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }
