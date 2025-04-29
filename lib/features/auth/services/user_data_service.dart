import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../models/user_model.dart';

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> deleteUserData(String userId) async {
    try {
      // Delete transactions
      final transactionsQuery = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();

      // Delete transactions
      for (var doc in transactionsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete photos from Firestore and Storage
      final photosQuery = await _firestore
          .collection('photos')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in photosQuery.docs) {
        final photoUrl = doc['imageUrl'] as String?;
        if (photoUrl != null) {
          try {
            await _storage.refFromURL(photoUrl).delete();
          } catch (e) {
            print('Erreur lors de la suppression de la photo: $e');
          }
        }
        batch.delete(doc.reference);
      }

      // Reset user's accounts and transactions
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'accounts': [], 'totalBalance': 0, 'hasResetData': true});

      // Commit batch operations
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors de la suppression des données utilisateur: $e');
    }
  }

  Future<void> resetUserAccounts(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'accounts': [], // Clear all accounts
        'totalBalance': 0, // Reset total balance
        'hasResetData': true // Add a flag to track reset
      });

      // Delete all transactions for this user
      final transactionsQuery = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in transactionsQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation des comptes utilisateurs: $e');
    }
  }

  // Update user profile image
  Future<UserModel> updateProfileImage(
      {required String userId, required File imageFile}) async {
    try {
      // Generate a unique filename
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}';

      // Reference to storage location
      final storageRef = _storage.ref().child('profile_images/$fileName');

      // Upload image
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update Firestore document
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({'profileImageUrl': downloadUrl});

      // Fetch updated user document
      final updatedDoc = await userRef.get();
      return UserModel.fromDocument(updatedDoc);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'image de profil: $e');
    }
  }

  // Update username
  Future<void> updateUsername(String userId, String newUsername) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'username': newUsername,
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du nom d\'utilisateur: $e');
    }
  }
}
