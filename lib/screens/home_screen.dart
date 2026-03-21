import 'package:flutter/material.dart';
import 'package:zerotierapi/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/services/device_repository.dart';
import 'package:zerotierapi/services/storage_service.dart';
import 'package:zerotierapi/services/widget_sync_service.dart';
import 'package:zerotierapi/widgets/device_card.dart';
import 'package:zerotierapi/widgets/refresh_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Device>>? _devicesFuture;
  final WidgetSyncService _widgetSyncService = WidgetSyncService();
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
      }).catchError((_) {
        if (!mounted) return;
        setState(() => _isRefreshing = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        // 在 AppBar 的 actions 中添加
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/stats'),
            tooltip: l10n.stats,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/config'),
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Navigator.pushNamed(context, '/admin'),
            tooltip: l10n.advancedAdmin,
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
            return Center(child: Text(l10n.configNeeded));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.loadFailed(snapshot.error.toString())),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadDevices,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }
          
          final devices = snapshot.data ?? [];
          if (devices.isEmpty) {
            return Center(child: Text(l10n.notFoundDevices));
          }
          
          // 按最后在线时间排序
          devices.sort((a, b) => 
            (b.lastOnline ?? 0).compareTo(a.lastOnline ?? 0));
          
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return DeviceCard(
                device: device,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/device',
                    arguments: device,
                  ).then((value) {
                    if (value == true && mounted) {
                      _loadDevices();
                    }
                  });
                },
              );
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