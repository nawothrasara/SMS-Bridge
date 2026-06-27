import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'data/services/sms_receiver_service.dart';
import 'data/providers/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SmsReceiverService().startListening();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: false,
    ),
    iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  const backgroundChannel = MethodChannel('com.example.ideaflow_sms/sms');

  backgroundChannel.setMethodCallHandler((call) async {
    if (call.method == "onSmsReceived") {
      final Map<dynamic, dynamic> args = call.arguments;
      String sender = args['sender'] ?? "Unknown";
      String body = args['body'] ?? "";
      final smsService = SmsReceiverService();
      await smsService.processIncomingSms(sender, body);
    }
  });

  await ApiService().syncPendingSms();
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    await ApiService().syncPendingSms();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IdeaFlow SMS Forward',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3F51B5),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3F51B5),
        brightness: Brightness.dark,
      ),
      home: const MainPermissionWrapper(),
    );
  }
}

class MainPermissionWrapper extends StatefulWidget {
  const MainPermissionWrapper({super.key});

  @override
  State<MainPermissionWrapper> createState() => _MainPermissionWrapperState();
}

class _MainPermissionWrapperState extends State<MainPermissionWrapper> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.sms,
      Permission.notification,
      Permission.ignoreBatteryOptimizations,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}
