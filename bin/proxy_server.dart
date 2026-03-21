import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

void main() async {
  final host = Platform.environment['PROXY_HOST'] ?? '0.0.0.0';
  final port = int.tryParse(Platform.environment['PROXY_PORT'] ?? '') ?? 3000;

  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(_handleRequest);

  final server = await io.serve(handler, host, port);
  developer.log(
    '代理服务器运行在: ${server.address.host}:${server.port}',
    name: 'proxy_server',
  );
}

shelf.Middleware _corsMiddleware() {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };

  return shelf.createMiddleware(requestHandler: (request) {
    if (request.method == 'OPTIONS') {
      return shelf.Response.ok('', headers: headers);
    }
    return null;
  }, responseHandler: (response) {
    return response.change(headers: headers);
  });
}

Future<shelf.Response> _handleRequest(shelf.Request request) async {
  developer.log('收到请求: ${request.url.path}', name: 'proxy_server');
  
  final path = request.url.path.startsWith('api/') 
      ? request.url.path.substring(4) 
      : request.url.path;

  if (path.isEmpty) {
    developer.log('路径不匹配: $path', name: 'proxy_server');
    return shelf.Response.notFound('Not Found');
  }
  final authHeader = request.headers['authorization'];

  if (authHeader == null) {
    developer.log('未提供认证令牌', name: 'proxy_server');
    return shelf.Response.unauthorized('No API token provided');
  }

  try {
    final query = request.url.hasQuery ? '?${request.url.query}' : '';
    final apiUrl = 'https://api.zerotier.com/api/v1/$path$query';
    developer.log('请求 ZeroTier API: $apiUrl', name: 'proxy_server');

    final requestBody = await request.readAsString();

    late http.Response response;
    switch (request.method.toUpperCase()) {
      case 'POST':
        response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': authHeader,
            'Content-Type': 'application/json',
          },
          body: requestBody,
        );
        break;
      case 'DELETE':
        response = await http.delete(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': authHeader,
            'Content-Type': 'application/json',
          },
        );
        break;
      case 'GET':
        response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': authHeader,
            'Content-Type': 'application/json',
          },
        );
        break;
      default:
        return shelf.Response(
          HttpStatus.methodNotAllowed,
          body: json.encode({'error': 'Unsupported method: ${request.method}'}),
          headers: {'Content-Type': 'application/json'},
        );
    }

    developer.log('ZeroTier API 响应状态码: ${response.statusCode}', name: 'proxy_server');

    return shelf.Response(
      response.statusCode,
      body: response.body,
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    developer.log('发生错误: $e', name: 'proxy_server');
    return shelf.Response.internalServerError(
      body: json.encode({'error': e.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  }
} 