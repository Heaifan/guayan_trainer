import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_info.dart';
import '../domain/calendar/calendar_engine.dart';
import '../domain/calendar/import/calendar_data_pack_importer.dart';
import '../domain/calendar/solar_term/month_branch_resolver.dart';
import '../domain/calendar/store/calendar_data_store.dart';
import '../domain/calendar/store/stored_solar_term_provider.dart';
import '../services/calendar/casting_calendar_service.dart';
import 'app_shell.dart';

/// 卦眼 2.0 应用根组件。
///
/// 只负责 MaterialApp 组装与全局主题，不持有导航状态。
class GuayanApp extends StatefulWidget {
  const GuayanApp({super.key});

  @override
  State<GuayanApp> createState() => _GuayanAppState();
}

class _GuayanAppState extends State<GuayanApp> {
  late final Future<CastingCalendarService> _calendarService =
      _loadCalendarService();

  Future<CastingCalendarService> _loadCalendarService() async {
    final store = InMemoryCalendarDataStore();
    final importer = CalendarDataPackImporter(store);
    for (final year in [2025, 2026, 2027, 2028]) {
      await importer.importPack(
        await rootBundle.loadString('assets/calendar/$year.calendar.json'),
      );
    }
    final provider = await StoredSolarTermProvider.load(store);
    return CastingCalendarService(
      CalendarEngine(monthBranchResolver: MonthBranchResolver(provider)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(AppInfo.seedColor)),
        scaffoldBackgroundColor: const Color(0xFFFAF7F2),
      ),
      home: FutureBuilder<CastingCalendarService>(
        future: _calendarService,
        builder: (context, snapshot) {
          return AppShell(calendarService: snapshot.data);
        },
      ),
    );
  }
}
