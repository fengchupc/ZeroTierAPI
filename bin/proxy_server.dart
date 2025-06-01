import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(_handleRequest);

  final server = await io.serve(handler, 'localhost', 3000);
  print('代理服务器运行在: ${server.address.host}:${server.port}');
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
  print('收到请求: ${request.url.path}');
  
  final path = request.url.path.startsWith('api/') 
      ? request.url.path.substring(4) 
      : request.url.path;

  if (!path.startsWith('devices/')) {
    print('路径不匹配: $path');
    return shelf.Response.notFound('Not Found');
  }

  final networkId = path.substring('devices/'.length);
  final authHeader = request.headers['authorization'];

  print('处理请求: networkId=$networkId');

  if (authHeader == null) {
    print('未提供认证令牌');
    return shelf.Response.unauthorized('No API token provided');
  }

  try {
    final apiUrl = 'https://api.zerotier.com/api/v1/network/$networkId/member';
    print('请求 ZeroTier API: $apiUrl');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': authHeader,
        'Content-Type': 'application/json',
      },
    );

    print('ZeroTier API 响应状态码: ${response.statusCode}');

    return shelf.Response(
      response.statusCode,
      body: response.body,
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print('发生错误: $e');
    return shelf.Response.internalServerError(
      body: json.encode({'error': e.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  }
} 