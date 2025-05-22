import 'package:flutter/material.dart';
import 'package:pawdoct/models/diagnosis_model.dart';
import 'package:pawdoct/screens/home_screen.dart';
import 'package:pawdoct/services/api_service.dart';
import 'package:pawdoct/utils/alert.dart';
import 'package:pawdoct/utils/colors.dart';
import 'package:pawdoct/utils/str.dart';
import 'package:url_launcher/url_launcher.dart';

class HasilDiagnosaPage extends StatelessWidget {
  late final String prediction;
  late final double persentase;
  late final List<String> gejalaDipilih;
  late final Map<String, double> detailPersentase;
  late final List<String> penanganan;

  final DiagnosisModel diagnosis;
  final bool showSaveActions;

  HasilDiagnosaPage({
    super.key,
    required this.diagnosis,
    this.showSaveActions = true,
  }) {
    prediction = diagnosis.results.prediction;

    // Hitung total probabilitas
    final totalProb = diagnosis.results.probabilities.values.fold(0.0, (a, b) => a + b);

    // Normalisasi agar total maksimal 100%
    detailPersentase = diagnosis.results.probabilities.map((key, value) {
      final percent = totalProb == 0 ? 0.0 : (value / totalProb) * 100;
      return MapEntry(key, percent);
    });

    // Persentase penyakit utama (prediksi)
    persentase = detailPersentase[diagnosis.results.prediction] ?? 0.0;

    // Gejala yang digunakan (value == 1)
    gejalaDipilih = diagnosis.results.featuresUsed.entries
        .where((e) => e.value == 1)
        .map((e) => toPascalCase(e.key))
        .toList();

    penanganan = diagnosis.results.suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Hasil Diagnosa'),
        elevation: 0,
        leading: const SizedBox(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Persentase Diagnosis'),
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.pets, color: PawdoctColors.purple, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        '${persentase.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const Text('Kemungkinan Penyakit', style: TextStyle(color: Colors.grey)),
                      Text(prediction, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoCard(
                    icon: Icons.list_alt,
                    title: 'Gejala Dipilih',
                    items: gejalaDipilih,
                  ),
                  const SizedBox(height: 12),
                  _infoCard(
                    icon: Icons.bar_chart,
                    title: 'Detail Persentase',
                    items: detailPersentase.entries
                        .map((e) => '${e.key}: ${e.value.toStringAsFixed(1)}%')
                        .toList(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _infoCard(
                icon: Icons.healing,
                title: 'Saran Penanganan',
                items: penanganan,
              ),

              const SizedBox(height: 20),

              _sectionTitle('Klinik Terdekat'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  showConfirmDialog(
                      context,
                      title: 'Klinik Tedekat',
                      content: 'Telusuri klinik dokter hewan tedekat disekitar kamu untuk konsultasi lebih lanjut?',
                      onConfirmed: () {
                        _openGoogleMapsURL(context);
                      });
                },
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/maps.png'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ...[showSaveActions ? SaveButtonActions(diagnosis: diagnosis) : DeleteButtonActions(diagnosis: diagnosis)]
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.indigo),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((text) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('• $text'),
          )),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  void _openGoogleMapsURL(BuildContext context) async {
    try {
      final uri = Uri.parse('https://www.google.com/maps/search/klinik+dokter+kucing+terdekat');
      if (await canLaunchUrl(uri)) {
        launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka Link Klinik Terdekat!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

class SaveButtonActions extends StatefulWidget {
  final DiagnosisModel diagnosis;

  const SaveButtonActions({
    super.key,
    required this.diagnosis,
  });

  @override
  State<SaveButtonActions> createState() => _SaveButtonActionsState();
}

class _SaveButtonActionsState extends State<SaveButtonActions> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
            onPressed: isLoading ? null : (){
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading ? CircularProgressIndicator() : Text('Ulangi Diagnosa', style: TextStyle(color: Colors.black))
        ),
        const SizedBox(height: 10),
        ElevatedButton(
            onPressed: (){
              saveRiwayatDiagnosa(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigoAccent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: isLoading ? CircularProgressIndicator() : Text('Riwayat Diagnosa', style: TextStyle(color: Colors.white))
        ),
      ],
    );
  }

  void saveRiwayatDiagnosa(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });

      if (await ApiService().diagnosisSave(diagnosis: widget.diagnosis)) {
        if (context.mounted) {
          HomeScreen.navIndex.value = 2;
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        throw Exception('API Failed');
      }
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan riwayat hasil diagnosa!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}

class DeleteButtonActions extends StatefulWidget {
  final DiagnosisModel diagnosis;

  const DeleteButtonActions({
    super.key,
    required this.diagnosis,
  });

  @override
  State<DeleteButtonActions> createState() => _DeleteButtonActionsState();
}

class _DeleteButtonActionsState extends State<DeleteButtonActions> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
            onPressed: isLoading ? null : (){
              if (context.mounted) {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading ? CircularProgressIndicator() : Text('Kembali', style: TextStyle(color: Colors.black))
        ),
        const SizedBox(height: 10),
        ElevatedButton(
            onPressed: (){
              showConfirmDialog(
                  context,
                  title: 'Hapus Riwayat',
                  content: 'Apakah anda yakin ingin menghapus riwayat diagnosa ini?',
                  onConfirmed: (){
                    deleteRiwayatDiagnosa(context);
                  });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: isLoading ? CircularProgressIndicator() : Text('Hapus Riwayat', style: TextStyle(color: Colors.white))
        ),
      ],
    );
  }

  void deleteRiwayatDiagnosa(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });

      if (await ApiService().diagnosisDelete(id: widget.diagnosis.id!)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil menghapus riwayat diagnosa!'),
              backgroundColor: Colors.green,
            ),
          );
          HomeScreen.navIndex.value = 2;
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        throw Exception('API Failed');
      }
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus riwayat diagnosa!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}

