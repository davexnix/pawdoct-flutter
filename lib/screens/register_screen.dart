import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pawdoct/utils/colors.dart';
import 'package:pawdoct/widgets/pawdoct_logo.dart';
import 'package:pawdoct/services/api_service.dart'; // pastikan import sesuai

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? selectedGender;
  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void createAccount(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedGender == null) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ApiService().register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text,
        gender: selectedGender!.toLowerCase(),
        address: addressController.text.trim(),
        phone: phoneController.text.trim(),
      );

      if (success) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed'),
              backgroundColor: Colors.redAccent),
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'] ?? 'Unknown error';

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      } else {
        print('Connection error: ${e.message}');
        throw Exception('Connection error');
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}!'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.\w+$').hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8 || value.length > 30) return 'Password must be 8-30 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: pawdoctLogo()),
                  const SizedBox(height: 16),

                  _buildInputField(
                    controller: nameController,
                    icon: Icons.person_outline,
                    hint: 'Full Name',
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : (v.length < 2 ? 'Name must be at least 2 characters' : null),
                  ),

                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: usernameController,
                    icon: Icons.key,
                    hint: 'Username',
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Username is required';
                      if (v.length < 6 || v.length > 30) return '6–30 characters required';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: emailController,
                    icon: Icons.email_outlined,
                    hint: 'Email',
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: passwordController,
                    icon: Icons.lock_outline,
                    hint: 'Password',
                    obscure: true,
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: passwordConfirmController,
                    icon: Icons.lock_outline,
                    hint: 'Confirm Password',
                    obscure: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Confirm your password';
                      if (value != passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: phoneController,
                    icon: Icons.phone_outlined,
                    hint: 'Phone Number',
                    validator: (v) => v == null || v.isEmpty
                        ? 'Phone is required'
                        : (!RegExp(r'^\d+$').hasMatch(v) ? 'Phone must be numeric' : null),
                  ),

                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    decoration: InputDecoration(
                      hintText: 'Gender',
                      prefixIcon: const Icon(Icons.emoji_emotions_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: PawdoctColors.purple, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: PawdoctColors.purple, width: 2),
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
                      setState(() => selectedGender = value);
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: addressController,
                    icon: Icons.home_outlined,
                    hint: 'Address',
                    validator: (v) => v == null || v.isEmpty
                        ? 'Address is required'
                        : (v.length < 5 ? 'Address must be at least 5 characters' : null),
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _isLoading ? null : () => createAccount(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PawdoctColors.purple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Create account',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: PawdoctColors.purple, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: PawdoctColors.purple, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
