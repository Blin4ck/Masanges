import 'package:chat2/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:chat2/pages/login_page.dart';
import 'package:chat2/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, required this.isRegistering}) : super(key: key);

  static Route<void> route({bool isRegistering = false}) {
    return CupertinoPageRoute(
      builder: (context) => RegisterPage(isRegistering: isRegistering),
    );
  }

  final bool isRegistering;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  Future<void> _signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;

    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      _emailController.clear();
      _passwordController.clear();
      _usernameController.clear();

      Navigator.of(context)
          .pushAndRemoveUntil(HomePage.route(), (route) => false);
    } on AuthException catch (error) {
      _showErrorDialog(error.message);
    } catch (error) {
      _showErrorDialog(unexpectedErrorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color.fromARGB(255, 28, 27, 27), // Темный фон
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Register',
          style: TextStyle(color: Colors.white), // Белый текст
        ),
        backgroundColor: Color.fromARGB(255, 28, 27, 27), // Темный фон
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 150.0),
          child: ListView(
            padding: formPadding,
            children: [
              _buildTextFieldRow(
                controller: _emailController,
                placeholder: 'Email',
                icon: Icons.email,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(val)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              formSpacer,
              _buildTextFieldRow(
                controller: _passwordController,
                placeholder: 'Password',
                icon: Icons.lock,
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  if (val.length < 6) {
                    return '6 characters minimum';
                  }
                  return null;
                },
              ),
              formSpacer,
              _buildTextFieldRow(
                controller: _usernameController,
                placeholder: 'Username',
                icon: Icons.person,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
                  if (!isValid) {
                    return '3-24 long with alphanumeric or underscore';
                  }
                  return null;
                },
              ),
              formSpacer,
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? const CupertinoActivityIndicator()
                    : const Text('Register'),
              ),
              formSpacer,
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).push(LoginPage.route());
                },
                child: const Text('I already have an account',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldRow({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: CupertinoTextFormFieldRow(
            controller: controller,
            placeholder: placeholder,
            placeholderStyle: const TextStyle(color: Colors.white54),
            style: const TextStyle(color: Colors.white),
            validator: validator,
            obscureText: obscureText,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
