import 'package:flutter/material.dart';
import 'package:hentaiz_viewer/views/log_in_page.dart';
import 'package:provider/provider.dart';
import 'package:hentaiz_viewer/view_models/application_view_model.dart';

class AccountAction extends StatelessWidget {
  const AccountAction({super.key});

  @override
  Widget build(BuildContext context) {
    final appVM = Provider.of<ApplicationViewModel>(context);

    if (appVM.isLoggedIn()) {
      return IconButton(
        icon: const Icon(Icons.logout),
        tooltip: "Logout",
        onPressed: () {
          appVM.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Logged out")),
          );
        },
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.login),
        tooltip: "Login",
        onPressed: () {
          // Navigate to login page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LogInPage()),
          );
        },
      );
    }
  }
}
