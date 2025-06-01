import 'package:flutter/material.dart';
import 'package:zerotierapi/models/device_model.dart';

class DeviceListItem extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;

  const DeviceListItem({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.circle,
        color: device.online ? Colors.green : Colors.grey,
      ),
      title: Text(device.name ?? 'Unknown Device'),
      subtitle: Text(device.ipAddress ?? 'No IP'),
      trailing: Text(
        device.lastOnline != null
            ? DateTime.fromMillisecondsSinceEpoch(device.lastOnline!)
                .toLocal()
                .toString()
                .split('.')[0]
            : 'Never',
      ),
      onTap: onTap,
    );
  }
} 