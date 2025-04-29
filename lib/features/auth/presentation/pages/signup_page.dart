import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/error_utils.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/authpage_container.dart';
import 'signin_page.dart.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await userCredential.user?.sendEmailVerification();
      _showVerificationMessage();
    } on FirebaseAuthException catch (e) {
      _handleSignupError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateInputs() {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ErrorUtils.showSnackBar(
          context: context,
          message: 'Veuillez remplir tous les champs',
          color: AppTheme.errorColor,
          icon: Icons.error_outline);
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ErrorUtils.showSnackBar(
          context: context,
          message: 'les mots de passe ne correspondent pas',
          color: AppTheme.errorColor,
          icon: Icons.error_outline);
      return false;
    }

    if (!_agreeToTerms) {
      ErrorUtils.showSnackBar(
          context: context,
          message: 'Veuillez accepter les termes et conditions',
          color: AppTheme.errorColor,
          icon: Icons.error_outline);
      return false;
    }

    return true;
  }

  void _handleSignupError(FirebaseAuthException e) {
    String errorMessage = ErrorUtils.getAuthErrorMessage(e.code);
    ErrorUtils.showSnackBar(
        context: context,
        message: errorMessage,
        color: AppTheme.errorColor,
        icon: Icons.error_outline);
  }

  void _showVerificationMessage() {
    // Show verification message using SnackBar
    ErrorUtils.showSnackBar(
      context: context,
      color: AppTheme.successColor,
      icon: Icons.check_circle_outline,
      message: 'Lien de vérification envoyé à votre e-mail',
      onVisible: () {
        // Navigate to login page after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SigninPage()),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageContainer(
      pageTitle: 'Créer un compte',
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
          AuthTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirmer mot de passe',
            prefixIcon: Icons.lock_outline,
            obscureText: _isConfirmPasswordObscured,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordObscured
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                activeColor: AppTheme.primaryColor,
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
              ),
              const Text(
                'Je reconnais avoir lu les termes et conditions',
                style: TextStyle(color: AppTheme.lightTextColor),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _signup,
            style: AppTheme.elevatedButtonStyle,
            child: _isLoading
                ? const Center(
                    child: SpinKitThreeBounce(
                      color: AppTheme.primaryDarkColor,
                      size: 20.0,
                    ),
                  )
                : const Text('S\'inscrire'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Vous avez déjà un compte?',
                style: TextStyle(
                    color: AppTheme.lightTextColor, letterSpacing: 0.5),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SigninPage(),
                  ),
                ),
                child: const Text(
                  'Connexion',
                  style: TextStyle(
                      color: AppTheme.lightTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
