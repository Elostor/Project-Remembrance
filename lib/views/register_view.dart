import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:project_remembrance/constants/routes.dart';
import 'package:project_remembrance/services/auth/auth_exceptions.dart';
import 'package:project_remembrance/services/auth/auth_service.dart';
import '../utilities/dialogs/error_dialog.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'),),
      body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "E-mail",
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
                hintText: "Password"
            ),
            maxLength: 12,
          ),
          TextButton(
            onPressed: () async {
              final emailText = _email.text;
              final passwordText = _password.text;

              try {
                final registerCredential = await AuthService.firebase().createAccount(
                    email: emailText,
                    password: passwordText
                ).then((_) {
                  AuthService.firebase().sendEmailVerification();
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                  });
                devtools.log(registerCredential.toString());
              } on WeakPasswordAuthException {
                if (mounted) {
                  await showErrorDialog(context, 'Weak Password');
                  devtools.log('Weak password.');
                }
              } on EmailAlreadyInUseAuthException {
                if (mounted) {
                  await showErrorDialog(context, 'E-mail already in use');
                  devtools.log('E-mail is already in use');
                }
              } on InvalidEmailAuthException {
                if (mounted) {
                  await showErrorDialog(context, 'Invalid E-mail');
                  devtools.log('E-mail is invalid.');
                }
              } on GenericAuthException {
                if (mounted) {
                  await showErrorDialog(context, 'Error: Auth Error Code GR');
                  devtools.log('Error: Auth Error Code GR');
                }
              }
            },
            child:  const Text("Register"),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute, (route) => false);
              },
              child: const Text('Already registered? Click here to go back to login.')
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
