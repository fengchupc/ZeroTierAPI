import 'package:flutter/material.dart';
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/utils/time_utils.dart';
import 'package:zerotierapi/widgets/status_indicator.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  
  const DeviceCard({super.key, required this.device});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: StatusIndicator(isOnline: device.online),
        title: Text(
          device.name ?? '未命名设备',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (device.ipAddress != null)
              Text(
                'IP: ${device.ipAddress}',
                style: const TextStyle(fontSize: 12),
              ),
            Text(
              device.online ? '在线' : '离线',
              style: TextStyle(
                color: device.online ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatLastOnline(device.lastOnline),
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              timeAgo(device.lastOnline),
              style: TextStyle(
                fontSize: 11,
                color: device.online ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        // 在设备卡片的 onTap 中添加导航
        onTap: () {
          Navigator.pushNamed(
            context,
            '/device',
            arguments: device,
          );
        },
      ),
    );
  }
}