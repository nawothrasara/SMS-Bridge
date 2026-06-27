import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../data/services/database_helper.dart';
import '../../data/models/sms_data.dart';
import '../../data/providers/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Theme Colors
  static const Color appOrange = Color(0xFFFF8A01);
  static const Color appBlack = Color(0xFF1A1A1A);
  static const Color appWhite = Colors.white;

  // Manual Input Controller
  final TextEditingController _manualInputController = TextEditingController();
  bool _isSubmitting = false;

  Stream<Map<String, int>> _countsStream() async* {
    while (true) {
      try {
        final allSms = await DatabaseHelper.instance.getAllSms();
        int total = allSms.length;
        int pending =
            allSms.where((s) => s.status.toLowerCase() == "pending").length;
        yield {"total": total, "pending": pending};
      } catch (e) {
        debugPrint("Stream Error: $e");
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _handleManualSubmit() async {
    String text = _manualInputController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      SmsData manualSms = SmsData(
        sender: "Manual Entry",
        body: text,
        refNo: "",
        amount: "",
        status: "pending",
      );

      await DatabaseHelper.instance.insertSms(manualSms);

      await ApiService().syncPendingSms();

      _manualInputController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Entry added and syncing..."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Manual Submit Error: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),

          // 📊 Stat Cards Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: StreamBuilder<Map<String, int>>(
                stream: _countsStream(),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? {"total": 0, "pending": 0};
                  return Row(
                    children: [
                      _buildStatCard(
                        "Total Messages",
                        "${stats['total']}",
                        appOrange,
                        Icons.message,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        "Pending",
                        "${stats['pending']}",
                        appOrange,
                        Icons.cloud_off,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ✍️ Manual Input Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Manual Entry",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appBlack,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _manualInputController,
                            decoration: InputDecoration(
                              hintText: "Type or paste content...",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton.filled(
                                onPressed: _handleManualSubmit,
                                icon: const Icon(Icons.send),
                                style: IconButton.styleFrom(
                                  backgroundColor: appOrange,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 📝 Recent Logs Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Text(
                "Recent Logs",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appBlack,
                ),
              ),
            ),
          ),

          // 🔄 Real-time List of Messages
          StreamBuilder<List<SmsData>>(
            stream: Stream.periodic(
              const Duration(seconds: 1),
            ).asyncMap((_) => DatabaseHelper.instance.getAllSms()),
            builder: (context, snapshot) {
              final messages = snapshot.data ?? [];
              if (messages.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text("No transactions recorded yet")),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildSmsTile(messages[index]),
                  childCount: messages.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: appOrange),
            currentAccountPicture: CircleAvatar(
              backgroundColor: appWhite,
              radius: 40,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: ClipOval(
                  child: Image.asset(
                    "assets/icons/drawerScreen_icon.png",
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.flash_on,
                        color: appOrange,
                        size: 30,
                      );
                    },
                  ),
                ),
              ),
            ),
            accountName: const Text(
              "SMS Sync",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text("Version 1.1.0"),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: appOrange),
            title: const Text(
              "Settings",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const Spacer(),
          const Text(
            "Powered by",
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const Text(
            "IDEAFLOW",
            style: TextStyle(
              fontFamily: 'Mokoto',
              color: appOrange,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar.large(
      backgroundColor: appOrange,
      expandedHeight: 120,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: appWhite),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      flexibleSpace: const FlexibleSpaceBar(
        title: Text(
          "Message Forward",
          style: TextStyle(color: appWhite, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 15),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: appBlack,
              ),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmsTile(SmsData sms) {
    bool isNotPending = sms.status.toLowerCase() != "pending";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: appWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isNotPending
              ? Colors.green.withOpacity(0.1)
              : appOrange.withOpacity(0.1),
          child: Icon(
            isNotPending ? Icons.check : Icons.sync,
            color: isNotPending ? Colors.green : appOrange,
            size: 20,
          ),
        ),
        title: Text(
          sms.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          sms.sender,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Text(
          isNotPending ? "Success" : "Pending",
          style: TextStyle(
            color: isNotPending ? Colors.green : appOrange,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
