import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:project_remembrance/constants/routes.dart';
import 'package:project_remembrance/services/auth/auth_exceptions.dart';
import 'package:project_remembrance/services/auth/auth_service.dart';
import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),),
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "E-mail",
            ),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
                hintText: "Password"
            ),
            maxLength: 12,
          ),
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  final emailText = _emailController.text;
                  final passwordText = _passwordController.text;
                  final nav = Navigator.of(context);

                  try {
                    final userCredential = await AuthService.firebase().logIn(
                        email: emailText,
                        password: passwordText
                    );
                    if (AuthService.firebase().currentUser?.isEmailVerified ?? false) {
                      nav.pushNamedAndRemoveUntil(
                        notesRoute, (route) => false,
                      );
                    } else {
                      nav.pushNamed(verifyEmailRoute);
                    }
                    devtools.log(userCredential.toString());
                  } on UserNotFoundAuthException {
                    if (mounted) {
                      await showErrorDialog(nav.context, 'User not found');
                      devtools.log('User not found.');
                    }
                  } on WrongPasswordAuthException {
                    if (mounted) {
                      await showErrorDialog(context, 'Wrong credentials');
                      devtools.log('Wrong password.');
                    }
                  } on GenericAuthException {
                    if (mounted) {
                      await showErrorDialog(context, 'Error: Auth Error Code G');
                      devtools.log('Error: Auth Error Code G');
                    }
                  }
                },
                child: const Text("Login"),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute, (route) => false
                    );
                  },
                  child: const Text('Not a member? Click here to register.')
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
}
