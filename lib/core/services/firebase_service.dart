import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Get the current user ID or null if not logged in
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // AUTHENTICATION METHODS
  
  // Sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // PROPOSAL METHODS
  
  // Save a proposal to Firestore
  Future<String> saveProposal(Map<String, dynamic> proposalData) async {
    // Add timestamp and user ID if available
    proposalData['timestamp'] = FieldValue.serverTimestamp();
    if (currentUserId != null) {
      proposalData['userId'] = currentUserId;
    }
    
    // Add to proposals collection
    final docRef = await _firestore.collection('proposals').add(proposalData);
    return docRef.id;
  }
  
  // Get proposal by ID
  Future<Map<String, dynamic>?> getProposal(String proposalId) async {
    final docSnapshot = await _firestore.collection('proposals').doc(proposalId).get();
    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>;
    }
    return null;
  }
  
  // Get recent proposals (limited to 10)
  Future<List<Map<String, dynamic>>> getRecentProposals() async {
    final querySnapshot = await _firestore
        .collection('proposals')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();
        
    return querySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();
  }

  // HISTORY METHODS
  
  // Save proposal summary to user's history
  Future<void> saveToHistory(Map<String, dynamic> summaryData) async {
    // Only save if user is logged in
    if (currentUserId == null) return;
    
    // Add timestamp
    summaryData['timestamp'] = FieldValue.serverTimestamp();
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('history')
        .add(summaryData);
  }
  
  // Get user's history
  Future<List<Map<String, dynamic>>> getUserHistory() async {
    // Return empty list if user is not logged in
    if (currentUserId == null) return [];
    
    final querySnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .get();
        
    return querySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();
  }
  
  // Delete history item
  Future<void> deleteHistoryItem(String historyId) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('history')
        .doc(historyId)
        .delete();
  }
  
  // USER PROFILE METHODS
  
  // Save user preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .set({
          'preferences': preferences,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
  
  // Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    if (currentUserId == null) return null;
    
    final docSnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get();
        
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      return data?['preferences'] as Map<String, dynamic>?;
    }
    
    return null;
  }
} 