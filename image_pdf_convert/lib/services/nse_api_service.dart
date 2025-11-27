// nse_api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:image_pdf_convert/models/board_meeting_model.dart';
import 'package:image_pdf_convert/models/corporate_action_model.dart';
import 'package:image_pdf_convert/models/corporate_announcement_model.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NseApiService {
  static const String _baseUrl = 'https://www.nseindia.com';
  
  // Store cookies between requests
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
      'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
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
      // Parse cookies from response
      final cookies = cookieHeader.split(',');
      for (var cookie in cookies) {
        final parts = cookie.split(';').first.split('=');
        if (parts.length == 2) {
          _cookies[parts[0].trim()] = parts[1].trim();
        }
      }
    }
  }

  Future<void> _initializeSession() async {
    try {
      // First request to main page to get initial cookies
      final mainResponse = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: await _getHeaders(),
      );
      _updateCookies(mainResponse);

      // Second request to market data page
      final marketResponse = await http.get(
        Uri.parse('$_baseUrl/api/market-data'),
        headers: await _getHeaders(),
      );
      _updateCookies(marketResponse);

      print('Session initialized with ${_cookies.length} cookies');
    } catch (e) {
      print('Session initialization error: $e');
    }
  }

  Future<List<dynamic>> _makeApiCall(String endpoint) async {
    await _initializeSession();
    
    final url = Uri.parse('$_baseUrl$endpoint');
    print('Making API call to: $url');
    
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );

    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        print('Successfully parsed ${data.length} items');
        return data;
      } catch (e) {
        print('JSON parsing error: $e');
        print('Response body: ${response.body}');
        throw Exception('Failed to parse JSON: $e');
      }
    } else {
      print('API error: ${response.statusCode} - ${response.body}');
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<CorporateAction>> getCorporateActions() async {
    try {
      final data = await _makeApiCall('/api/corporates-corporateActions?index=equities');
      return data.map((item) => CorporateAction.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error fetching corporate actions: $e');
    }
  }

  Future<List<CorporateAnnouncement>> getCorporateAnnouncements() async {
    try {
      final data = await _makeApiCall('/api/corporate-announcements?index=equities');
      return data.map((item) => CorporateAnnouncement.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error fetching corporate announcements: $e');
    }
  }

  Future<List<BoardMeeting>> getBoardMeetings() async {
    try {
      final data = await _makeApiCall('/api/corporate-board-meetings?index=equities');
      return data.map((item) => BoardMeeting.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error fetching board meetings: $e');
    }
  }
}

// class NseApiServiceHttp {
//   static const String _baseUrl = 'https://www.nseindia.com';
//   final http.Client _client = http.Client();
  
//   // Store cookies
//   Map<String, String> _cookies = {};

//   Future<Map<String, String>> _getHeaders() async {
//     return {
//       'authority': 'www.nseindia.com',
//       'accept': 'application/json, text/plain, */*',
//       'accept-language': 'en-US,en;q=0.9',
//       'referer': 'https://www.nseindia.com/companies-listing/corporate-filings-announcements',
//       'sec-ch-ua': '"Google Chrome";v="119", "Chromium";v="119", "Not?A_Brand";v="24"',
//       'sec-ch-ua-mobile': '?0',
//       'sec-ch-ua-platform': '"Windows"',
//       'sec-fetch-dest': 'empty',
//       'sec-fetch-mode': 'cors',
//       'sec-fetch-site': 'same-origin',
//       'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
//       'x-requested-with': 'XMLHttpRequest',
//     };
//   }

//   Future<void> _initializeSession() async {
//     try {
//       // First request to get cookies
//       final response = await _client.get(
//         Uri.parse('$_baseUrl/'),
//         headers: await _getHeaders(),
//       );

//       // Save cookies from response
//       _saveCookies(response);

//       // Second request to complete session setup
//       await _client.get(
//         Uri.parse('$_baseUrl/api/market-data'),
//         headers: await _getHeadersWithCookies(),
//       );
//     } catch (e) {
//       print('Session initialization failed: $e');
//     }
//   }

//   void _saveCookies(http.Response response) {
//     final cookieHeader = response.headers['set-cookie'];
//     if (cookieHeader != null) {
//       final cookies = cookieHeader.split(',');
//       for (final cookie in cookies) {
//         final parts = cookie.split(';').first.split('=');
//         if (parts.length == 2) {
//           _cookies[parts[0].trim()] = parts[1].trim();
//         }
//       }
//     }
//   }

//   Future<Map<String, String>> _getHeadersWithCookies() async {
//     final headers = <String, String>{};
//     headers.addAll(await _getHeaders());
    
//     // Add cookies to headers
//     if (_cookies.isNotEmpty) {
//       final cookieString = _cookies.entries
//           .map((entry) => '${entry.key}=${entry.value}')
//           .join('; ');
//       headers['cookie'] = cookieString;
//     }
    
//     return headers;
//   }

//   Future<List<CorporateAction>> getCorporateActions() async {
//     await _initializeSession();
    
//     final response = await _client.get(
//       Uri.parse('$_baseUrl/api/corporates-corporateActions?index=equities'),
//       headers: await _getHeadersWithCookies(),
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((item) => CorporateAction.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to load corporate actions: ${response.statusCode}');
//     }
//   }

//   Future<List<CorporateAnnouncement>> getCorporateAnnouncements() async {
//     await _initializeSession();
    
//     final response = await _client.get(
//       Uri.parse('$_baseUrl/api/corporate-announcements?index=equities'),
//       headers: await _getHeadersWithCookies(),
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((item) => CorporateAnnouncement.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to load corporate announcements: ${response.statusCode}');
//     }
//   }

//   Future<List<BoardMeeting>> getBoardMeetings() async {
//     await _initializeSession();
    
//     final response = await _client.get(
//       Uri.parse('$_baseUrl/api/corporate-board-meetings?index=equities'),
//       headers: await _getHeadersWithCookies(),
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((item) => BoardMeeting.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to load board meetings: ${response.statusCode}');
//     }
//   }

//   void dispose() {
//     _client.close();
//   }
// }

// class NseApiService {
//   static const String _baseUrl = 'https://www.nseindia.com';
//   final Dio _dio = Dio();
//   final CookieJar _cookieJar = CookieJar();

//   NseApiService() {
//     _setupDio();
//   }

//   void _setupDio() {
//     _dio.options.baseUrl = _baseUrl;
//     _dio.options.connectTimeout = const Duration(seconds: 30);
//     _dio.options.receiveTimeout = const Duration(seconds: 30);

//     // Add cookie manager
//     _dio.interceptors.add(CookieManager(_cookieJar));

//     // Add interceptors for NSE-specific headers
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           // Set required NSE headers
//           options.headers.addAll(_getNseHeaders());
//           return handler.next(options);
//         },
//         onError: (error, handler) async {
//           if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
//             // Clear cookies and retry
//             await _cookieJar.deleteAll();
//             return handler.resolve(await _retry(error.requestOptions));
//           }
//           return handler.next(error);
//         },
//       ),
//     );
//   }

//   Map<String, String> _getNseHeaders() {
//     return {
//       'authority': 'www.nseindia.com',
//       'accept':
//           'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
//       'accept-language': 'en-US,en;q=0.9',
//       'cache-control': 'no-cache',
//       'dnt': '1',
//       'pragma': 'no-cache',
//       'sec-ch-ua': '"Google Chrome";v="119", "Chromium";v="119", "Not?A_Brand";v="24"',
//       'sec-ch-ua-mobile': '?0',
//       'sec-ch-ua-platform': '"Windows"',
//       'sec-fetch-dest': 'document',
//       'sec-fetch-mode': 'navigate',
//       'sec-fetch-site': 'none',
//       'sec-fetch-user': '?1',
//       'upgrade-insecure-requests': '1',
//       'user-agent':
//           'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
//       'Referer': 'https://www.nseindia.com/',
//       'Origin': 'https://www.nseindia.com',
//     };
//   }

//   Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
//     // First, get the main page to set cookies
//     await _dio.get('/');

//     // Then retry the original request
//     return _dio.request(
//       requestOptions.path,
//       data: requestOptions.data,
//       queryParameters: requestOptions.queryParameters,
//       options: Options(method: requestOptions.method, headers: requestOptions.headers),
//     );
//   }

//   Future<void> _initializeSession() async {
//     try {
//       // First, get the main page to set required cookies
//       await _dio.get('/', options: Options(headers: _getNseHeaders()));

//       // Then get the market data page to complete session setup
//       await _dio.get('/api/market-data', options: Options(headers: _getNseHeaders()));
//     } catch (e) {
//       print('Session initialization failed: $e');
//     }
//   }

//   Future<List<CorporateAction>> getCorporateActions() async {
//     try {
//       await _initializeSession();

//       final response = await _dio.get(
//         '/api/corporates-corporateActions',
//         queryParameters: {'index': 'equities'},
//         options: Options(headers: _getNseHeaders()),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data;
//         return data.map((item) => CorporateAction.fromJson(item)).toList();
//       } else {
//         throw Exception('Failed to load corporate actions: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching corporate actions: $e');
//     }
//   }

//   Future<List<CorporateAnnouncement>> getCorporateAnnouncements() async {
//     try {
//       await _initializeSession();

//       final response = await _dio.get(
//         '/api/corporate-announcements',
//         queryParameters: {'index': 'equities'},
//         options: Options(headers: _getNseHeaders()),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data;
//         return data.map((item) => CorporateAnnouncement.fromJson(item)).toList();
//       } else {
//         throw Exception('Failed to load corporate announcements: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching corporate announcements: $e');
//     }
//   }

//   Future<List<BoardMeeting>> getBoardMeetings() async {
//     try {
//       await _initializeSession();

//       final response = await _dio.get(
//         '/api/corporate-board-meetings',
//         queryParameters: {'index': 'equities'},
//         options: Options(headers: _getNseHeaders()),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data;
//         return data.map((item) => BoardMeeting.fromJson(item)).toList();
//       } else {
//         throw Exception('Failed to load board meetings: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching board meetings: $e');
//     }
//   }
// }
