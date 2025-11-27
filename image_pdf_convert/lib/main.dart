import 'package:flutter/material.dart';
import 'package:image_pdf_convert/providers/nse_data_provider.dart';
import 'package:image_pdf_convert/screens/announcements_tab.dart';
import 'package:image_pdf_convert/screens/board_meetings_tab.dart';
import 'package:image_pdf_convert/screens/corporate_actions_tab.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NseDataProvider(),
      child: MaterialApp(
        title: 'NSE India Data',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const NseDataScreen(),
      ),
    );
  }
}

class NseDataScreen extends StatefulWidget {
  const NseDataScreen({super.key});

  @override
  State<NseDataScreen> createState() => _NseDataScreenState();
}

class _NseDataScreenState extends State<NseDataScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NseDataProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NSE India Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<NseDataProvider>().loadAllData();
            },
          ),
        ],
      ),
      body: Consumer<NseDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            debugPrint('Error: ${provider.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadAllData();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Corporate Actions'),
                    Tab(text: 'Announcements'),
                    Tab(text: 'Board Meetings'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      CorporateActionsTab(actions: provider.corporateActions),
                      AnnouncementsTab(announcements: provider.corporateAnnouncements),
                      BoardMeetingsTab(meetings: provider.boardMeetings),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
