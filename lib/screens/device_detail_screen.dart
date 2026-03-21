import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/services/storage_service.dart';
import 'package:zerotierapi/services/zerotier_service.dart';
import 'package:zerotierapi/utils/time_utils.dart';
import 'package:zerotierapi/utils/constants.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  Future<Device>? _memberFuture;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  void _loadMember() {
    final storage = context.read<StorageService>();
    final service = context.read<ZeroTierService>();
    final apiToken = storage.apiToken;
    final networkId = storage.networkId ?? widget.device.networkId;

    if (apiToken == null || apiToken.isEmpty || networkId == null || networkId.isEmpty) {
      setState(() {
        _memberFuture = Future<Device>.value(widget.device);
      });
      return;
    }

    setState(() {
      _memberFuture = service
          .getDevice(networkId, widget.device.id, apiToken)
          .catchError((_) => widget.device);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name ?? '设备详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMember,
            tooltip: '刷新',
          ),
        ],
      ),
      body: FutureBuilder<Device>(
        future: _memberFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('加载设备详情失败: ${snapshot.error}'));
          }

          final device = snapshot.data ?? widget.device;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard('基本信息', [
                  _buildInfoRow('成员ID', device.id),
                  if (device.name != null) _buildInfoRow('设备名称', device.name!),
                  if (device.description != null)
                    _buildInfoRow('描述', device.description!),
                  _buildInfoRow('状态', device.online ? '在线' : '离线'),
                  _buildInfoRow('最后在线时间', formatLastOnline(device.lastOnline)),
                  _buildInfoRow('最后在线', timeAgo(device.lastOnline)),
                ]),
                _buildInfoCard('网络信息', [
                  _buildInfoRow('IP地址', device.ipAddress ?? '未分配'),
                  _buildInfoRow(
                    '公网IP',
                    _extractPublicIp(device.physicalAddress) ?? '未知',
                  ),
                  _buildInfoRow(
                    'IP Assignments',
                    device.ipAssignments.isEmpty
                        ? '未分配'
                        : device.ipAssignments.join(', '),
                  ),
                  _buildInfoRow(
                    '网络ID',
                    device.networkId ?? Constants.defaultNetworkId,
                  ),
                  _buildInfoRow('已授权', device.authorized == true ? '是' : '否'),
                ]),
                _buildInfoCard('管理开关', [
                  _buildInfoRow('隐藏成员', device.hidden ? '是' : '否'),
                  _buildInfoRow(
                    '禁止自动分配 IP',
                    device.noAutoAssignIps ? '是' : '否',
                  ),
                  _buildInfoRow('活动桥接', device.activeBridge ? '是' : '否'),
                  _buildInfoRow('SSO 豁免', device.ssoExempt ? '是' : '否'),
                ]),
                _buildInfoCard('技术信息', [
                  _buildInfoRow('节点ID', device.nodeId ?? '未知'),
                  _buildInfoRow('设备ID', device.deviceId ?? '未知'),
                  _buildInfoRow('客户端版本', device.clientVersion ?? '未知'),
                ]),
                _buildInfoCard('成员操作', [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showEditDialog(device),
                        icon: const Icon(Icons.edit),
                        label: const Text('编辑成员'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showDeleteDialog(device),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('删除成员'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEditDialog(Device device) async {
    final nameController = TextEditingController(text: device.name ?? '');
    final descriptionController = TextEditingController(
      text: device.description ?? '',
    );
    final ipAssignmentsController = TextEditingController(
      text: device.ipAssignments.join(', '),
    );
    var hidden = device.hidden;
    var authorized = device.authorized ?? false;
    var noAutoAssignIps = device.noAutoAssignIps;
    var activeBridge = device.activeBridge;
    var ssoExempt = device.ssoExempt;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('编辑成员'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '名称'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: '描述'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ipAssignmentsController,
                      decoration: const InputDecoration(
                        labelText: 'IP Assignments',
                        hintText: '多个 IP 用逗号分隔',
                      ),
                      maxLines: 2,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: authorized,
                      title: const Text('已授权'),
                      onChanged: (value) {
                        setState(() {
                          authorized = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: hidden,
                      title: const Text('隐藏成员'),
                      onChanged: (value) {
                        setState(() {
                          hidden = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: noAutoAssignIps,
                      title: const Text('禁止自动分配 IP'),
                      onChanged: (value) {
                        setState(() {
                          noAutoAssignIps = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: activeBridge,
                      title: const Text('活动桥接'),
                      onChanged: (value) {
                        setState(() {
                          activeBridge = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: ssoExempt,
                      title: const Text('SSO 豁免'),
                      onChanged: (value) {
                        setState(() {
                          ssoExempt = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true || !mounted) {
      return;
    }

    final storage = context.read<StorageService>();
    final service = context.read<ZeroTierService>();
    final apiToken = storage.apiToken;
    final networkId = storage.networkId ?? device.networkId;

    if (apiToken == null || apiToken.isEmpty || networkId == null || networkId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('缺少 API Token 或 Network ID 配置')),
      );
      return;
    }

    final ipAssignments = ipAssignmentsController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final updatedDevice = device.copyWith(
      name: nameController.text.trim(),
      clearName: nameController.text.trim().isEmpty,
      description: descriptionController.text.trim(),
      clearDescription: descriptionController.text.trim().isEmpty,
      hidden: hidden,
      authorized: authorized,
      noAutoAssignIps: noAutoAssignIps,
      activeBridge: activeBridge,
      ssoExempt: ssoExempt,
      ipAssignments: ipAssignments,
      ipAddress: ipAssignments.isEmpty ? null : ipAssignments.first,
    );

    try {
      final savedDevice = await service.updateDevice(
        networkId,
        device.id,
        apiToken,
        updatedDevice,
      );

      if (!mounted) return;

      setState(() {
        _memberFuture = Future<Device>.value(savedDevice);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('成员信息已更新')),
      );
    } catch (e) {
      if (!mounted) return;
      await _showCopyableErrorDialog('更新失败', '$e');
    }
  }

  Future<void> _showDeleteDialog(Device device) async {
    final confirmController = TextEditingController();
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('删除成员'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('该成员会从当前网络中删除。'),
                  const SizedBox(height: 12),
                  Text('请输入成员 ID 以确认: ${device.id}'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    decoration: const InputDecoration(labelText: '确认成员 ID'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(
                    dialogContext,
                    confirmController.text.trim() == device.id,
                  ),
                  child: const Text('删除成员'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !mounted) {
      return;
    }

    final storage = context.read<StorageService>();
    final service = context.read<ZeroTierService>();
    final apiToken = storage.apiToken;
    final networkId = storage.networkId ?? device.networkId;

    if (apiToken == null || apiToken.isEmpty || networkId == null || networkId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('缺少 API Token 或 Network ID 配置')),
      );
      return;
    }

    try {
      await service.deleteDevice(networkId, device.id, apiToken);
    } catch (e) {
      if (!mounted) return;
      await _showCopyableErrorDialog('删除失败', '$e');
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('成员已删除')),
    );
    Navigator.pop(context, true);
  }

  Future<void> _showCopyableErrorDialog(String title, String details) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              child: SelectableText(details),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: details));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('错误信息已复制')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('复制错误'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  String? _extractPublicIp(String? physicalAddress) {
    if (physicalAddress == null || physicalAddress.trim().isEmpty) {
      return null;
    }

    final value = physicalAddress.trim();
    final slashIndex = value.indexOf('/');
    final colonIndex = value.lastIndexOf(':');

    if (slashIndex > 0) {
      return value.substring(0, slashIndex);
    }

    if (colonIndex > 0) {
      return value.substring(0, colonIndex);
    }

    return value;
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