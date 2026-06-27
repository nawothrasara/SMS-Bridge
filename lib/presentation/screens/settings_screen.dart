import 'package:flutter/material.dart';
import '../../data/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color appOrange = Color(0xFFFF8A01);
  static const Color appBlack = Color(0xFF1A1A1A);
  //static const Color appWhite = Colors.white;

  final _urlController = TextEditingController();
  final _maskController = TextEditingController();
  final _keyController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final settings = await SettingsService.getSettings();
    setState(() {
      _urlController.text = settings['baseUrl'] ?? "";
      _maskController.text = settings['senderMask'] ?? "";
      _keyController.text = settings['apiKey'] ?? "";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // const appBlue = Color(0xFF3F51B5);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: appOrange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("API Configuration"),
                    const SizedBox(height: 15),
                    _buildTextField(
                      "Base URL",
                      _urlController,
                      Icons.link,
                      "https://example.com/api",
                    ),
                    _buildTextField(
                      "API Key",
                      _keyController,
                      Icons.vpn_key,
                      "Enter secret key",
                    ),

                    const SizedBox(height: 25),

                    _buildSectionTitle("SMS Configuration"),
                    const SizedBox(height: 15),
                    _buildTextField(
                      "Sender Masks / Numbers",
                      _maskController,
                      Icons.phone_android,
                      "e.g: eZ Cash, Dialog, 076XXXXXXX",
                    ),
                    const Text(
                      " Separate multiple masks with a comma (,)",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),

                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          await SettingsService.saveSettings(
                            _urlController.text.trim(),
                            _maskController.text.trim(),
                            _keyController.text.trim(),
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Settings Saved Successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          "SAVE SETTINGS",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: appBlack,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF3F51B5), size: 22),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}
