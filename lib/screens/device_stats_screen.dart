import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/services/device_repository.dart';
import 'package:provider/provider.dart';
import 'package:zerotierapi/services/storage_service.dart';

class DeviceStatsScreen extends StatefulWidget {
  const DeviceStatsScreen({super.key});

  @override
  State<DeviceStatsScreen> createState() => _DeviceStatsScreenState();
}

class _DeviceStatsScreenState extends State<DeviceStatsScreen> {
  List<Device> _devices = [];
  bool _isLoading = true;
  String _timeRange = '24小时'; // 默认时间范围
  final List<String> _timeRanges = ['24小时', '7天', '30天'];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final deviceRepo = Provider.of<DeviceRepository>(context, listen: false);
      final storage = Provider.of<StorageService>(context, listen: false);
      final devices = await deviceRepo.getDevices(
        storage.networkId!,
        storage.apiToken!,
      );

      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载设备数据失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备统计'),
        actions: [
          DropdownButton<String>(
            value: _timeRange,
            dropdownColor: Theme.of(context).cardColor,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            underline: Container(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _timeRange = newValue;
                });
              }
            },
            items: _timeRanges.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDevices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOnlineStatusChart(),
                  const SizedBox(height: 24),
                  _buildLastOnlineChart(),
                  const SizedBox(height: 24),
                  _buildDeviceVersionChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildOnlineStatusChart() {
    final onlineCount = _devices.where((d) => d.online).length;
    final offlineCount = _devices.length - onlineCount;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '设备在线状态',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: onlineCount.toDouble(),
                      title: '在线 ($onlineCount)',
                      color: Colors.green,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: offlineCount.toDouble(),
                      title: '离线 ($offlineCount)',
                      color: Colors.orange,
                      radius: 80,
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastOnlineChart() {
    // 根据最后在线时间分组设备
    final now = DateTime.now().millisecondsSinceEpoch;
    final hour = 60 * 60 * 1000;
    final day = 24 * hour;

    final lastHour = _devices.where((d) => d.lastOnline != null && now - d.lastOnline! < hour).length;
    final lastDay = _devices.where((d) => d.lastOnline != null && now - d.lastOnline! >= hour && now - d.lastOnline! < day).length;
    final lastWeek = _devices.where((d) => d.lastOnline != null && now - d.lastOnline! >= day && now - d.lastOnline! < 7 * day).length;
    final older = _devices.where((d) => d.lastOnline != null && now - d.lastOnline! >= 7 * day).length;
    final never = _devices.where((d) => d.lastOnline == null || d.lastOnline == 0).length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最后在线时间分布',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _devices.length.toDouble(),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: lastHour.toDouble(),
                          color: Colors.green,
                          width: 30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: lastDay.toDouble(),
                          color: Colors.blue,
                          width: 30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: lastWeek.toDouble(),
                          color: Colors.orange,
                          width: 30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: older.toDouble(),
                          color: Colors.red,
                          width: 30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: never.toDouble(),
                          color: Colors.grey,
                          width: 30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          String text = '';
                          switch (value.toInt()) {
                            case 0:
                              text = '1小时内';
                              break;
                            case 1:
                              text = '24小时内';
                              break;
                            case 2:
                              text = '7天内';
                              break;
                            case 3:
                              text = '更早';
                              break;
                            case 4:
                              text = '从未在线';
                              break;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(text, style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceVersionChart() {
    // 按客户端版本分组
    final Map<String, int> versionCounts = {};
    for (var device in _devices) {
      final version = device.clientVersion ?? '未知';
      versionCounts[version] = (versionCounts[version] ?? 0) + 1;
    }

    // 转换为图表数据
    final List<PieChartSectionData> sections = [];
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal];
    int colorIndex = 0;

    versionCounts.forEach((version, count) {
      sections.add(
        PieChartSectionData(
          value: count.toDouble(),
          title: '$version\n($count)',
          color: colors[colorIndex % colors.length],
          radius: 80,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );
      colorIndex++;
    });

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '客户端版本分布',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}