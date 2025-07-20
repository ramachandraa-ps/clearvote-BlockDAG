import 'dart:convert';
import 'package:clearvote/core/config/app_config.dart';

class ApiService {
  final String baseUrl;
  
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.instance.apiBaseUrl;
  
  Future<Map<String, dynamic>> get(String endpoint) async {
    // This is a placeholder for actual HTTP implementation
    // In a real app, you would use http or dio package
    await Future.delayed(const Duration(milliseconds: 300));
    
    return {
      'success': true,
      'data': {'message': 'Mock API response for GET $endpoint'}
    };
  }
  
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    // This is a placeholder for actual HTTP implementation
    await Future.delayed(const Duration(milliseconds: 300));
    
    return {
      'success': true,
      'data': {
        'message': 'Mock API response for POST $endpoint',
        'receivedData': data
      }
    };
  }
}