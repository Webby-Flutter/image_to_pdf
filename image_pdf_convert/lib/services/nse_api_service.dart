// nse_api_service.dart
import 'package:flutter/foundation.dart';
import 'package:image_pdf_convert/models/board_meeting_model.dart';
import 'package:image_pdf_convert/models/corporate_action_model.dart';
import 'package:image_pdf_convert/models/corporate_announcement_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_pdf_convert/models/pagination_model.dart';

class NseApiServiceWithPagination {
  static const String _baseUrl = 'https://www.nseindia.com';
  static const int _pageSize = 20; // NSE default page size

  Map<String, String> _cookies = {};

  Future<Map<String, String>> _getHeaders() {
    return Future.value({
      'authority': 'www.nseindia.com',
      'accept': 'application/json, text/plain, */*',
      'accept-language': 'en-US,en;q=0.9',
      'referer': 'https://www.nseindia.com/',
      'sec-ch-ua': '"Google Chrome";v="119", "Chromium";v="119", "Not?A_Brand";v="24"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-origin',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
      'x-requested-with': 'XMLHttpRequest',
      if (_cookies.isNotEmpty) 'cookie': _getCookieString(),
    });
  }

  String _getCookieString() {
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  void _updateCookies(http.Response response) {
    final cookieHeader = response.headers['set-cookie'];
    if (cookieHeader != null) {
      final cookies = cookieHeader.split(',');
      for (var cookie in cookies) {
        final parts = cookie.split(';').first.split('=');
        if (parts.length == 2) {
          _cookies[parts[0].trim()] = parts[1].trim();
        }
      }
    }
  }

  Future<PaginatedResponse<T>> _fetchSinglePage<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    int page = 0,
    String? fromDate,
    String? toDate,
  }) async {
    await _initializeSession();

    final params = <String, String>{
      'index': 'equities',
      'from': (page * _pageSize).toString(),
      'limit': _pageSize.toString(),
    };

    if (fromDate != null) params['from_date'] = fromDate;
    if (toDate != null) params['to_date'] = toDate;
    debugPrint('Fetching $endpoint with params: $params');
    final url = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: params);
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      final items = data.map((item) => fromJson(item)).toList();

      final hasMore = items.length == _pageSize;

      return PaginatedResponse(data: items, currentPage: page, totalPages: -1, totalRecords: -1, hasMore: hasMore);
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  // Corporate Actions - Single page
  Future<PaginatedResponse<CorporateAction>> getCorporateActionsPage({
    int page = 0,
    String? fromDate,
    String? toDate,
  }) async {
    return await _fetchSinglePage<CorporateAction>(
      endpoint: '/api/corporates-corporateActions',
      fromJson: (json) => CorporateAction.fromJson(json),
      page: page,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  // Corporate Announcements - Single page
  Future<PaginatedResponse<CorporateAnnouncement>> getCorporateAnnouncementsPage({
    int page = 0,
    String? fromDate,
    String? toDate,
  }) async {
    return await _fetchSinglePage<CorporateAnnouncement>(
      endpoint: '/api/corporate-announcements',
      fromJson: (json) => CorporateAnnouncement.fromJson(json),
      page: page,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  // Board Meetings - Single page
  Future<PaginatedResponse<BoardMeeting>> getBoardMeetingsPage({int page = 0, String? fromDate, String? toDate}) async {
    return await _fetchSinglePage<BoardMeeting>(
      endpoint: '/api/corporate-board-meetings',
      fromJson: (json) => BoardMeeting.fromJson(json),
      page: page,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<void> _initializeSession() async {
    try {
      final mainResponse = await http.get(Uri.parse('$_baseUrl/'), headers: await _getHeaders());
      _updateCookies(mainResponse);

      final marketResponse = await http.get(Uri.parse('$_baseUrl/api/market-data'), headers: await _getHeaders());
      _updateCookies(marketResponse);
    } catch (e) {
      if (kDebugMode) {
        print('Session initialization error: $e');
      }
    }
  }

  // Generic method to fetch paginated data
  Future<PaginatedResponse<T>> _fetchPaginatedData<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    int page = 0, // NSE uses offset-based pagination
    String? fromDate,
    String? toDate,
  }) async {
    await _initializeSession();

    // Build query parameters
    final params = <String, String>{
      'index': 'equities',
      'from': (page * _pageSize).toString(),
      'limit': _pageSize.toString(),
    };

    if (fromDate != null) params['from_date'] = fromDate;
    if (toDate != null) params['to_date'] = toDate;

    final url = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: params);

    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      final items = data.map((item) => fromJson(item)).toList();

      // NSE doesn't provide total count in response, so we estimate
      final hasMore = items.length == _pageSize;

      return PaginatedResponse(
        data: items,
        currentPage: page,
        totalPages: -1, // NSE doesn't provide this
        totalRecords: -1, // NSE doesn't provide this
        hasMore: hasMore,
      );
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  // Get all data by fetching multiple pages
  Future<List<T>> _fetchAllData<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    int maxPages = 10, // Safety limit to avoid infinite loops
    String? fromDate,
    String? toDate,
  }) async {
    final allData = <T>[];
    int page = 0;
    bool hasMore = true;

    while (hasMore && page < maxPages) {
      try {
        final response = await _fetchPaginatedData(
          endpoint: endpoint,
          fromJson: fromJson,
          page: page,
          fromDate: fromDate,
          toDate: toDate,
        );

        allData.addAll(response.data);
        hasMore = response.hasMore;
        page++;

        debugPrint('Fetched page $page: ${response.data.length} items');

        // Add a small delay to be respectful to the API
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Error fetching page $page: $e');
        break;
      }
    }

    debugPrint('Total fetched: ${allData.length} items');
    return allData;
  }

  // Corporate Actions with pagination
  // Get latest data only (single page)
  Future<List<CorporateAction>> getLatestCorporateActions() async {
    final response = await getCorporateActionsPage(page: 0);
    return response.data;
  }

  Future<List<CorporateAnnouncement>> getLatestCorporateAnnouncements() async {
    final response = await getCorporateAnnouncementsPage(page: 0);
    return response.data;
  }

  Future<List<BoardMeeting>> getLatestBoardMeetings() async {
    final response = await getBoardMeetingsPage(page: 0);
    return response.data;
  }

  // Board Meetings with pagination
  Future<List<BoardMeeting>> getBoardMeetings({int maxPages = 5, String? fromDate, String? toDate}) async {
    return await _fetchAllData<BoardMeeting>(
      endpoint: '/api/corporate-board-meetings',
      fromJson: (json) => BoardMeeting.fromJson(json),
      maxPages: maxPages,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
