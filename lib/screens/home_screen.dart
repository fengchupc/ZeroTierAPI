import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/services/device_repository.dart';
import 'package:zerotierapi/services/storage_service.dart';
import 'package:zerotierapi/services/macos_widget_sync_service.dart';
import 'package:zerotierapi/widgets/device_card.dart';
import 'package:zerotierapi/widgets/refresh_button.dart';
import 'package:zerotierapi/utils/notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Device>>? _devicesFuture;
  final MacOSWidgetSyncService _widgetSyncService = MacOSWidgetSyncService();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _schedulePeriodicRefresh();
  }

  void _schedulePeriodicRefresh() {
    Future.delayed(const Duration(minutes: 5), () {
      if (mounted) {
        _loadDevices();
        _schedulePeriodicRefresh();
      }
    });
  }

  void _loadDevices() {
    setState(() {
      _isRefreshing = true;
    });

    final storage = context.read<StorageService>();
    final deviceRepo = context.read<DeviceRepository>();
    final apiToken = storage.apiToken;
    final networkId = storage.networkId;

    if (apiToken == null || networkId == null) {
      setState(() {
        _isRefreshing = false;
        _devicesFuture = Future.value([]);
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushNamed(context, '/config');
      });
      return;
    }

    setState(() {
      _devicesFuture = deviceRepo.getDevices(networkId, apiToken);
      _devicesFuture?.then((devices) {
        _widgetSyncService.syncDevices(devices);
        if (!mounted) return;
        setState(() => _isRefreshing = false);
        showUpdateNotification(context, '设备列表已更新');
      }).catchError((_) {
        if (!mounted) return;
        setState(() => _isRefreshing = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZeroTier 设备状态'),
        // 在 AppBar 的 actions 中添加
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/stats'),
            tooltip: '设备统计',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/config'),
          ),
          RefreshButton(
            onRefresh: _loadDevices,
            isRefreshing: _isRefreshing,
          ),
        ],
      ),
      body: FutureBuilder<List<Device>>(
        future: _devicesFuture,
        builder: (context, snapshot) {
          if (_devicesFuture == null) {
            return const Center(child: Text('请先配置 API Token 和 Network ID'));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败: ${snapshot.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadDevices,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }
          
          final devices = snapshot.data ?? [];
          if (devices.isEmpty) {
            return const Center(child: Text('未找到设备'));
          }
          
          // 按最后在线时间排序
          devices.sort((a, b) => 
            (b.lastOnline ?? 0).compareTo(a.lastOnline ?? 0));
          
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return DeviceCard(device: devices[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDevices,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}