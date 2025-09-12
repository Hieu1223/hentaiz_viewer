import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hentaiz_viewer/view_models/application_view_model.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRegisterMode = false;
  bool _loading = false;

  void _submit(BuildContext context) async {
    final appVM = Provider.of<ApplicationViewModel>(context, listen: false);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username and password cannot be empty")),
      );
      return;
    }

    setState(() => _loading = true);

    bool success = false;

    if (_isRegisterMode) {
      success = await appVM.register(username, password); // now auto-login
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful")),
        );
        Navigator.pop(context); // 👈 close page after success
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Registration failed")));
      }
    } else {
      success = await appVM.login(username, password);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login successful")));
        Navigator.pop(context); // 👈 close page after success
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login failed")));
      }
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegisterMode ? "Register" : "Log In")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _submit(context),
                    child: Text(_isRegisterMode ? "Register" : "Log In"),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  setState(() => _isRegisterMode = !_isRegisterMode),
              child: Text(
                _isRegisterMode
                    ? "Already have an account? Log in"
                    : "Don't have an account? Register",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
