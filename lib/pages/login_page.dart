import 'package:chat2/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:chat2/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return CupertinoPageRoute(builder: (context) => const LoginPage());
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.of(context)
          .pushAndRemoveUntil(HomePage.route(), (route) => false);
    } on AuthException catch (error) {
      _showErrorDialog(error.message);
    } catch (_) {
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color.fromARGB(255, 28, 27, 27),
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Sign In',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 28, 27, 27),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 210.0),
        child: ListView(
          padding: formPadding,
          children: [
            _buildTextFieldRow(
              controller: _emailController,
              placeholder: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            formSpacer,
            _buildTextFieldRow(
              controller: _passwordController,
              placeholder: 'Password',
              icon: Icons.lock,
              obscureText: true,
            ),
            formSpacer,
            CupertinoButton.filled(
              onPressed: _isLoading ? null : _signIn,
              child: _isLoading
                  ? const CupertinoActivityIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldRow({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
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
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
