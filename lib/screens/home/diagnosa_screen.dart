import 'package:flutter/material.dart';
import 'package:pawdoct/screens/home_screen.dart';
import 'package:pawdoct/services/api_service.dart';
import 'package:pawdoct/utils/str.dart';
import 'hasil_diagnosa.dart';

class DiagnosaScreen extends StatefulWidget {
  const DiagnosaScreen({super.key});

  @override
  State<DiagnosaScreen> createState() => _DiagnosaScreenState();
}

class _DiagnosaScreenState extends State<DiagnosaScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  bool isChecking = false;

  final List<String> genders = ['Jantan', 'Betina'];
  late Future<List<String>> gejalaList;
  final Set<String> gejalaTerpilih = {};

  @override
  void initState()  {
    super.initState();

    try {
      gejalaList = ApiService().fetchDiagnosisFeatures();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          try {
            setState(() {
              gejalaTerpilih.removeAll(gejalaTerpilih.toList());
              gejalaList = ApiService().fetchDiagnosisFeatures();
            });
          } catch (e) {
            print(e);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        HomeScreen.navIndex.value = 0;
                      },
                      icon: const Icon(Icons.arrow_back)
                  ),
                  Text(
                    'Konsultasi Sekarang!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                      onPressed: () {
                        HomeScreen.navIndex.value = 2;
                      },
                      icon: const Icon(Icons.arrow_forward)
                  ),
                ],
              ),


              const SizedBox(height: 24),
              _buildNameInput(),
              const SizedBox(height: 16),
              _buildGenderSelect(),
              const SizedBox(height: 24),
              _buildGejalaList(),
              const SizedBox(height: 24),
              _buildDiagnosisButton(),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isChecking ? null : _handleDiagnosis,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isChecking ? CircularProgressIndicator(color: Colors.white) : Text(
          'Diagnosa',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildGejalaList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Pilih Gejala',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<String>>(
          future: gejalaList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Terjadi kesalahan saat memuat data'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada data yang ditemukan'));
            }

            final list = snapshot.data!;

            return SizedBox(
              // height: (60 * list.length) + 60,
              height: 400,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  String gejala = list[index];
                  bool selected = gejalaTerpilih.contains(gejala);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            gejalaTerpilih.remove(gejala);
                          } else {
                            gejalaTerpilih.add(gejala);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue, width: 1.2),
                          color: selected
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              toPascalCase(gejala),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color: selected ? Colors.blue : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nama Kucing'),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Contoh: Oyen',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jenis Kelamin'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Pilih jenis kelamin',
          ),
          items: genders
              .map((gender) => DropdownMenuItem(
            value: gender,
            child: Text(gender),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
      ],
    );
  }

  void _handleDiagnosis() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Nama kucing tidak boleh kosong!');
      return;
    }

    if (!genders.contains(_selectedGender)) {
      _showError('Pilih jenis kelamin kucing kamu!');
      return;
    }

    if (gejalaTerpilih.isEmpty) {
      _showError('Pilih beberapa gejala penyakit!');
      return;
    }

    setState(() {
      isChecking = true;
    });

    try {
      final result = await ApiService().diagnosisCheck(
        petName: _nameController.text.trim(),
        petGender: _selectedGender!.toLowerCase(),
        symptom: gejalaTerpilih,
      );

      setState(() {
        isChecking = false;
      });

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HasilDiagnosaPage(
              diagnosis: result,
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
      setState(() {
        isChecking = false;
      });
      _showError('Terjadi kesalahan saat memproses data!');
    }
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
