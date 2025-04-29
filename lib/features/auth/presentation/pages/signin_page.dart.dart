import 'dart:io';

import 'package:finlytics/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/error_utils.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/authpage_container.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isPasswordObscured = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isFirstLogin = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeAuth();

    // Set Firebase Auth locale if required
    FirebaseAuth.instance.setLanguageCode('fr');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeAuth() async {
    // Set language code
    await FirebaseAuth.instance
        .setLanguageCode(Platform.localeName.split('_')[0]);

    // Check if this is first login
    final prefs = await SharedPreferences.getInstance();
    _isFirstLogin = !(prefs.getBool('hasLoggedInBefore') ?? false);
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ErrorUtils.showSnackBar(
        context: context,
        message: 'Veuillez saisir votre adresse e-mail et votre mot de passe',
        color: AppTheme.errorColor,
        icon: Icons.error_outline,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign in with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        if (!userCredential.user!.emailVerified) {
          ErrorUtils.showSnackBar(
            context: context,
            message: 'Veuillez vérifier votre email',
            color: AppTheme.errorColor,
            icon: Icons.error_outline,
          );
          setState(() => _isLoading = false);
          return;
        }

        // Set login state and first login flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('hasLoggedInBefore', true);

        // Navigate to auth page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthPage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Special handling for first-time login errors
      if (_isFirstLogin && e.code == 'invalid-credential') {
        // Wait briefly and retry authentication
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          final retryCredential = await _auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          if (retryCredential.user != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setBool('hasLoggedInBefore', true);

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()),
              );
            }
            return;
          }
        } catch (retryError) {
          _handleLoginError(e);
        }
      } else {
        _handleLoginError(e);
      }
    } catch (e) {
      ErrorUtils.showSnackBar(
        context: context,
        message: 'Une erreur inattendue s\'est produite. Veuillez réessayer..',
        color: AppTheme.errorColor,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleLoginError(FirebaseAuthException e) {
    print('Firebase Auth Error Code: ${e.code}');
    print('Firebase Auth Error Message: ${e.message}');

    String errorMessage;
    switch (e.code) {
      case 'invalid-credential':
        errorMessage = _isFirstLogin
            ? 'Première connexion en cours. Veuillez réessayer.'
            : 'L\'adresse e-mail ou le mot de passe est incorrect. Veuillez réessayer.';
        break;
      case 'user-not-found':
        errorMessage = 'Aucun utilisateur trouvé avec cette adresse e-mail. Veuillez vous inscrire.';
        break;
      case 'wrong-password':
        errorMessage = 'Mot de passe incorrect. Veuillez réessayer.';
        break;
      default:
        errorMessage = 'Une erreur s\'est produite. Veuillez réessayer.';
    }

    ErrorUtils.showSnackBar(
      context: context,
      message: errorMessage,
      color: AppTheme.errorColor,
      icon: Icons.error_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageContainer(
      pageTitle: 'Content de vous revoir',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _emailController,
            labelText: 'Adresse email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            labelText: 'Mot de passe',
            prefixIcon: Icons.lock_outline,
            obscureText: _isPasswordObscured,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordObscured = !_isPasswordObscured;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    activeColor: AppTheme.primaryColor,
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Text('Se souvenir de moi',
                      style: TextStyle(
                          color: AppTheme.lightTextColor, letterSpacing: 0.5)),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage()));
                },
                child: const Text(
                  'Mot de passe oublié?',
                  style: TextStyle(
                      color: AppTheme.lightTextColor, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: AppTheme.elevatedButtonStyle,
            child: _isLoading
                ? const Center(
                    child: SpinKitThreeBounce(
                      color: AppTheme.primaryDarkColor,
                      size: 20.0,
                    ),
                  )
                : const Text('Connexion'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Je n\'ai pas de compte?',
                style: TextStyle(
                    color: AppTheme.lightTextColor, letterSpacing: 0.5),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignupPage(),
                  ),
                ),
                child: const Text(
                  'S\'inscrire',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
