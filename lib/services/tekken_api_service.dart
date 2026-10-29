import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/move_model.dart';
import 'api_config.dart';

class TekkenApiService {
  static const Duration _timeout = Duration(seconds: 20);

  Future<List<MoveModel>> getMoveTable(String characterName) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.moveTableEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'character_name': characterName.trim().toLowerCase(),
          }),
        )
        .timeout(_timeout);

    return _parseMoves(response);
  }

  Future<List<MoveModel>> findMove({
    required String characterName,
    String? moveName,
    String? notation,
  }) async {
    final body = <String, dynamic>{
      'character_name': characterName.trim().toLowerCase(),
    };

    if (moveName != null && moveName.trim().isNotEmpty) {
      body['name_move'] = moveName.trim();
    }

    if (notation != null && notation.trim().isNotEmpty) {
      body['notation'] = notation.trim();
    }

    if (body.length == 1) {
      throw Exception('Masukkan nama jurus atau notasi tombol.');
    }

    final response = await http
        .post(
          Uri.parse(ApiConfig.findMoveEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    return _parseMoves(response);
  }

  List<MoveModel> _parseMoves(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      var reason = '';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map<String, dynamic> && errorBody['detail'] is String) {
          reason = ' ${errorBody['detail']}';
        }
      } on FormatException {
        // Keep the HTTP status message when the server did not return JSON.
      }
      if (reason.isEmpty) {
        reason = 'Periksa karakter dan konfigurasi API.';
      }
      throw Exception(
        'Server mengembalikan HTTP ${response.statusCode}. $reason',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Format respons API tidak sesuai.');
    }

    final dynamic rawData = decoded['data'];

    if (rawData is! List) {
      throw Exception('Data jurus tidak ditemukan dalam respons API.');
    }

    return rawData
        .whereType<Map<String, dynamic>>()
        .map((json) => MoveModel.fromJson(json))
        .toList();
  }
}
