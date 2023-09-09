import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_remembrance/services/auth/auth_exceptions.dart';
import 'package:project_remembrance/services/auth/bloc/auth_bloc.dart';
import 'package:project_remembrance/services/auth/bloc/auth_event.dart';
import 'package:project_remembrance/utilities/dialogs/loading_dialog.dart';
import '../services/auth/bloc/auth_state.dart';
import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  CloseDialog? _closeDialogHandle;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final closeDialog = _closeDialogHandle;

          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialogHandle = null;
          } else if (state.isLoading && closeDialog == null) {
            _closeDialogHandle = showLoadingDialog(
                context: context,
                text: 'Loading...'
            );
          }

          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else
          if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: Scaffold(
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
                    onPressed: () {
                      context.read<AuthBloc>().add(
                          const AuthEventShouldRegister()
                      );
                    },
                    child: const Text('Not a member? Click here to register.')
                )
              ],
            ),
          ],
        ),
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
