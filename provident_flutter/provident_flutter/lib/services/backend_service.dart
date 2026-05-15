import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/analysis_result.dart';

class BackendService {
  BackendService._();

  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://10.109.102.184:8000',
  );

  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static Future<AnalysisResult> analyzeImage(File imageFile) async {
    final uri = _uri('/analyze');
    final request = http.MultipartRequest('POST', uri);

    final contentType = _mimeTypeForPath(imageFile.path);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: contentType,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(
          'Server returned ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return AnalysisResult.fromJson(decoded);
  }

  static MediaType _mimeTypeForPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'bmp':
        return MediaType('image', 'bmp');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}
