import 'package:flutter/material.dart';
import 'success_screen.dart'; // Import for navigation

// Signup Screen w/ Interactive Form
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();

  final List<String> _avatars = ['😊', '🚀', '🐱', '🌙'];

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  double _passwordStrength = 0;
  Color _strengthColor = Colors.red;

  bool _hadValidationError = false;
  List<String> _badges = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;

    if (password.isEmpty) {
      strength = 0;
    } else {
      if (password.length >= 6) strength += 0.25;
      if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
      if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
      if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')))
        strength += 0.25;
    }

    setState(() {
      _passwordStrength = strength;

      if (strength <= 0.25) {
        _strengthColor = Colors.red;
      } else if (strength <= 0.5) {
        _strengthColor = Colors.orange;
      } else if (strength <= 0.75) {
        _strengthColor = Colors.yellow[700]!;
      } else {
        _strengthColor = Colors.green;
      }
    });
  }

  String _getStrengthLabel() {
    if (_passwordStrength <= 0.25) return "Very Weak 🔴";
    if (_passwordStrength <= 0.50) return "Weak 🟠";
    if (_passwordStrength <= 0.75) return "Strong 🟡";
    return "Excellent ✅";
  }

  void _assignBadges() {
    _badges.clear();

    if (_passwordStrength >= 0.75) {
      _badges.add("🏆 Strong Password Master");
    }

    if (_dobController.text.isNotEmpty) {
      try {
        // Split dd/MM/yyyy
        final parts = _dobController.text.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);

          final dob = DateTime(year, month, day);

          // Born in the 1900s
          if (dob.year < 2000) {
            _badges.add("🕰 Time Traveler (Born in the 1900s)");
          }

          // Gen Alpha Explorer DOB > 2013
          if (dob.year > 2013) {
            _badges.add("🚀 Gen Alpha Explorer");
          }
        }
      } catch (_) {
        // ignore parse errors safely
      }
    }

    if (_hadValidationError == false) {
      _badges.add("✨ Flawless Hero (No Form Errors)");
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _submitForm() {
    // Track validation failures first
    if (!_formKey.currentState!.validate()) {
      _hadValidationError = true;
    }

    if (_avatarController.text.isEmpty) {
      _hadValidationError = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an avatar"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _assignBadges();

      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;

        setState(() => _isLoading = false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              userName: _nameController.text,
              userAvatar: _avatarController.text,
              badges: _badges, // ✅ Pass badges
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account ✅'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),

                _buildTextField(
                  controller: _nameController,
                  label: 'Adventure Name',
                  icon: Icons.person,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your name adventurer!' : null,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  validator: (value) {
                    if (value!.isEmpty) return 'Email required!';
                    if (!value.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.deepPurple,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Choose your birth date' : null,
                ),
                const SizedBox(height: 20),

                // ✅ Password + Strength Meter
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  onChanged: _checkPasswordStrength,
                  decoration: InputDecoration(
                    labelText: 'Secret Password',
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.deepPurple,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () {
                        setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        );
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Password required!';
                    if (value.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // ✅ Strength Bar UI
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade300,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(_strengthColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getStrengthLabel(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _strengthColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ✅ Avatar Pick
                Wrap(
                  spacing: 12,
                  children: _avatars.map((emoji) {
                    final isSelected = _avatarController.text == emoji;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _avatarController.text = emoji),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.purple.withOpacity(0.2)
                              : Colors.grey.shade200,
                          border: Border.all(
                            color: isSelected
                                ? Colors.purple
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // ✅ Button / Loading
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isLoading ? 60 : double.infinity,
                  height: 60,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Start My Adventure 🚀',
                            style: TextStyle(fontSize: 18, color: Colors.white),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }
}
