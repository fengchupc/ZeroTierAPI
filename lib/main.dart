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
import 'package:zerotierapi/services/storage_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化存储服务
  final StorageInterface storage = kIsWeb 
      ? WebStorageService() as StorageInterface
      : DatabaseHelper.instance as StorageInterface;
  await storage.initialize();

  // 初始化存储服务
  final storageService = StorageService();
  await storageService.initialize();
  
  // 初始化API服务
  final apiService = ZeroTierService(storageService);
  
  // 初始化设备仓库
  final deviceRepository = DeviceRepository(
    apiService: apiService,
    storage: storage,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: storageService),
        Provider.value(value: storage),
        Provider.value(value: apiService),
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
        '/': (context) {
          final storageService = context.read<StorageService>();
          if (!storageService.isConfigured) {
            return const ConfigScreen();
          }
          return const HomeScreen();
        },
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

