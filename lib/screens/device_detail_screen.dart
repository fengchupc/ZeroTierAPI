import 'package:flutter/material.dart';
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/utils/time_utils.dart';
import 'package:zerotierapi/utils/constants.dart';

class DeviceDetailScreen extends StatelessWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name ?? '设备详情'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('基本信息', [
              _buildInfoRow('设备ID', device.id),
              if (device.name != null) _buildInfoRow('设备名称', device.name!),
              _buildInfoRow('状态', device.online ? '在线' : '离线'),
              _buildInfoRow('最后在线时间', formatLastOnline(device.lastOnline)),
              _buildInfoRow('最后在线', timeAgo(device.lastOnline)),
            ]),
            
            if (device.ipAddress != null)
              _buildInfoCard('网络信息', [
                _buildInfoRow('IP地址', device.ipAddress!),
                _buildInfoRow('网络ID', device.networkId ?? Constants.defaultNetworkId),
              ]),
            
            _buildInfoCard('技术信息', [
              _buildInfoRow('节点ID', device.nodeId ?? '未知'),
              _buildInfoRow('设备ID', device.deviceId ?? '未知'),
              _buildInfoRow('客户端版本', device.clientVersion ?? '未知'),
            ]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 实现设备管理功能
        },
        child: const Icon(Icons.settings),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}