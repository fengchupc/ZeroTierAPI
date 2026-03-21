import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zerotierapi/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:zerotierapi/services/storage_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apiTokenController;
  late TextEditingController _networkIdController;
  late TextEditingController _timeZoneController;
  bool _obscureToken = true;
  String _selectedLanguageCode = 'zh';
  String? _versionText;

  @override
  void initState() {
    super.initState();
    final storage = context.read<StorageService>();
    _apiTokenController = TextEditingController(text: storage.apiToken);
    _networkIdController = TextEditingController(text: storage.networkId);
    _timeZoneController = TextEditingController(
        text: storage.timeZone ?? 'Asia/Shanghai');
    _selectedLanguageCode = storage.languageCode ?? 'zh';
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _versionText = '${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.configTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _apiTokenController,
                decoration: InputDecoration(
                  labelText: l10n.apiToken,
                  border: const OutlineInputBorder(),
                  hintText: l10n.apiTokenHint,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureToken
                        ? Icons.visibility_off
                        : Icons.visibility),
                    tooltip: _obscureToken ? l10n.showToken : l10n.hideToken,
                    onPressed: () =>
                        setState(() => _obscureToken = !_obscureToken),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '${l10n.retry} ${l10n.apiToken}';
                  }
                  return null;
                },
                obscureText: _obscureToken,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: Text(l10n.copyToken),
                onPressed: () {
                  final token = _apiTokenController.text;
                  if (token.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: token));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.tokenCopied)),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _networkIdController,
                decoration: InputDecoration(
                  labelText: l10n.networkId,
                  border: OutlineInputBorder(),
                  hintText: l10n.networkIdHint,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '${l10n.retry} ${l10n.networkId}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeZoneController,
                decoration: InputDecoration(
                  labelText: l10n.timeZone,
                  border: OutlineInputBorder(),
                  hintText: l10n.timeZoneHint,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLanguageCode,
                decoration: InputDecoration(
                  labelText: l10n.language,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'zh',
                    child: Text(l10n.languageChinese),
                  ),
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(l10n.languageEnglish),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedLanguageCode = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveConfig,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(l10n.saveConfig),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.configHelp,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(l10n.configHelp1),
              Text(l10n.configHelp2),
              Text(l10n.configHelp3),
              if (_versionText != null) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.version(_versionText!),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      final storage = context.read<StorageService>();
      storage.apiToken = _apiTokenController.text.trim();
      storage.networkId = _networkIdController.text.trim();
      storage.timeZone = _timeZoneController.text.trim();
      storage.languageCode = _selectedLanguageCode;

      final l10n = AppLocalizations.of(context)!;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.configSaved)),
      );
      
      Navigator.pop(context);
    }
  }
}