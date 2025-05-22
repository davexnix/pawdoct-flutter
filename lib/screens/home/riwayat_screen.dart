import 'package:flutter/material.dart';
import 'package:pawdoct/screens/home/hasil_diagnosa.dart';
import 'package:pawdoct/screens/home_screen.dart';
import 'package:pawdoct/models/diagnosis_model.dart';
import 'package:pawdoct/services/api_service.dart';
import 'package:intl/intl.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late Future<List<DiagnosisModel>> diagnosisList;

  @override
  void initState() {
    super.initState();

    try {
      diagnosisList = ApiService().fetchDiagnosisList();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          try {
            diagnosisList = ApiService().fetchDiagnosisList();
          } catch (e) {
            print(e);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  IconButton(
                      onPressed: () {
                        HomeScreen.navIndex.value = 1;
                      },
                      icon: const Icon(Icons.arrow_back)
                  ),
                  Text(
                    'Riwayat Diagnosa Anda',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                      onPressed: () {
                        HomeScreen.navIndex.value = 3;
                      },
                      icon: const Icon(Icons.arrow_forward)
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // List Riwayat Diagnosa
              FutureBuilder(
                  future: diagnosisList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Terjadi kesalahan saat memuat data'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Tidak ada data yang ditemukan'));
                    }

                    final list = snapshot.data!;

                    return Column(
                      children: List.generate(list.length, (index) {
                        final item = list[index];
                        final totalProb = item.results.probabilities.values.fold(0.0, (a, b) => a + b);
                        final detailPersentase = item.results.probabilities.map((key, value) {
                          final percent = totalProb == 0 ? 0.0 : (value / totalProb) * 100;
                          return MapEntry(key, percent);
                        });
                        final persentase = detailPersentase[item.results.prediction] ?? 0.0;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Nama Kucing: ${item.petName}",
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("Diagnosa: ${item.results.prediction} $persentase%"),
                                const SizedBox(height: 4),
                                Text("Tanggal: ${DateFormat('d MMMM y', 'id_ID').format(list[index].createdAt!)}"),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => HasilDiagnosaPage(diagnosis: item, showSaveActions: false))
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigoAccent,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Lihat detail',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
