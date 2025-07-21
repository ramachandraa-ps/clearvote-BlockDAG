import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Check if user is logged in
  bool get isLoggedIn {
    final user = _auth.currentUser;
    return user != null && user.uid.isNotEmpty;
  }
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email, 
    required String password,
    required String name,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user profile in Firestore
      if (userCredential.user != null) {
        await _createUserProfile(
          userId: userCredential.user!.uid,
          email: email,
          name: name,
        );
        
        // Update display name
        await userCredential.user!.updateDisplayName(name);
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email, 
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Create user profile in Firestore
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String name,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'preferences': {
        'darkMode': false,
        'notificationsEnabled': true,
      },
    });
  }
  
  // Update user profile
  Future<void> updateUserProfile({
    required String name,
    String? photoUrl,
  }) async {
    if (currentUser == null) return;
    
    // Update Firestore profile
    await _firestore.collection('users').doc(currentUserId).update({
      'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    
    // Update Firebase Auth profile
    await currentUser!.updateDisplayName(name);
    if (photoUrl != null) {
      await currentUser!.updatePhotoURL(photoUrl);
    }
  }
  
  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUserId == null) return null;
    
    final doc = await _firestore.collection('users').doc(currentUserId).get();
    return doc.data();
  }
  
  // Update last login timestamp
  Future<void> updateLastLogin() async {
    if (currentUserId == null) return;
    
    await _firestore.collection('users').doc(currentUserId).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
} 