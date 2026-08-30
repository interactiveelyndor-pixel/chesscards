import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/board/domain/board_position.dart';
import '../../shared/enums/piece_type.dart';

final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

class NetworkService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get userId => _auth.currentUser?.uid;
  String? currentMatchId;
  bool isPlayer1 = false;
  StreamSubscription? _matchSubscription;
  StreamSubscription? _actionSubscription;

  // Listeners for game events
  void Function(Map<String, dynamic> actionData)? onActionReceived;
  void Function(String opponentId)? onMatchStart;

  Timer? _heartbeatTimer;
  void Function()? onOpponentDisconnected;

  Future<void> signInAnonymously() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  Future<void> findMatch() async {
    await signInAnonymously();
    final uid = userId!;

    bool joined = false;
    int retries = 0;

    while (!joined && retries < 3) {
      final snapshot = await _firestore
          .collection('matches')
          .where('status', isEqualTo: 'waiting')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final matchDoc = snapshot.docs.first;
        if (matchDoc['player1'] != uid) {
          try {
            await _firestore.runTransaction((transaction) async {
              final freshSnap = await transaction.get(matchDoc.reference);
              if (!freshSnap.exists || freshSnap.data()?['status'] != 'waiting') {
                throw Exception('Match unavailable');
              }
              transaction.update(matchDoc.reference, {
                'player2': uid,
                'status': 'playing',
                'player2Heartbeat': FieldValue.serverTimestamp(),
              });
            });
            isPlayer1 = false;
            currentMatchId = matchDoc.id;
            _listenToMatch();
            _startHeartbeat();
            if (onMatchStart != null) onMatchStart!(matchDoc['player1']);
            joined = true;
          } catch (e) {
            retries++;
          }
        } else {
          break; // It's our own waiting match
        }
      } else {
        break; // No waiting match
      }
    }

    if (joined) return;

    // Create new match
    final newMatch = await _firestore.collection('matches').add({
      'player1': uid,
      'player2': null,
      'status': 'waiting',
      'player1Heartbeat': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    isPlayer1 = true;
    currentMatchId = newMatch.id;
    _listenToMatch();
    _startHeartbeat();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (currentMatchId == null) return;
      final field = isPlayer1 ? 'player1Heartbeat' : 'player2Heartbeat';
      _firestore.collection('matches').doc(currentMatchId).update({
        field: FieldValue.serverTimestamp(),
      }).catchError((e) => null);
    });
  }

  void _listenToMatch() {
    _matchSubscription?.cancel();
    _actionSubscription?.cancel();

    if (currentMatchId == null) return;

    _matchSubscription = _firestore
        .collection('matches')
        .doc(currentMatchId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;
      
      final data = doc.data()!;
      if (data['status'] == 'playing' && data['player2'] != null) {
        final opponent = data['player1'] == userId ? data['player2'] : data['player1'];
        if (onMatchStart != null && isPlayer1 && data['player2Heartbeat'] != null) {
           // We're player 1, and someone just joined
           onMatchStart!(opponent);
        }

        // Check heartbeat
        final opponentField = isPlayer1 ? 'player2Heartbeat' : 'player1Heartbeat';
        final Timestamp? oppHeartbeat = data[opponentField];
        if (oppHeartbeat != null) {
           final diff = DateTime.now().difference(oppHeartbeat.toDate());
           if (diff.inSeconds > 15) {
             if (onOpponentDisconnected != null) onOpponentDisconnected!();
           }
        }
      } else if (data['status'] == 'abandoned') {
        if (onOpponentDisconnected != null) onOpponentDisconnected!();
      }
    });

    _actionSubscription = _firestore
        .collection('matches')
        .doc(currentMatchId)
        .collection('actions')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null && data['senderId'] != userId) {
            final int seq = data['seq'] ?? 0;
            if (seq > 0) {
              _actionQueue[seq] = data;
              _processActionQueue();
            } else {
              // Fallback for actions without seq (backward compatibility or testing)
              if (onActionReceived != null) onActionReceived!(data);
            }
          }
        }
      }
    });
  }

  int _localSequence = 0;
  int _remoteSequence = 0;
  final Map<int, Map<String, dynamic>> _actionQueue = {};

  Future<void> sendMoveAction(BoardPosition from, BoardPosition to, PieceType? promotion) async {
    if (currentMatchId == null) return;
    _localSequence++;
    await _firestore
        .collection('matches')
        .doc(currentMatchId)
        .collection('actions')
        .add({
      'senderId': userId,
      'type': 'move',
      'seq': _localSequence,
      'from': {'row': from.row, 'col': from.col},
      'to': {'row': to.row, 'col': to.col},
      'promotion': promotion?.name,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendCardAction(String cardId, BoardPosition? primary, BoardPosition? secondary) async {
    if (currentMatchId == null) return;
    _localSequence++;
    await _firestore
        .collection('matches')
        .doc(currentMatchId)
        .collection('actions')
        .add({
      'senderId': userId,
      'type': 'card',
      'seq': _localSequence,
      'cardId': cardId,
      'primary': primary != null ? {'row': primary.row, 'col': primary.col} : null,
      'secondary': secondary != null ? {'row': secondary.row, 'col': secondary.col} : null,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  Future<void> sendEndTurnAction() async {
    if (currentMatchId == null) return;
    _localSequence++;
    await _firestore
        .collection('matches')
        .doc(currentMatchId)
        .collection('actions')
        .add({
      'senderId': userId,
      'type': 'endTurn',
      'seq': _localSequence,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _processActionQueue() {
    while (_actionQueue.containsKey(_remoteSequence + 1)) {
      _remoteSequence++;
      final action = _actionQueue.remove(_remoteSequence)!;
      if (onActionReceived != null) onActionReceived!(action);
    }
  }

  Future<void> leaveMatch() async {
    if (currentMatchId != null) {
      await _firestore.collection('matches').doc(currentMatchId).update({
        'status': 'abandoned'
      }).catchError((e) => null);
    }
    _matchSubscription?.cancel();
    _actionSubscription?.cancel();
    _heartbeatTimer?.cancel();
    currentMatchId = null;
    _localSequence = 0;
    _remoteSequence = 0;
    _actionQueue.clear();
  }
}
