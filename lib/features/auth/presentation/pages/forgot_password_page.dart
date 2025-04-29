import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/error_utils.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/authpage_container.dart';
import 'signin_page.dart.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ErrorUtils.showSnackBar(
          context: context,
          message: 'L\'e-mail ne peut pas être vide',
          color: AppTheme.errorColor,
          icon: Icons.error_outline);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

      ErrorUtils.showSnackBar(
          context: context,
          message: 'Lien de réinitialisation du mot de passe envoyé à votre adresse e-mail',
          color: AppTheme.successColor,
          icon: Icons.check_circle_outline);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SigninPage()),
      );
    } on FirebaseAuthException catch (e) {
      ErrorUtils.showSnackBar(
          context: context,
          message: ErrorUtils.getAuthErrorMessage(e.code),
          color: AppTheme.errorColor,
          icon: Icons.error_outline);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageContainer(
      pageTitle: 'Mot de passe oublié?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Entrez votre adresse e-mail pour recevoir un lien de réinitialisation de mot de passe.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.lightTextColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          AuthTextField(
            controller: _emailController,
            labelText: 'Adresse email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
            style: AppTheme.elevatedButtonStyle,
            child: _isLoading
                ? const Center(
                    child: SpinKitThreeBounce(
                      color: AppTheme.primaryDarkColor,
                      size: 20.0,
                    ),
                  )
                : const Text('Réinitialiser le mot de passe'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Mémorisez votre mot de passe?',
                style: TextStyle(
                  color: AppTheme.lightTextColor,
                  letterSpacing: 0.5,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Retour à la connexion',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
