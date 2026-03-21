import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:zerotierapi/services/storage_service.dart';
import 'package:zerotierapi/screens/home_screen.dart';
import 'package:zerotierapi/screens/config_screen.dart';
import 'package:zerotierapi/services/database_helper.dart';
import 'package:zerotierapi/services/zerotier_service.dart';
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/screens/device_detail_screen.dart';
import 'package:flutter/foundation.dart'
  show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:zerotierapi/services/web_storage_service.dart';
import 'package:zerotierapi/services/device_repository.dart';
import 'package:zerotierapi/screens/device_stats_screen.dart'; // 添加这一行导入语句
import 'package:zerotierapi/screens/admin_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zerotierapi/utils/notifications.dart';
import 'package:zerotierapi/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  if (!kIsWeb) {
    await ensureNotificationsInitialized();
  }

  // 初始化服务
  final storageService = StorageService();
  await storageService.initialize();
  
  final zerotierService = ZeroTierService();
  
  // 根据平台选择存储实现
  final storage = kIsWeb 
      ? await (() async {
          final webStorage = WebStorageService();
          await webStorage.initialize();
          return webStorage;
        })()
      : await (() async {
          final dbHelper = DatabaseHelper.instance;
          await dbHelper.initialize();
          return dbHelper;
        })();
  
  final deviceRepository = DeviceRepository(
    apiService: zerotierService,
    storage: storage,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: storageService),
        Provider.value(value: storage),
        Provider.value(value: zerotierService),
        Provider.value(value: deviceRepository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Locale? _resolveLocale(String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) {
      return null;
    }
    return Locale(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'NotoSans',
        fontFamilyFallback: const ['DroidSansFallback'],
      ),
      locale: _resolveLocale(storage.languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: '/',
      // 在 routes 中添加
      routes: {
        '/': (context) => const HomeScreen(),
        '/config': (context) => const ConfigScreen(),
        '/device': (context) {
          final device = ModalRoute.of(context)!.settings.arguments as Device;
          return DeviceDetailScreen(device: device);
        },
        '/stats': (context) => const DeviceStatsScreen(), // 新增
        '/admin': (context) => const AdminScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

