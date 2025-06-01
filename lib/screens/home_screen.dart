import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/services/device_repository.dart';
import 'package:zerotierapi/widgets/device_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Device>> _devicesFuture;
  late final DeviceRepository _repository;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _repository = context.read<DeviceRepository>();
    _loadDevices();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadDevices() {
    setState(() {
      _devicesFuture = _repository.getDevices();
    });
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadDevices(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZeroTier Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/config'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDevices,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDevices();
        },
        child: FutureBuilder<List<Device>>(
          future: _devicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final devices = snapshot.data ?? [];
            if (devices.isEmpty) {
              return const Center(
                child: Text('No devices found'),
              );
            }

            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return DeviceListItem(
                  device: device,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/device',
                      arguments: device,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}