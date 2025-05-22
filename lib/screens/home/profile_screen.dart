import 'package:flutter/material.dart';
import 'package:pawdoct/providers/auth_provider.dart';
import 'package:pawdoct/services/api_service.dart';
import 'package:pawdoct/services/storage_service.dart';
import 'package:pawdoct/utils/alert.dart';
import 'package:pawdoct/utils/str.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  String? selectedGender;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final user = StorageService().user;
    if (user != null) {
      usernameController.text = user.username;
      emailController.text = user.email;
      nameController.text = user.name;
      addressController.text = user.address ?? '';
      phoneController.text = user.phone;
      selectedGender = ucfirst(user.gender);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth > 500 ? 500 : screenWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Profil Anda",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _styledField(controller: usernameController, icon: Icons.key, hint: "Username", readOnly: true),
                      _styledField(controller: emailController, icon: Icons.email_outlined, hint: "Email", readOnly: true),
                      _styledField(controller: nameController, icon: Icons.person_outline, hint: "Nama Lengkap", validator: _validateName),
                      _buildGenderDropdown(),
                      _styledField(controller: addressController, icon: Icons.home_outlined, hint: "Alamat", validator: _validateAddress),
                      _styledField(controller: phoneController, icon: Icons.phone_outlined, hint: "Nomor Telepon", validator: _validatePhone),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : () {
                    if (context.mounted && _formKey.currentState!.validate()) {
                      updateProfile(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: isLoading ? null : () {
                    if (context.mounted) {
                      showConfirmDialog(context, title: 'Logout', content: 'Apakah anda ingin Logout dari aplikasi?', onConfirmed: () {
                        logout(context);
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.indigoAccent),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Log Out",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledField({
    TextEditingController? controller,
    required IconData icon,
    required String hint,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        style: TextStyle(
          color: readOnly ? Colors.grey : Colors.black,
        ),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: readOnly ? Colors.grey : null),
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: readOnly ? Colors.grey[200] : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: readOnly ? Colors.grey : Colors.indigoAccent,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: readOnly ? Colors.grey : Colors.indigoAccent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        icon: const Icon(Icons.keyboard_arrow_down),
        decoration: InputDecoration(
          hintText: 'Jenis Kelamin',
          prefixIcon: const Icon(Icons.emoji_emotions_outlined),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigoAccent, width: 1.2),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigoAccent, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: genderOptions.map((gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedGender = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Jenis kelamin tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong!';
    } else if (value.length < 2 || value.length > 150) {
      return 'Nama min 2 karakter max 150 karakter!';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat tidak boleh kosong!';
    } else if (value.length < 5 || value.length > 225) {
      return 'Alamat min 5 karakter max 225 karakter!';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'No HP tidak boleh kosong!';
    } else if (!isNumeric(value)) {
      return 'No HP hanya boleh berisi angka!';
    } else if (value.length < 10 || value.length > 20) {
      return 'No HP min 10 karakter max 20 karakter!';
    }
    return null;
  }

  void logout(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
      }
    }
  }

  void updateProfile(BuildContext context) async {
    final name = nameController.text.trim();
    final address = addressController.text.trim();
    final phone = phoneController.text.trim();

    try {
      setState(() {
        isLoading = true;
      });

      final Map<String, String> body = {
        'name': name,
        'gender': selectedGender!.toLowerCase(),
        'address': address,
        'phone': phone
      };

      final update = await ApiService().updateProfile(body);
      await StorageService().setUser(update);

      usernameController.text = update.username;
      emailController.text = update.email;
      nameController.text = update.name;
      addressController.text = update.address ?? '';
      phoneController.text = update.phone;

      setState(() {
        selectedGender = ucfirst(update.gender);
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile information successfully updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print(e);
      _showError("Failed to update profile information!");
    } finally {
      setState(() {
        isLoading = false;
      });
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