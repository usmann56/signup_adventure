import 'package:flutter/material.dart';
import 'success_screen.dart'; // Import for navigation
import 'package:confetti/confetti.dart';

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

  double _progress = 0.0; // 0.0 → 1.0
  String _progressMessage = "";

  final ConfettiController _progressConfettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );
  Set<int> _milestonesReached = {}; // Track which milestones fired

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
    _updateProgress();
  }

  String _getStrengthLabel() {
    if (_passwordStrength <= 0.25) return "Very Weak 🔴";
    if (_passwordStrength <= 0.50) return "Weak 🟠";
    if (_passwordStrength <= 0.75) return "Strong 🟡";
    return "Excellent ✅";
  }

  void _updateProgress() {
    double progress = 0;

    if (_nameController.text.isNotEmpty) progress += 0.2;
    if (_emailController.text.isNotEmpty) progress += 0.2;
    if (_passwordController.text.isNotEmpty) progress += 0.2;
    if (_dobController.text.isNotEmpty) progress += 0.2;
    if (_avatarController.text.isNotEmpty) progress += 0.2;

    setState(() {
      _progress = progress;

      // Milestones
      int milestonePercent = (_progress * 100).round();

      if (!_milestonesReached.contains(milestonePercent) &&
          [20, 40, 60, 80, 100].contains(milestonePercent)) {
        _milestonesReached.add(milestonePercent);
        _progressConfettiController.play();

        switch (milestonePercent) {
          case 20:
            _progressMessage = "🌟 First Steps! Keep Going!";
            break;
          case 40:
            _progressMessage = "🔥 Second Step Done!";
            break;
          case 60:
            _progressMessage = "More Then Halfway There! You got this!";
            break;
          case 80:
            _progressMessage = "⚡ Almost Complete! Adventure Awaits!";
            break;
          case 100:
            _progressMessage = "🏆 Fully Ready! Let’s Begin the Journey!";
            break;
        }
      }
    });
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
    _updateProgress();
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
                ValidatedTextField(
                  controller: _nameController,
                  label: 'Adventure Name',
                  icon: Icons.person,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your name adventurer!' : null,
                  onChanged: (_) => _updateProgress(),
                ),
                const SizedBox(height: 20),
                ValidatedTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  validator: (value) {
                    if (value!.isEmpty) return 'Email required!';
                    if (!value.contains('@')) return 'Enter valid email';
                    return null;
                  },
                  onChanged: (_) => _updateProgress(),
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
                      onTap: () {
                        setState(() {
                          _avatarController.text = emoji;
                        });
                        _updateProgress();
                      },

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade300,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${(_progress * 100).round()}%",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _progressMessage,
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _progressConfettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      Colors.deepPurple,
                      Colors.purple,
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                    ],
                  ),
                ),

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
}

class ValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final void Function(String)? onChanged;
  final bool obscureText;

  const ValidatedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.onChanged,
    this.obscureText = false,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField>
    with SingleTickerProviderStateMixin {
  bool _isValid = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticIn,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _validate(String value) {
    final error = widget.validator(value);
    final valid = error == null;

    setState(() {
      _isValid = valid;
      _errorMessage = error;
    });

    if (_isValid) {
      _animationController.forward().then(
        (_) => _animationController.reverse(),
      );
    } else {
      _animationController.forward(from: 0);
    }

    if (widget.onChanged != null) widget.onChanged!(value);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_isValid ? 0 : _shakeAnimation.value, 0),
              child: child,
            );
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            onChanged: _validate,
            decoration: InputDecoration(
              labelText: widget.label,
              prefixIcon: Icon(widget.icon, color: Colors.deepPurple),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              errorText: _errorMessage,
            ),
          ),
        ),
        if (_isValid)
          Positioned(
            right: 12,
            child: ScaleTransition(
              scale: Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
            ),
          ),
      ],
    );
  }
}
