import 'package:project_remembrance/services/auth/auth_exceptions.dart';
import 'package:project_remembrance/services/auth/auth_provider.dart';
import 'package:project_remembrance/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('Should not be initialized at the beginning', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      provider.logOut();
      throwsA(const TypeMatcher<NotInitializedException>());
    });

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null', () {
      expect(provider.currentUser, null);
    });

    test('Should be able to initialize in a specific time', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create user should delegate to logIn function', () async {
      final badEmailUser = await provider.createAccount(email: 'test2@test.com', password: 'test123');
      expect(
          badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>())
      );

      final badPassword = await provider.createAccount(email: 'test@test.com', password: 'test321');
      expect(
          badPassword,
          throwsA(const TypeMatcher<WrongPasswordAuthException>())
      );

      final user = await provider.createAccount(email: 'test', password: 'test');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to logout and login', () async {
      await provider.logOut();
      await provider.logIn(email: 'test2', password: 'test2');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });

    test('Should be able to reset password', () async {
      final operationSuccess = await provider
          .sendPasswordResetEmail(email: 'test@test.com');
      expect(operationSuccess, true);
    });
    
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  static const String realEmail = 'test@test.com';
  String realPassword = 'test123';


  @override
  Future<AuthUser> createAccount({required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email != realEmail) throw UserNotFoundAuthException();
    if (password != realPassword) throw WrongPasswordAuthException();

    const user = AuthUser(
        userId: 'my_id',
        isEmailVerified: false,
        email: realEmail
    );
    _user = user;

    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    if(_user == null) throw UserNotFoundAuthException();

    const newUser = AuthUser(
        userId: 'my_id',
        isEmailVerified: true,
        email: realEmail
    );
    _user = newUser;
  }

  @override
  Future<bool> sendPasswordResetEmail({required String email}) async {
    if (!isInitialized) throw NotInitializedException();

    String passwordHolder = realPassword;

    if (email != realEmail) {
      throw UserNotFoundAuthException();
    } else {
      await Future.delayed(const Duration(seconds: 1));
      realPassword = 'resetTest123';
    }

    return (realPassword == passwordHolder) ? false : true;
  }

}