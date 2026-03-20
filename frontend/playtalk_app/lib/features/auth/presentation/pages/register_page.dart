import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _collegeController = TextEditingController();

  final Dio _dio = Dio();

  String _selectedRole = 'user';
  File? _idProofFile;

  bool _isLoading = false;
  bool _obscurePassword = true;

  static const String baseUrl = "http://172.70.105.138:3000";

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  bool get _needsIdProof =>
      _selectedRole == 'match_admin' || _selectedRole == 'super_admin';

  Future<void> _pickIdProof() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _idProofFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showSnackBar("Failed to pick ID proof");
    }
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final college = _collegeController.text.trim().toLowerCase();

    // VALIDATION
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        college.isEmpty ||
        _selectedRole.isEmpty) {
      _showSnackBar("Please fill all required fields");
      return;
    }

    if (!email.contains('@')) {
      _showSnackBar("Please enter a valid email");
      return;
    }

    if (password.length < 6) {
      _showSnackBar("Password must be at least 6 characters");
      return;
    }

    if (_needsIdProof && _idProofFile == null) {
      _showSnackBar("ID proof is required for admins");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> formMap = {
        "name": name,
        "email": email,
        "password": password,
        "college": college, // IMPORTANT: always send for all roles
        "role": _selectedRole,
      };

      if (_needsIdProof && _idProofFile != null) {
        formMap["idProof"] = await MultipartFile.fromFile(
          _idProofFile!.path,
          filename: _idProofFile!.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formMap);

      final response = await _dio.post(
        "$baseUrl/auth/register",
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
          validateStatus: (status) => status != null,
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message =
            response.data["message"] ?? "Registration successful";

        _showSnackBar(message);

        // Go to login after success
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        });
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? (response.data["error"] ?? "Registration failed")
            : "Registration failed";

        _showSnackBar(errorMessage.toString());
      }
    } catch (e) {
      _showSnackBar("Registration failed. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdminRole = _needsIdProof;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              const Icon(
                Icons.app_registration_rounded,
                size: 72,
                color: Colors.blueGrey,
              ),

              const SizedBox(height: 20),

              const Text(
                "Create your PlayTalk account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),

              const SizedBox(height: 28),

              // FULL NAME
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // EMAIL
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // PASSWORD
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // COLLEGE (IMPORTANT FOR ALL ROLES)
              TextField(
                controller: _collegeController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "College Code (e.g. iiitl27)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ROLE DROPDOWN
              InputDecorator(
                decoration: InputDecoration(
                  labelText: "Select Role",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('User'),
                      ),
                      DropdownMenuItem(
                        value: 'match_admin',
                        child: Text('Match Admin'),
                      ),
                      DropdownMenuItem(
                        value: 'super_admin',
                        child: Text('Super Admin'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedRole = value;

                        // clear ID proof if switching to user
                        if (!_needsIdProof) {
                          _idProofFile = null;
                        }
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ID PROOF (ONLY FOR ADMINS)
              if (isAdminRole) ...[
                OutlinedButton.icon(
                  onPressed: _pickIdProof,
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    _idProofFile == null
                        ? "Upload ID Proof"
                        : "Selected: ${_idProofFile!.path.split('/').last}",
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "ID proof is required only for Match Admin and Super Admin.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),
              ],

              // REGISTER BUTTON
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    disabledBackgroundColor: Colors.blueAccent.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 22),

              // LOGIN LINK
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}