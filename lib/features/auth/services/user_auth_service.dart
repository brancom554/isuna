import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
    } catch (e) {
      throw Exception('Erreur de déconnexion: $e');
    }
  }

  // Reauthenticate user before sensitive operations
  Future<bool> reauthenticateUser(String email, String password) async {
    try {
      User user = _auth.currentUser!;
      AuthCredential credentials =
          EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credentials);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("Aucun utilisateur n'est actuellement connecté.");
      }
      await user.delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du compte: $e');
    }
  }
}
