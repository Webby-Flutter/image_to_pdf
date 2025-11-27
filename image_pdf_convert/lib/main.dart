// import 'package:image_pdf_convert/providers/app_state_provider.dart';
// import 'package:provider/provider.dart';
// import 'core/theme/app_theme.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NSE Corporate Actions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const CorporateHomePage(),
    );
  }
}

class CorporateHomePage extends StatefulWidget {
  const CorporateHomePage({super.key});

  @override
  State<CorporateHomePage> createState() => _CorporateHomePageState();
}

class _CorporateHomePageState extends State<CorporateHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> dividends = [];
  List<dynamic> bonusSplits = [];
  List<dynamic> boardMeetings = [];
  List<dynamic> announcements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    setState(() => isLoading = true);

    try {
      final client = http.Client();
      final headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Referer': 'https://www.nseindia.com/',
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9',
        'X-Requested-With': 'XMLHttpRequest',
      };

      final Uri actionsUri = Uri.https('www.nseindia.com', '/api/corporates-corporateActions', {'index': 'equities'});

      final Uri meetingsUri = Uri.https('www.nseindia.com', '/api/corporate-board-meetings', {'index': 'equities'});

      final Uri annUri = Uri.https('www.nseindia.com', '/api/corporate-announcements', {'index': 'equities'});
      debugPrint("Fetching -->>$actionsUri");
      final responses = await Future.wait([
        client.get(actionsUri, headers: headers),
        client.get(meetingsUri, headers: headers),
        client.get(annUri, headers: headers),
      ]);

      final actionsRes = responses[0];
      final meetingsRes = responses[1];
      final annRes = responses[2];

      if (actionsRes.statusCode == 200 && meetingsRes.statusCode == 200 && annRes.statusCode == 200) {
        final List<dynamic> actionsData = json.decode(actionsRes.body);
        final dynamic meetingsData = json.decode(meetingsRes.body);
        final dynamic annData = json.decode(annRes.body);

        setState(() {
          dividends = actionsData
              .where((e) {
                final purpose = (e['purpose'] ?? '').toString().toLowerCase();
                return purpose.contains('dividend');
              })
              .take(15)
              .toList();

          bonusSplits = actionsData
              .where((e) {
                final purpose = (e['purpose'] ?? '').toString().toLowerCase();
                return purpose.contains('bonus') || purpose.contains('split') || purpose.contains('stock split');
              })
              .take(10)
              .toList();

          boardMeetings = (meetingsData is List ? meetingsData : <dynamic>[]).take(15).toList();
          announcements = (annData is List ? annData : <dynamic>[]).take(20).toList();

          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data: ${actionsRes.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Check internet or try again later")));
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NSE Corporate Actions"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Dividends"),
            Tab(text: "Bonus/Split"),
            Tab(text: "Board Meetings"),
            Tab(text: "Announcements"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(dividends, "No dividends found"),
                _buildList(bonusSplits, "No bonus/split announced"),
                _buildList(boardMeetings, "No board meetings"),
                _buildList(announcements, "No announcements"),
              ],
            ),
      floatingActionButton: FloatingActionButton(onPressed: fetchAllData, child: const Icon(Icons.refresh)),
    );
  }

  Widget _buildList(List<dynamic> items, String emptyMsg) {
    if (items.isEmpty) {
      return Center(child: Text(emptyMsg));
    }

    return RefreshIndicator(
      onRefresh: fetchAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          String title = "";
          String subtitle = "";
          Color color = Colors.blue;

          if (item.containsKey('purpose')) {
            // Corporate Actions
            title = item['companyName'] ?? item['symbol'] ?? 'Unknown';
            subtitle = "${item['purpose']}\nEx-Date: ${item['exDate'] ?? 'N/A'} | Record: ${item['recDate'] ?? 'N/A'}";
            color = item['purpose'].toString().toLowerCase().contains('dividend') ? Colors.green : Colors.orange;
          } else if (item.containsKey('bm_desc')) {
            // Board Meetings
            title = item['symbol'];
            subtitle = "Purpose: ${item['bm_desc']}\nDate: ${item['bm_date'] ?? 'TBA'}";
            color = Colors.purple;
          } else if (item.containsKey('desc')) {
            // Announcements
            title = item['symbol'];
            subtitle = item['desc'];
            if (item['attchmntFile'] != null && item['attchmntFile'].toString().contains('.pdf')) {
              subtitle += "\nTap to view PDF";
            }
            color = Colors.teal;
          }

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color,
                child: Text(title[0], style: const TextStyle(color: Colors.white)),
              ),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(subtitle),
              isThreeLine: true,
              onTap: item['attchmntFile'] != null
                  ? () => _launchURL("https://www.nseindia.com${item['attchmntFile']}")
                  : null,
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [ChangeNotifierProvider(create: (_) => AppStateProvider())],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'SnapPDF',
//         theme: AppTheme.lightTheme,
//         darkTheme: AppTheme.darkTheme,
//         // home: const SplashScreen(),
//       ),
//     );
//   }
// }
