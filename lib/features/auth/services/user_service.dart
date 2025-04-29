import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../models/account_model.dart';
import '../../../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserModel?> getUserById(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      return UserModel.fromDocument(userDoc);
    }
    return null;
  }

  Future<void> updateUsername(String userId, String username) async {
    await _firestore.collection('users').doc(userId).update({
      'username': username,
    });
  }

  Future<void> addAccount(String userId, Account account) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    await userDoc.update({
      'accounts': FieldValue.arrayUnion([account.toMap()]),
    });
  }

  Future<void> updateAccountBalance(String userId, Account account) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    DocumentSnapshot snapshot = await userDoc.get();
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

    List<dynamic> accounts = userData['accounts'] ?? [];

    for (int i = 0; i < accounts.length; i++) {
      if (accounts[i]['name'] == account.name) {
        accounts[i]['balance'] = account.balance;
        break;
      }
    }

    await userDoc.update({
      'accounts': accounts,
    });
  }

  Future removeProfileImage(String userId) async {
    try {
      final ListResult result =
          await _storage.ref().child('profile_images').listAll();

      final matchingFiles =
          result.items.where((ref) => ref.name.startsWith('profile_$userId'));

      if (matchingFiles.isNotEmpty) {
        await Future.wait(matchingFiles.map((ref) => ref.delete()));
      }

      // Update Firestore to remove the URL
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': FieldValue.delete(),
      });

      // Fetch the updated user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return UserModel.fromDocument(userDoc);
    } on FirebaseException catch (e) {
      print('Erreur Firebase lors de la suppression de l\'image de profil: ${e.code} - ${e.message}');
      throw Exception('Échec de la suppression de l\'image de profil: ${e.message}');
    } catch (e) {
      print('Erreur inattendue lors de la suppression de l\'image de profil: $e');
      rethrow;
    }
  }

  Future<bool> checkAccountHasTransactions(
      String userId, String accountName) async {
    try {
      // Query transactions collection for transactions with the specific account
      QuerySnapshot transactionsQuery = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('account', isEqualTo: accountName)
          .limit(1)
          .get();

      // Return true if there are any transactions associated with the account
      return transactionsQuery.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification des transactions du compte: $e');
      throw Exception('Échec de la vérification des transactions du compte');
    }
  }

  Future<void> deleteAccount(String userId, String accountName) async {
    try {
      // Start a batch operation for atomic writes
      WriteBatch batch = _firestore.batch();

      // Get the user document reference
      DocumentReference userDoc = _firestore.collection('users').doc(userId);

      // Get the current user data
      DocumentSnapshot snapshot = await userDoc.get();
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

      // Get the current accounts list
      List<dynamic> accounts = userData['accounts'] ?? [];

      // Remove the account with the specified name
      accounts.removeWhere((account) => account['name'] == accountName);

      // Add user document update to the batch
      batch.update(userDoc, {
        'accounts': accounts,
      });

      // Query and delete all transactions for this account
      QuerySnapshot transactionsQuery = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('account', isEqualTo: accountName)
          .get();

      // Add transactions deletion to the batch
      for (var doc in transactionsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch operation
      await batch.commit();
    } catch (e) {
      print('Erreur lors de la suppression du compte et de ses transactions: $e');
      throw Exception('Échec de la suppression du compte et de ses transactions');
    }
  }

  Future<void> renameAccount(
      String userId, String oldName, String newName) async {
    try {
      // Get the user document reference
      DocumentReference userDoc = _firestore.collection('users').doc(userId);

      // Get the current user data
      DocumentSnapshot snapshot = await userDoc.get();
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

      // Get the current accounts list
      List<dynamic> accounts = userData['accounts'] ?? [];

      // Find the account to rename
      for (int i = 0; i < accounts.length; i++) {
        if (accounts[i]['name'] == oldName) {
          // Update the account name
          accounts[i]['name'] = newName;
          break;
        }
      }

      // Update the user document with the modified accounts list
      await userDoc.update({
        'accounts': accounts,
      });

      // Update all transactions with the old account name to the new account name
      await _updateTransactionAccountName(userId, oldName, newName);
    } catch (e) {
      print('Erreur lors du changement de nom du compte: $e');
      throw Exception('Impossible de renommer le compte');
    }
  }

// Helper method to update account name in transactions
  Future<void> _updateTransactionAccountName(
      String userId, String oldName, String newName) async {
    try {
      // Query transactions with the old account name
      QuerySnapshot transactionsQuery = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('account', isEqualTo: oldName)
          .get();

      // Batch update to modify account names in transactions
      WriteBatch batch = _firestore.batch();

      for (var doc in transactionsQuery.docs) {
        batch.update(doc.reference, {'account': newName});
      }

      // Commit the batch update
      await batch.commit();
    } catch (e) {
      print('Erreur lors de la mise à jour des noms de comptes de transaction: $e');
      throw Exception('Échec de la mise à jour des noms de compte de transaction');
    }
  }

  // Future updateProfileImage({
  //   required String userId,
  //   required File imageFile,
  // }) async {
  //   try {
  //     // Validate file
  //     if (!imageFile.existsSync() || imageFile.lengthSync() == 0) {
  //       throw Exception('Invalid image file');
  //     }

  //     // Compress image before upload
  //     final compressedFile = await compressImage(imageFile);

  //     // Generate unique filename
  //     final filename =
  //         'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

  //     // Ensure storage reference exists
  //     final storageRef = _storage.ref().child('profile_images/$filename');

  //     // Upload file directly with await
  //     final TaskSnapshot snapshot = await storageRef.putFile(
  //       compressedFile,
  //       SettableMetadata(contentType: 'image/jpeg'),
  //     );

  //     // Get the download URL after successful upload
  //     final downloadURL = await snapshot.ref.getDownloadURL();

  //     // Update Firestore
  //     await _firestore.collection('users').doc(userId).update({
  //       'profileImageUrl': downloadURL,
  //     });

  //     // Fetch and return updated user
  //     final userDoc = await _firestore.collection('users').doc(userId).get();
  //     return UserModel.fromDocument(userDoc);
  //   } on FirebaseException catch (e) {
  //     print('Firebase upload error: ${e.code} - ${e.message}');
  //     throw Exception('Image upload failed: ${e.message}');
  //   } catch (e) {
  //     print('Unexpected profile image upload error: $e');
  //     throw Exception('Failed to update profile image');
  //   }
  // }

  // Add image compression method
  // Future<File> compressImage(File file) async {
  //   try {
  //     // Compress the image and return the result or the original file if compression fails
  //     final XFile? result = await FlutterImageCompress.compressAndGetFile(
  //       file.absolute.path,
  //       '${file.path}_compressed.jpg', // Create a new file for compressed image
  //       quality: 70,
  //       minWidth: 800,
  //       minHeight: 800,
  //     );

  //     // If compression is successful, return the compressed file
  //     if (result != null) {
  //       return File(result.path); // Convert XFile to File
  //     } else {
  //       // Return the original file if compression fails
  //       return file;
  //     }
  //   } catch (e) {
  //     print('Image compression error: $e');
  //     // Return the original file in case of error
  //     return file;
  //   }
  // }
}
