import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/provider/currency_provider.dart';
import '../../../core/utils/error_utils.dart';
import '../../../models/user_model.dart';
import '../../auth/services/user_auth_service.dart';
import '../../auth/services/user_data_service.dart';
import '../../auth/presentation/pages/auth_page.dart';
import '../widgets/account_setting_section.dart';
import '../widgets/danger_zone_section.dart';
import '../widgets/profile_header.dart';

class ProfileSettingPage extends StatefulWidget {
  final UserModel user;

  const ProfileSettingPage({super.key, required this.user});

  @override
  _ProfileSettingPageState createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends State<ProfileSettingPage>
    with SingleTickerProviderStateMixin {
  late UserModel _currentUser;
  final ImagePicker _picker = ImagePicker();
  final UserAuthenticationService _authService = UserAuthenticationService();
  final UserDataService _userDataService = UserDataService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;

    // Initialize animation controller for fade animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800), // Slightly longer duration
      vsync: this,
    );

    // Create a fade animation with more pronounced curve
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart, // More dramatic easing
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final updatedUser = await _userDataService.updateProfileImage(
            userId: _currentUser.id, imageFile: imageFile);

        Navigator.of(context).pop();

        setState(() {
          _currentUser = updatedUser;
        });
      }
    } catch (e) {
      ErrorUtils.showSnackBar(
        color: AppTheme.errorColor,
        icon: Icons.error_outline,
        context: context,
        message: 'Échec de la mise à jour de l\'image de profil: $e',
      );
      Navigator.of(context).pop();
    }
  }

  void _editUsername() {
    final TextEditingController usernameController =
        TextEditingController(text: _currentUser.username);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Modsifier nom d\'utilisateur",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: "Entrez un nouveau nom d'utilisateur",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade500),
                  ),

                  // Enabled border
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),

                  // Focused border
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryColor, width: 2),
                  ),
                  // Disabled border
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),

                  prefixIcon:
                      const Icon(Icons.person, color: AppTheme.primaryColor),
                ),
                maxLength: 30,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Annuler"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final newUsername = usernameController.text.trim();
                        if (newUsername.isNotEmpty) {
                          try {
                            await _userDataService.updateUsername(
                              widget.user.id,
                              newUsername,
                            );

                            setState(() {
                              _currentUser.username = newUsername;
                              widget.user.username = newUsername;
                            });

                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: Colors.white),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Nom d\'utilisateur mis à jour avec succès',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur lors de la mise à jour du nom d\'utilisateur: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text(
                        "Enregistrer",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  AlertDialog _buildCustomDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    Color? iconColor,
    required List<Widget> actions,
    String? additionalMessage,
    Widget? customContent,
  }) {
    return AlertDialog(
      backgroundColor: DialogTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? DialogTheme.infoColor,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: iconColor ?? DialogTheme.infoColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: DialogTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (additionalMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              additionalMessage,
              style: TextStyle(
                fontSize: 14,
                color: iconColor ?? DialogTheme.warningColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (customContent != null) ...[
            const SizedBox(height: 20),
            customContent,
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
          child: const Text("Annuler"),
        ),
        ...actions,
      ],
    );
  }

  void _signOut(BuildContext context) async {
    try {
      setState(() {
        _isSigningOut = true;
      });

      await _authService.signOut();

      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Déconnexion réussie',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ));
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _isSigningOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Échec de la déconnexion : $e',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ));
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildCustomDialog(
          context: context,
          title: "Déconnexion",
          message: "Êtes-vous sûr de vouloir vous déconnecter de Isuna?",
          icon: Icons.exit_to_app,
          actions: [
            _isSigningOut
                ? const Center(
                    child: SpinKitFadingCircle(
                      color: DialogTheme.infoColor,
                      size: 24,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _signOut(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DialogTheme.infoColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Se déconnecter"),
                  ),
          ],
        );
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    String? emailErrorMessage;
    String? passwordErrorMessage;
    bool isDeleting = false; // Add a flag to track deletion process

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildCustomDialog(
              context: context,
              title: "Supprimer le compte",
              message:
                  "Êtes-vous sûr de vouloir supprimer définitivement votre compte ?",
              icon: Icons.delete_forever,
              iconColor: DialogTheme.warningColor,
              additionalMessage:
                  "Cela supprimera toutes vos données sur tous les appareils.",
              actions: [
                isDeleting
                    ? const Center(
                        child: SpinKitFadingCircle(
                          color: DialogTheme.warningColor,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            emailErrorMessage = null;
                            passwordErrorMessage = null;
                          });

                          if (emailController.text.isEmpty) {
                            setState(() {
                              emailErrorMessage = "Email ne peut être vide.";
                            });
                          } else if (emailController.text !=
                              widget.user.email) {
                            setState(() {
                              emailErrorMessage =
                                  "Email incorrect. Veuillez réessayer.";
                            });
                          } else if (passwordController.text.isEmpty) {
                            setState(() {
                              passwordErrorMessage =
                                  "Le mot de passe ne peut être vide.";
                            });
                          } else {
                            try {
                              // Set loading state
                              setState(() {
                                isDeleting = true;
                              });

                              bool isReauthenticated =
                                  await _authService.reauthenticateUser(
                                emailController.text,
                                passwordController.text,
                              );

                              if (isReauthenticated) {
                                // Delete user data first
                                await _userDataService
                                    .deleteUserData(widget.user.id);

                                // Then delete the user account
                                await _authService.deleteUserAccount();

                                // Sign out and navigate to auth page
                                _signOut(context);

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle_outline,
                                          color: Colors.white),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Le compte a été supprimé avec succès",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.black,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ));
                              } else {
                                setState(() {
                                  isDeleting = false;
                                  passwordErrorMessage =
                                      "Mot de passe incorrect. Veuillez réessayer.";
                                });
                              }
                            } catch (e) {
                              setState(() {
                                isDeleting = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Erreur lors de la suppression du compte: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DialogTheme.warningColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Supprimer le compte"),
                      ),
              ],
              customContent: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    enabled: !isDeleting, // Disable when deleting
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Confirmer l'email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: emailErrorMessage,
                      prefixIcon:
                          const Icon(Icons.email, color: DialogTheme.infoColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    enabled: !isDeleting, // Disable when deleting
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirmer le mot de passe",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: passwordErrorMessage,
                      prefixIcon:
                          const Icon(Icons.lock, color: DialogTheme.infoColor),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
              parent: _animationController, curve: Curves.easeOut)),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 230, 236, 241),
                  Color.fromARGB(255, 220, 239, 225),
                ],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                // Profile Header with only fade effect
                ProfileHeader(
                  user: _currentUser,
                  onImageTap: _pickAndUploadImage,
                  onUsernameTap: () => _editUsername(),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Account Settings Section
                      AccountSettingsSection(
                        onPrivacyTap: () =>
                            Navigator.of(context).pushNamed('/privacy-policy'),
                        onTermsofServicesTap: () => Navigator.of(context)
                            .pushNamed('/terms-of-services'),
                        onSignOutTap: () => _confirmSignOut(context),
                        onAboutTap: () => _showAboutBottomSheet(context),
                        onCurrencyExchangeTap: () =>
                            _showCurrencyBottomSheet(context),
                      ),

                      // Danger Zone Section
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.accentColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DangerZoneSection(
                            onDeleteAccountTap: () =>
                                _confirmDeleteAccount(context),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCurrencyBottomSheet(BuildContext context) {
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: CurrencyProvider.supportedCurrencies.length,
          itemBuilder: (context, index) {
            final currencyEntry =
                CurrencyProvider.supportedCurrencies.entries.elementAt(index);
            return ListTile(
              title: Text('${currencyEntry.key} - ${currencyEntry.value.name}'),
              subtitle: Text('Symbole: ${currencyEntry.value.symbol}'),
              onTap: () {
                currencyProvider.changeCurrency(currencyEntry.key);
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

void _showAboutBottomSheet(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: 'Isuna',
    applicationVersion: '1.0.0',
    applicationIcon: const CircleAvatar(
      backgroundColor: Colors.blue,
      child: Icon(Icons.analytics_outlined, color: Colors.white),
    ),
    applicationLegalese: '© 2024 Isuna. Tous droits réservés.',
    barrierColor: Colors.black54, // Dim background
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Text(
          'Une application complète de suivi et d\'analyse financière conçue pour vous aider à gérer vos finances avec précision et facilité.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Fonctionnalités principales:',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Suivi des dépenses'),
            Text('• Planification budgétaire'),
            Text('• Perspectives financières'),
            Text('• Isuna AI'),
          ],
        ),
      ),
    ],
  );
}

class DialogTheme {
  static const Color warningColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color infoColor = AppTheme.primaryColor;
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black87;
}
