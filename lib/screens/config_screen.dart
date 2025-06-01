import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zerotierapi/services/storage_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiTokenController = TextEditingController();
  final _networkIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final storage = context.read<StorageService>();
    _apiTokenController.text = storage.apiToken ?? '';
    _networkIdController.text = storage.networkId ?? '';
  }

  @override
  void dispose() {
    _apiTokenController.dispose();
    _networkIdController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      final storage = context.read<StorageService>();
      storage.apiToken = _apiTokenController.text;
      storage.networkId = _networkIdController.text;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZeroTier 配置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _apiTokenController,
                decoration: const InputDecoration(
                  labelText: 'API Token',
                  hintText: '请输入 ZeroTier API Token',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入 API Token';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _networkIdController,
                decoration: const InputDecoration(
                  labelText: 'Network ID',
                  hintText: '请输入 ZeroTier Network ID',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入 Network ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveConfig,
                child: const Text('保存配置'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}