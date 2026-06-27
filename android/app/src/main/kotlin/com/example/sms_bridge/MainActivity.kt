package com.example.sms_bridge

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.provider.Telephony
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.ideaflow_sms/sms"
    private lateinit var channel: MethodChannel
    private var smsReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        smsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
                    val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                    messages?.forEach { sms ->
                        val sender = sms.originatingAddress ?: "Unknown"
                        val body = sms.messageBody ?: ""
                        runOnUiThread {
                            channel.invokeMethod(
                                "onSmsReceived",
                                mapOf("sender" to sender, "body" to body)
                            )
                        }
                    }
                }
            }
        }

        val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
        filter.priority = 999
        registerReceiver(smsReceiver, filter)
    }

    override fun onDestroy() {
        smsReceiver?.let { unregisterReceiver(it) }
        super.onDestroy()
    }
}