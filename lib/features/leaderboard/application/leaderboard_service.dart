import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/leaderboard_entry.dart';

final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  return LeaderboardService();
});

final topPlayersProvider = StreamProvider<List<LeaderboardEntry>>((ref) {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getTopPlayers();
});

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUid => _auth.currentUser?.uid ?? '';

  /// Returns a stream of the top 20 players sorted by souls.
  Stream<List<LeaderboardEntry>> getTopPlayers() {
    return _firestore
        .collection('leaderboard')
        .orderBy('totalSouls', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LeaderboardEntry.fromJson(doc.data());
      }).toList();
    });
  }

  /// Updates the current user's stats on the leaderboard.
  Future<void> recordMatchResult(bool isWin, int soulsEarned) async {
    if (_currentUid.isEmpty) return;

    final docRef = _firestore.collection('leaderboard').doc(_currentUid);

    try {
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        if (!docSnapshot.exists) {
          // Initialize if the user somehow doesn't exist
          transaction.set(docRef, {
            'uid': _currentUid,
            'displayName': _generateGothicName(),
            'totalSouls': soulsEarned,
            'multiplayerWins': isWin ? 1 : 0,
          });
        } else {
          // Update existing
          final currentSouls = docSnapshot.data()?['totalSouls'] as int? ?? 0;
          final currentWins = docSnapshot.data()?['multiplayerWins'] as int? ?? 0;

          transaction.update(docRef, {
            'totalSouls': currentSouls + soulsEarned,
            'multiplayerWins': isWin ? currentWins + 1 : currentWins,
          });
        }
      });
    } catch (e) {
      print('Error recording match result to leaderboard: $e');
    }
  }

  /// Ensures the current user has a leaderboard entry with a random name.
  Future<void> ensurePlayerRegistered() async {
    if (_currentUid.isEmpty) {
      await _auth.signInAnonymously();
    }
    
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('leaderboard').doc(uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set({
        'uid': uid,
        'displayName': _generateGothicName(),
        'totalSouls': 0,
        'multiplayerWins': 0,
      });
    }
  }

  String _generateGothicName() {
    const prefixes = ['Abyssal', 'Haunted', 'Crimson', 'Shadow', 'Midnight', 'Ebon', 'Phantom', 'Void', 'Skeletal'];
    const nouns = ['Reaper', 'Knight', 'Wraith', 'Fiend', 'Monarch', 'Specter', 'Terror', 'Warden', 'Soul'];
    
    final r = Random();
    final prefix = prefixes[r.nextInt(prefixes.length)];
    final noun = nouns[r.nextInt(nouns.length)];
    final number = r.nextInt(1000);

    return '$prefix $noun #$number';
  }
}
