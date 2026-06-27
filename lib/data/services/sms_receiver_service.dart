import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/sms_data.dart';
import 'database_helper.dart';
import '../providers/api_service.dart';
import '../services/settings_service.dart';

class SmsReceiverService {
  static const platform = MethodChannel('com.example.ideaflow_sms/sms');

  static String _accumulatedBody = "";
  static Timer? _bufferTimer;
  static String? _currentSender;

  void startListening() {
    platform.setMethodCallHandler((call) async {
      debugPrint("📩 Flutter: Method Received -> ${call.method}");

      if (call.method == "onSmsReceived") {
        final Map<dynamic, dynamic> args = call.arguments;
        String sender = args['sender'] ?? "";
        String body = args['body'] ?? "";

        debugPrint("🔍 Received SMS Fragment from $sender");
        await processIncomingSms(sender, body);
      }
    });
  }

  Future<void> processIncomingSms(String sender, String body) async {
    final settings = await SettingsService.getSettings();
    final String? allowedMasksRaw = settings['senderMask'];

    if (allowedMasksRaw == null || allowedMasksRaw.isEmpty) {
      debugPrint("🚫 No allowed sender masks configured.");
      return;
    }

    List<String> allowedMasks =
        allowedMasksRaw.split(',').map((e) => e.trim().toLowerCase()).toList();

    String currentSenderLower = sender.trim().toLowerCase();

    if (!allowedMasks.contains(currentSenderLower)) {
      debugPrint("🚫 Mask does not match.: $sender");
      return;
    }

    _currentSender = sender;
    _accumulatedBody += body;

    _bufferTimer?.cancel();

    _bufferTimer = Timer(const Duration(milliseconds: 1500), () async {
      debugPrint("✅ Full Message Collected. Saving to DB...");

      final finalMessage = _accumulatedBody;
      final finalSender = _currentSender ?? "Unknown";

      // Reset variables for next message
      _accumulatedBody = "";
      _currentSender = null;

      SmsData newSms = SmsData(
        sender: finalSender,
        body: finalMessage,
        refNo: "FULL_CONTENT",
        amount: "0.00",
        status: "pending",
      );

      try {
        await DatabaseHelper.instance.insertSms(newSms);
        debugPrint("💾 Full SMS has been saved to the database.");

        await ApiService().syncPendingSms();
        debugPrint("📡 Sync request sent to server.");
      } catch (e) {
        debugPrint("❌ Error saving/syncing SMS: $e");
      }
    });
  }
}
