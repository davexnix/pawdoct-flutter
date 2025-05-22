import 'package:flutter/material.dart';
import 'package:pawdoct/models/buletin_model.dart';
import 'package:pawdoct/screens/home_screen.dart';
import 'package:pawdoct/services/api_service.dart';
import 'package:pawdoct/services/storage_service.dart';
import 'package:pawdoct/utils/alert.dart';
import 'package:url_launcher/url_launcher.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String? userName;
  late Future<List<BuletinModel>> futureBulletins;

  @override
  void initState() {
    super.initState();

    final user = StorageService().user;
    if (user != null) {
      userName = user.name;
    }
    futureBulletins = ApiService().fetchBulletins();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            futureBulletins = ApiService().fetchBulletins(refresh: true);
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi $userName',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Cari tahu apa keluhan kucing kesayangan mu',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kucing Sehat, Pemlik Bahagia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yuk cak gelala kucing anda disini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    HomeScreen.navIndex.value = 1;
                  },
                  child: const Text(
                    'Diagnosa Kucingmu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Divider(height: 1),
              const SizedBox(height: 24),
              Text(
                'Buletin Pawrent',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              FutureBuilder<List<BuletinModel>>(
                future: futureBulletins,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Gagal memuat buletin');
                  }

                  final items = snapshot.data ?? [];
                  return Column(
                    children: items.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildBulletinItem(
                        title: b.title,
                        subtitle: b.excerpt,
                        time: b.date,
                        onTap: () {
                          showConfirmDialog(
                              context, title: 'Baca Artikel',
                              content: 'Buka artikel ini menggunakan browser external?',
                              onConfirmed: (){
                                _launchURL(b.link);
                              });
                        },
                      ),
                    )).toList(),
                  );
                },
              )
            ],
          ),
        )
      ),
    );
  }

  Widget _buildBulletinItem({
    required String title,
    String? subtitle,
    required String time,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      _showError('Tidak dapat membuka buletin link');
    }
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
