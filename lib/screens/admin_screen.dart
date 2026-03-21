import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zerotierapi/models/network_model.dart';
import 'package:zerotierapi/models/user_model.dart';
import 'package:zerotierapi/services/storage_service.dart';
import 'package:zerotierapi/services/zerotier_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Future<_AdminData>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  void _reloadData() {
    setState(() {
      _dataFuture = _loadAdminData();
    });
  }

  Future<_AdminData> _loadAdminData() async {
    final storage = context.read<StorageService>();
    final service = context.read<ZeroTierService>();
    final apiToken = storage.apiToken;

    if (apiToken == null || apiToken.isEmpty) {
      throw Exception('请先在设置中配置 API Token');
    }

    final status = await service.getStatus(apiToken);
    final networks = await service.getNetworks(apiToken);

    ZeroTierUser? user;
    if (status.user != null && status.user!.id.isNotEmpty) {
      user = await service.getUser(status.user!.id, apiToken);
    }

    ZeroTierNetwork? currentNetwork;
    final networkId = storage.networkId;
    if (networkId != null && networkId.isNotEmpty) {
      currentNetwork = await service.getNetwork(networkId, apiToken);
    }

    return _AdminData(
      status: status,
      user: user,
      currentNetwork: currentNetwork,
      networks: networks,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZeroTier 管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadData,
            tooltip: '刷新',
          ),
        ],
      ),
      body: FutureBuilder<_AdminData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载管理信息失败: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reloadData,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('没有可用的管理数据'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusCard(data),
              const SizedBox(height: 16),
              _buildCurrentNetworkCard(data),
              const SizedBox(height: 16),
              _buildNetworkListCard(data),
              const SizedBox(height: 16),
              _buildUserCard(data),
              if (data.user != null) ...[
                const SizedBox(height: 16),
                _buildTokenCard(data.user!),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(_AdminData data) {
    return _buildSectionCard(
      'Central 状态',
      [
        _buildInfoRow('Central 版本', data.status.version ?? '未知'),
        _buildInfoRow('API 版本', data.status.apiVersion ?? '未知'),
        _buildInfoRow('只读模式', data.status.readOnlyMode ? '是' : '否'),
      ],
    );
  }

  Widget _buildCurrentNetworkCard(_AdminData data) {
    final network = data.currentNetwork;
    return _buildSectionCard(
      '当前网络',
      [
        if (network == null)
          const Text('当前未配置 Network ID，或该网络无法访问。')
        else ...[
          _buildInfoRow('网络 ID', network.id),
          _buildInfoRow('名称', network.name ?? '未命名'),
          _buildInfoRow('描述', network.description ?? '未设置'),
          _buildInfoRow('私有网络', network.isPrivate == true ? '是' : '否'),
          _buildInfoRow('MTU', network.mtu?.toString() ?? '默认'),
          _buildInfoRow(
            '广播',
            network.enableBroadcast == true ? '已启用' : '未启用',
          ),
          _buildInfoRow(
            'Multicast Limit',
            network.multicastLimit?.toString() ?? '默认',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showNetworkEditDialog(network),
                icon: const Icon(Icons.edit),
                label: const Text('编辑网络'),
              ),
              OutlinedButton.icon(
                onPressed: _showCreateNetworkDialog,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('新建网络'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNetworkListCard(_AdminData data) {
    final storage = context.watch<StorageService>();
    final currentNetworkId = storage.networkId;

    return _buildSectionCard(
      '可访问网络',
      [
        if (data.networks.isEmpty)
          const Text('当前账号下没有可访问网络')
        else
          ...data.networks.map((network) {
            final isCurrent = network.id == currentNetworkId;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                title: Text(network.name ?? network.id),
                subtitle: Text(network.description ?? '无描述'),
                trailing: isCurrent
                    ? const Chip(label: Text('当前'))
                    : TextButton(
                        onPressed: () {
                          storage.networkId = network.id;
                          _reloadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('当前网络已切换为 ${network.id}')),
                          );
                        },
                        child: const Text('设为当前'),
                      ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildUserCard(_AdminData data) {
    final user = data.user;
    return _buildSectionCard(
      '当前用户',
      [
        if (user == null)
          const Text('无法获取当前用户信息')
        else ...[
          _buildInfoRow('用户 ID', user.id),
          _buildInfoRow('显示名称', user.displayName ?? '未设置'),
          _buildInfoRow('邮箱', user.email ?? '未知'),
          _buildInfoRow('组织 ID', user.orgId ?? '无'),
          _buildInfoRow('短信号码', user.smsNumber ?? '未设置'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showUserEditDialog(user),
                icon: const Icon(Icons.edit),
                label: const Text('编辑用户'),
              ),
              OutlinedButton.icon(
                onPressed: () => _showDeleteUserDialog(user),
                icon: const Icon(Icons.delete_forever),
                label: const Text('删除用户'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTokenCard(ZeroTierUser user) {
    return _buildSectionCard(
      'API Token 管理',
      [
        if (user.tokens.isEmpty)
          const Text('当前用户还没有可见的 API Token 记录')
        else
          ...user.tokens.map((tokenName) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(tokenName),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '删除 Token',
                  onPressed: () => _deleteToken(user, tokenName),
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showAddTokenDialog(user),
          icon: const Icon(Icons.key_outlined),
          label: const Text('添加 API Token'),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showNetworkEditDialog(ZeroTierNetwork network) async {
    final nameController = TextEditingController(text: network.name ?? '');
    final descriptionController = TextEditingController(
      text: network.description ?? '',
    );
    final rulesController = TextEditingController(
      text: network.rulesSource ?? '',
    );
    final mtuController = TextEditingController(
      text: network.mtu?.toString() ?? '',
    );
    final multicastController = TextEditingController(
      text: network.multicastLimit?.toString() ?? '',
    );
    var privateNetwork = network.isPrivate ?? true;
    var enableBroadcast = network.enableBroadcast ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('编辑网络'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '网络名称'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: '描述'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: rulesController,
                      decoration: const InputDecoration(labelText: 'Rules Source'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: mtuController,
                      decoration: const InputDecoration(labelText: 'MTU'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: multicastController,
                      decoration: const InputDecoration(
                        labelText: 'Multicast Limit',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: privateNetwork,
                      title: const Text('私有网络'),
                      onChanged: (value) {
                        setState(() {
                          privateNetwork = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: enableBroadcast,
                      title: const Text('允许广播'),
                      onChanged: (value) {
                        setState(() {
                          enableBroadcast = value;
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
    if (apiToken == null || apiToken.isEmpty) {
      return;
    }

    final updatedNetwork = network.copyWith(
      name: nameController.text.trim(),
      clearName: nameController.text.trim().isEmpty,
      description: descriptionController.text.trim(),
      clearDescription: descriptionController.text.trim().isEmpty,
      rulesSource: rulesController.text.trim(),
      clearRulesSource: rulesController.text.trim().isEmpty,
      isPrivate: privateNetwork,
      enableBroadcast: enableBroadcast,
      mtu: int.tryParse(mtuController.text.trim()),
      multicastLimit: int.tryParse(multicastController.text.trim()),
    );

    await service.updateNetwork(network.id, apiToken, updatedNetwork);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('网络配置已更新')),
    );
    _reloadData();
  }

  Future<void> _showCreateNetworkDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    var privateNetwork = true;
    var useAsCurrent = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('新建网络'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '网络名称'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: '描述'),
                      maxLines: 2,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: privateNetwork,
                      title: const Text('私有网络'),
                      onChanged: (value) {
                        setState(() {
                          privateNetwork = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: useAsCurrent,
                      title: const Text('创建后设为当前网络'),
                      onChanged: (value) {
                        setState(() {
                          useAsCurrent = value;
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
                  child: const Text('创建'),
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
    if (apiToken == null || apiToken.isEmpty) {
      return;
    }

    final network = await service.createNetwork(
      apiToken,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      isPrivate: privateNetwork,
    );

    if (useAsCurrent) {
      storage.networkId = network.id;
    }

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('网络已创建: ${network.id}')),
    );
    _reloadData();
  }

  Future<void> _showUserEditDialog(ZeroTierUser user) async {
    final displayNameController = TextEditingController(
      text: user.displayName ?? '',
    );
    final smsController = TextEditingController(text: user.smsNumber ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('编辑用户'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: displayNameController,
                decoration: const InputDecoration(labelText: '显示名称'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: smsController,
                decoration: const InputDecoration(labelText: '短信号码'),
              ),
            ],
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

    if (result != true || !mounted) {
      return;
    }

    final storage = context.read<StorageService>();
    final service = context.read<ZeroTierService>();
    final apiToken = storage.apiToken;
    if (apiToken == null || apiToken.isEmpty) {
      return;
    }

    await service.updateUser(
      user.id,
      apiToken,
      user.copyWith(
        displayName: displayNameController.text.trim(),
        clearDisplayName: displayNameController.text.trim().isEmpty,
        smsNumber: smsController.text.trim(),
        clearSmsNumber: smsController.text.trim().isEmpty,
      ),
    );

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('用户信息已更新')),
    );
    _reloadData();
  }

  Future<void> _showDeleteUserDialog(ZeroTierUser user) async {
    final confirmController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('删除用户'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('该操作会删除用户及其关联网络，无法撤销。'),
              const SizedBox(height: 12),
              Text('请输入用户 ID 以确认删除: ${user.id}'),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(labelText: '确认用户 ID'),
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
                confirmController.text.trim() == user.id,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('删除用户'),
            ),
          ],
        );
      },
    );

    if (result != true || !mounted) {
      return;
    }

    final storage = context.read<StorageService>();
    final service = context.read<ZeroTierService>();
    final apiToken = storage.apiToken;
    if (apiToken == null || apiToken.isEmpty) {
      return;
    }

    await service.deleteUser(user.id, apiToken);
    storage.apiToken = null;
    storage.networkId = null;
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('用户已删除')),
    );
    Navigator.pop(context, true);
  }

  Future<void> _showAddTokenDialog(ZeroTierUser user) async {
    final tokenNameController = TextEditingController();
    final tokenController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('添加 API Token'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tokenNameController,
                      decoration: const InputDecoration(labelText: 'Token 名称'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: tokenController,
                      decoration: const InputDecoration(labelText: 'Token 值'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () async {
                          final storage = context.read<StorageService>();
                          final service = context.read<ZeroTierService>();
                          final apiToken = storage.apiToken;
                          if (apiToken == null || apiToken.isEmpty) {
                            return;
                          }
                          final generated = await service.getRandomToken(apiToken);
                          setState(() {
                            tokenController.text = generated.token;
                          });
                        },
                        icon: const Icon(Icons.casino_outlined),
                        label: const Text('生成随机 Token'),
                      ),
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
                  child: const Text('添加'),
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
    if (apiToken == null || apiToken.isEmpty) {
      return;
    }

    final tokenName = tokenNameController.text.trim();
    final token = tokenController.text.trim();
    if (tokenName.isEmpty || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token 名称和 Token 值都不能为空')),
      );
      return;
    }

    await service.addApiToken(user.id, apiToken, tokenName, token);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API Token 已添加')),
    );
    _reloadData();
  }

  Future<void> _deleteToken(ZeroTierUser user, String tokenName) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('删除 API Token'),
              content: Text('确认删除 Token: $tokenName ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('删除'),
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
    if (apiToken == null || apiToken.isEmpty) {
      return;
    }

    await service.deleteApiToken(user.id, apiToken, tokenName);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token $tokenName 已删除')),
    );
    _reloadData();
  }
}

class _AdminData {
  final ZeroTierStatus status;
  final ZeroTierUser? user;
  final ZeroTierNetwork? currentNetwork;
  final List<ZeroTierNetwork> networks;

  const _AdminData({
    required this.status,
    required this.user,
    required this.currentNetwork,
    required this.networks,
  });
}