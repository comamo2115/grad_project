// profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final token = await storage.read(key: "access_token");
      if (token == null) {
        setState(() => _loading = false);
        return;
      }

      final url = Uri.parse("http://127.0.0.1:8000/api/auth/me/");
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          _user = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await storage.delete(key: "access_token");
    await storage.delete(key: "refresh_token");

    if (!mounted) return;

    // ★ ルート全体を破棄して /login だけに戻す
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFFBFB69B),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_user != null) ...[
                    Text(
                      "ID: ${_user!['id']}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Username: ${_user!['username']}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Gender: ${_user!['gender']}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ] else ...[
                    const Center(child: Text("로그인 정보 없음")),
                  ],
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: _logout, // 👈 どんな状態でもログアウト可能
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBF634E),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
