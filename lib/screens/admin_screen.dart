import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zerotierapi/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    if (apiToken == null || apiToken.isEmpty) {
      throw Exception(l10n.configNeeded);
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadData,
            tooltip: l10n.refresh,
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
                    Text(l10n.adminLoadFailed(snapshot.error.toString())),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reloadData,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(child: Text(l10n.noAdminData));
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
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionCard(
      l10n.centralStatus,
      [
        _buildInfoRow(l10n.centralVersion, data.status.version ?? l10n.unknown),
        _buildInfoRow(l10n.apiVersion, data.status.apiVersion ?? l10n.unknown),
        _buildInfoRow(l10n.readOnlyMode, data.status.readOnlyMode ? l10n.yes : l10n.no),
      ],
    );
  }

  Widget _buildCurrentNetworkCard(_AdminData data) {
    final l10n = AppLocalizations.of(context)!;
    final network = data.currentNetwork;
    return _buildSectionCard(
      l10n.currentNetwork,
      [
        if (network == null)
          Text(l10n.networkNotConfigured)
        else ...[
          _buildInfoRow(l10n.networkId, network.id),
          _buildInfoRow(l10n.networkName, network.name ?? l10n.unnamedDevice),
          _buildInfoRow(l10n.description, network.description ?? l10n.unset),
          _buildInfoRow(l10n.privateNetwork, network.isPrivate == true ? l10n.yes : l10n.no),
          _buildInfoRow('MTU', network.mtu?.toString() ?? l10n.defaultValue),
          _buildInfoRow(
            l10n.broadcast,
            network.enableBroadcast == true ? l10n.enabled : l10n.disabled,
          ),
          _buildInfoRow(
            'Multicast Limit',
            network.multicastLimit?.toString() ?? l10n.defaultValue,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showNetworkEditDialog(network),
                icon: const Icon(Icons.edit),
                label: Text(l10n.editNetwork),
              ),
              OutlinedButton.icon(
                onPressed: _showCreateNetworkDialog,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(l10n.createNetwork),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNetworkListCard(_AdminData data) {
    final l10n = AppLocalizations.of(context)!;
    final storage = context.watch<StorageService>();
    final currentNetworkId = storage.networkId;

    return _buildSectionCard(
      l10n.accessibleNetworks,
      [
        if (data.networks.isEmpty)
          Text(l10n.noAccessibleNetworks)
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
                subtitle: Text(network.description ?? l10n.noDescription),
                trailing: isCurrent
                    ? Chip(label: Text(l10n.current))
                    : TextButton(
                        onPressed: () {
                          storage.networkId = network.id;
                          _reloadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.switchedCurrentNetwork(network.id))),
                          );
                        },
                        child: Text(l10n.setCurrent),
                      ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildUserCard(_AdminData data) {
    final l10n = AppLocalizations.of(context)!;
    final user = data.user;
    return _buildSectionCard(
      l10n.currentUser,
      [
        if (user == null)
          Text(l10n.cannotFetchCurrentUser)
        else ...[
          _buildInfoRow(l10n.userId, user.id),
          _buildInfoRow(l10n.displayName, user.displayName ?? l10n.unset),
          _buildInfoRow(l10n.email, user.email ?? l10n.unknown),
          _buildInfoRow(l10n.orgId, user.orgId ?? l10n.none),
          _buildInfoRow(l10n.smsNumber, user.smsNumber ?? l10n.unset),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showUserEditDialog(user),
                icon: const Icon(Icons.edit),
                label: Text(l10n.editUser),
              ),
              OutlinedButton.icon(
                onPressed: () => _showDeleteUserDialog(user),
                icon: const Icon(Icons.delete_forever),
                label: Text(l10n.deleteUser),
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
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionCard(
      l10n.apiTokenManagement,
      [
        if (user.tokens.isEmpty)
          Text(l10n.noVisibleApiToken)
        else
          ...user.tokens.map((tokenName) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(tokenName),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.deleteToken,
                  onPressed: () => _deleteToken(user, tokenName),
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showAddTokenDialog(user),
          icon: const Icon(Icons.key_outlined),
          label: Text(l10n.addApiToken),
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
    final l10n = AppLocalizations.of(context)!;
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
              title: Text(l10n.editNetwork),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: l10n.networkNameLabel),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: l10n.description),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: rulesController,
                      decoration: InputDecoration(labelText: l10n.rulesSource),
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
                      title: Text(l10n.privateNetwork),
                      onChanged: (value) {
                        setState(() {
                          privateNetwork = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: enableBroadcast,
                      title: Text(l10n.allowBroadcast),
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
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(l10n.save),
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
      SnackBar(content: Text(l10n.updateSuccess)),
    );
    _reloadData();
  }

  Future<void> _showCreateNetworkDialog() async {
    final l10n = AppLocalizations.of(context)!;
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
              title: Text(l10n.createNetwork),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: l10n.networkNameLabel),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: l10n.description),
                      maxLines: 2,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: privateNetwork,
                      title: Text(l10n.privateNetwork),
                      onChanged: (value) {
                        setState(() {
                          privateNetwork = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: useAsCurrent,
                      title: Text(l10n.setCurrentAfterCreate),
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
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(l10n.create),
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
      SnackBar(content: Text(l10n.networkCreated(network.id))),
    );
    _reloadData();
  }

  Future<void> _showUserEditDialog(ZeroTierUser user) async {
    final l10n = AppLocalizations.of(context)!;
    final displayNameController = TextEditingController(
      text: user.displayName ?? '',
    );
    final smsController = TextEditingController(text: user.smsNumber ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.editUser),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: displayNameController,
                decoration: InputDecoration(labelText: l10n.displayName),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: smsController,
                decoration: InputDecoration(labelText: l10n.smsNumber),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.save),
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
      SnackBar(content: Text(l10n.userUpdated)),
    );
    _reloadData();
  }

  Future<void> _showDeleteUserDialog(ZeroTierUser user) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteUserTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.deleteUserWarning),
              const SizedBox(height: 12),
              Text(l10n.confirmDeleteUser(user.id)),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(labelText: l10n.confirmUserId),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                confirmController.text.trim() == user.id,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.deleteUserButton),
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
      SnackBar(content: Text(l10n.userDeleted)),
    );
    Navigator.pop(context, true);
  }

  Future<void> _showAddTokenDialog(ZeroTierUser user) async {
    final l10n = AppLocalizations.of(context)!;
    final tokenNameController = TextEditingController();
    final tokenController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.addApiToken),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tokenNameController,
                      decoration: InputDecoration(labelText: l10n.tokenName),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: tokenController,
                      decoration: InputDecoration(labelText: l10n.tokenValue),
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
                        label: Text(l10n.generateRandomToken),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(l10n.add),
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
        SnackBar(content: Text(l10n.tokenNameValueRequired)),
      );
      return;
    }

    await service.addApiToken(user.id, apiToken, tokenName, token);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.apiTokenAdded)),
    );
    _reloadData();
  }

  Future<void> _deleteToken(ZeroTierUser user, String tokenName) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(l10n.deleteApiTokenTitle),
              content: Text(l10n.confirmDeleteToken(tokenName)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(l10n.delete),
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
      SnackBar(content: Text(l10n.tokenDeleted(tokenName))),
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