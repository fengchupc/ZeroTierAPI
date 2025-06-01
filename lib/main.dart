import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zerotierapi/services/storage_service.dart';
import 'package:zerotierapi/screens/home_screen.dart';
import 'package:zerotierapi/screens/config_screen.dart';
import 'package:zerotierapi/services/database_helper.dart';
import 'package:zerotierapi/services/zerotier_service.dart';
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/screens/device_detail_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:zerotierapi/services/web_storage_service.dart';
import 'package:zerotierapi/services/device_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZeroTier Status',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/config': (context) => const ConfigScreen(),
        '/device': (context) {
          final device = ModalRoute.of(context)!.settings.arguments as Device;
          return DeviceDetailScreen(device: device);
        },
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

