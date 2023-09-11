import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_remembrance/services/auth/auth_exceptions.dart';
import 'package:project_remembrance/services/auth/bloc/auth_bloc.dart';
import 'package:project_remembrance/services/auth/bloc/auth_event.dart';
import 'package:project_remembrance/services/auth/bloc/auth_state.dart';
import 'package:project_remembrance/utilities/dialogs/error_dialog.dart';

import '../utilities/dialogs/password_reset_enail_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.emailSent) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (mounted && state.exception != null) {
            final String exceptionText;

            switch (state.exception) {
              case InvalidEmailAuthException() :
                exceptionText = 'We could not process your request. Please check your user credentials';
              case UserNotFoundAuthException() :
                exceptionText = 'User does not exist.';
              default :
                exceptionText = 'We could not process your request. Please try again later.';
            }
            await showErrorDialog(context, exceptionText);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('If you forgot your password, please simply enter your email and a reset link will be sent'),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Your email address...'
                ),
              ),
              TextButton(
                  onPressed: () {
                    final email = _controller.text;
                    context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                  },
                  child: const Text('Send me a reset link')
              ),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: const Text('Back to the login page')
              ),
            ],
          ),
        ),
      ),
    );
  }
}
