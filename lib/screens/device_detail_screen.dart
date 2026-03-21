import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zerotierapi/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name ?? l10n.deviceDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMember,
            tooltip: l10n.refresh,
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
            return Center(
              child: Text(l10n.loadDeviceDetailFailed(snapshot.error.toString())),
            );
          }

          final device = snapshot.data ?? widget.device;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(l10n.basicInfo, [
                  _buildInfoRow(l10n.memberId, device.id),
                  if (device.name != null) _buildInfoRow(l10n.deviceName, device.name!),
                  if (device.description != null)
                    _buildInfoRow(l10n.description, device.description!),
                  _buildInfoRow(l10n.status, device.online ? l10n.online : l10n.offline),
                  _buildInfoRow(l10n.lastOnlineTime, formatLastOnline(device.lastOnline, l10n)),
                  _buildInfoRow(l10n.lastOnline, timeAgo(device.lastOnline, l10n)),
                ]),
                _buildInfoCard(l10n.networkInfo, [
                  _buildInfoRow(l10n.ipAddress, device.ipAddress ?? l10n.unassigned),
                  _buildInfoRow(
                    l10n.publicIp,
                    _extractPublicIp(device.physicalAddress) ?? l10n.unknown,
                  ),
                  _buildInfoRow(
                    l10n.ipAssignments,
                    device.ipAssignments.isEmpty
                        ? l10n.unassigned
                        : device.ipAssignments.join(', '),
                  ),
                  _buildInfoRow(
                    l10n.networkId,
                    device.networkId ?? Constants.defaultNetworkId,
                  ),
                  _buildInfoRow(l10n.authorized, device.authorized == true ? l10n.yes : l10n.no),
                ]),
                _buildInfoCard(l10n.managementSwitches, [
                  _buildInfoRow(l10n.hiddenMember, device.hidden ? l10n.yes : l10n.no),
                  _buildInfoRow(
                    l10n.disableAutoAssignIp,
                    device.noAutoAssignIps ? l10n.yes : l10n.no,
                  ),
                  _buildInfoRow(l10n.activeBridge, device.activeBridge ? l10n.yes : l10n.no),
                  _buildInfoRow(l10n.ssoExempt, device.ssoExempt ? l10n.yes : l10n.no),
                ]),
                _buildInfoCard(l10n.technicalInfo, [
                  _buildInfoRow(l10n.nodeId, device.nodeId ?? l10n.unknown),
                  _buildInfoRow(l10n.deviceId, device.deviceId ?? l10n.unknown),
                  _buildInfoRow(l10n.clientVersion, device.clientVersion ?? l10n.unknown),
                ]),
                _buildInfoCard(l10n.memberActions, [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showEditDialog(device),
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.editMember),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showDeleteDialog(device),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l10n.deleteMember),
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
    final l10n = AppLocalizations.of(context)!;
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
              title: Text(l10n.memberEditTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: l10n.name),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: l10n.description),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ipAssignmentsController,
                      decoration: InputDecoration(
                        labelText: l10n.ipAssignments,
                        hintText: l10n.ipAssignmentsHint,
                      ),
                      maxLines: 2,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: authorized,
                      title: Text(l10n.authorized),
                      onChanged: (value) {
                        setState(() {
                          authorized = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: hidden,
                      title: Text(l10n.hiddenMember),
                      onChanged: (value) {
                        setState(() {
                          hidden = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: noAutoAssignIps,
                      title: Text(l10n.disableAutoAssignIp),
                      onChanged: (value) {
                        setState(() {
                          noAutoAssignIps = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: activeBridge,
                      title: Text(l10n.activeBridge),
                      onChanged: (value) {
                        setState(() {
                          activeBridge = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: ssoExempt,
                      title: Text(l10n.ssoExempt),
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
    final networkId = storage.networkId ?? device.networkId;

    if (apiToken == null || apiToken.isEmpty || networkId == null || networkId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.missingTokenOrNetwork)),
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
        SnackBar(content: Text(l10n.updateSuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      await _showCopyableErrorDialog(l10n.updateFailed, '$e');
    }
  }

  Future<void> _showDeleteDialog(Device device) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmController = TextEditingController();
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(l10n.deleteMemberTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.deleteMemberWarning),
                  const SizedBox(height: 12),
                  Text(l10n.confirmDeleteMember(device.id)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    decoration: InputDecoration(labelText: l10n.confirmMemberId),
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
                    confirmController.text.trim() == device.id,
                  ),
                  child: Text(l10n.deleteMember),
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
        SnackBar(content: Text(l10n.missingTokenOrNetwork)),
      );
      return;
    }

    try {
      await service.deleteDevice(networkId, device.id, apiToken);
    } catch (e) {
      if (!mounted) return;
      await _showCopyableErrorDialog(l10n.deleteFailed, '$e');
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.deleteSuccess)),
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
                final l10n = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.errorCopied)),
                );
              },
              icon: const Icon(Icons.copy),
              label: Text(AppLocalizations.of(context)!.copyError),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.close),
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