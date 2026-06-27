import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/sms_data.dart';
import '../services/settings_service.dart';
import '../services/database_helper.dart';

class ApiService {
  Future<void> syncPendingSms() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      List<SmsData> pendingList = await dbHelper.getPendingSms();

      for (var sms in pendingList) {
        bool isSuccess = await sendSmsToWeb(sms);
        if (isSuccess) {
          await dbHelper.updateStatus(sms.id!, 'sent');
          debugPrint("✅ Synced: ${sms.sender}");
        }
      }
    } catch (e) {
      debugPrint("❌ Sync Error: $e");
    }
  }

  Future<bool> sendSmsToWeb(SmsData sms) async {
    try {
      final settings = await SettingsService.getSettings();
      final String? currentUrl = settings['baseUrl'];
      final String? currentKey = settings['apiKey'];

      if (currentUrl == null || currentUrl.isEmpty) return false;

      final Map<String, dynamic> data = {
        'api_key': currentKey ?? "",
        'sender': sms.sender,
        'message': sms.body,
      };

      final response = await http
          .post(
            Uri.parse(currentUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("🌐 Network Error: $e");
      return false;
    }
  }
}
