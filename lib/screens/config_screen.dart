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
  late TextEditingController _apiTokenController;
  late TextEditingController _networkIdController;
  late TextEditingController _timeZoneController;

  @override
  void initState() {
    super.initState();
    final storage = context.read<StorageService>();
    _apiTokenController = TextEditingController(text: storage.apiToken);
    _networkIdController = TextEditingController(text: storage.networkId);
    _timeZoneController = TextEditingController(
        text: storage.timeZone ?? 'Asia/Shanghai');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('配置')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _apiTokenController,
                decoration: const InputDecoration(
                  labelText: 'API Token',
                  border: OutlineInputBorder(),
                  hintText: '从 ZeroTier 控制台获取',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入API Token';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _networkIdController,
                decoration: const InputDecoration(
                  labelText: '网络ID',
                  border: OutlineInputBorder(),
                  hintText: '例如: 0000000000000000',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入网络ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeZoneController,
                decoration: const InputDecoration(
                  labelText: '时区',
                  border: OutlineInputBorder(),
                  hintText: '例如: Asia/Shanghai, America/New_York',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveConfig,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('保存配置'),
              ),
              const SizedBox(height: 16),
              const Text(
                '配置说明:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('1. 登录 ZeroTier Central (https://my.zerotier.com)'),
              const Text('2. 在 "Networks" 页面找到您的网络ID'),
              const Text('3. 在 "Settings" > "API" 生成 API Token'),
            ],
          ),
        ),
      ),
    );
  }

  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      final storage = context.read<StorageService>();
      storage.apiToken = _apiTokenController.text;
      storage.networkId = _networkIdController.text;
      storage.timeZone = _timeZoneController.text;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('配置已保存')),
      );
      
      Navigator.pop(context);
    }
  }
}