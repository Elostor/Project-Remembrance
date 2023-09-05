import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_remembrance/constants/routes.dart';
import 'package:project_remembrance/services/auth/auth_service.dart';
import 'dart:developer' as devtools show log;
import '../utilities/dialogs/error_dialog.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> with WidgetsBindingObserver {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification'),),
      body: Column(
        children: [
          const Text('A verification email has been sent. Please verify your email address.'),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Press here for another verification email'),
          ),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().logOut().then( () {Navigator.of(context).pushAndRemoveUntil(
                    loginRoute as Route<Object?>, (route) => false);
                } as FutureOr Function(void value)).catchError((e) {
                  devtools.log(e);
                  showErrorDialog(context, 'Error: ${e.toString()}');
                }
                );
              },
              child: const Text('Logout')
          )
        ],
      ),
    );
  }

  // Here lies a constant checker that can be used to automatically log-in the user
  // The method here presumes that the user puts the application into 'waiting' status,
  // then uses an email application for verification and after that returns to the app again.
  // In short, this AppLifeCycleState method only works when an user chooses to register and verify on a mobile device.
  // Another way is to just log-out the user after registering and/or logging-in.
  /*
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && (user?.emailVerified ?? false)) {
      refreshFirebaseUser().then((value) => setState(() {}));
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> refreshFirebaseUser() async {
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
   */
}

