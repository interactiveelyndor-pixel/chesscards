import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'soul_doll.dart';
import 'doll_event.dart';
import 'doll_reaction.dart';
import 'doll_state.dart';

class SoulDollController extends StateNotifier<SoulDoll> {
  SoulDollController(super.state);

  final _eventController = StreamController<DollEvent>.broadcast();
  Stream<DollEvent> get events => _eventController.stream;

  DollEvent onPieceLost() {
    final int newLevel = (state.corruptionLevel + 1).clamp(0, 5);
    state = state.copyWith(
      corruptionLevel: newLevel,
      losses: state.losses + 1,
      state: DollState.values[newLevel],
    );

    final event = DollEvent(
      reaction: DollReaction.crackAppears,
      timestamp: DateTime.now(),
      soundKey: 'crack_01',
    );
    _eventController.add(event);
    return event;
  }

  DollEvent onPieceCaptured() {
    final int newLevel = (state.corruptionLevel - 1).clamp(0, 5);
    state = state.copyWith(
      corruptionLevel: newLevel,
      captures: state.captures + 1,
      state: DollState.values[newLevel],
    );

    final event = DollEvent(
      reaction: DollReaction.healPulse,
      timestamp: DateTime.now(),
      soundKey: 'heal_01',
    );
    _eventController.add(event);
    return event;
  }

  void triggerCheckReaction() {
    final reaction = state.corruptionLevel > 2 ? DollReaction.stare : DollReaction.whisper;
    _eventController.add(DollEvent(
      reaction: reaction,
      timestamp: DateTime.now(),
      soundKey: reaction == DollReaction.whisper ? 'whisper_01' : null,
    ));
  }

  void triggerCheckmateReaction() {
    state = state.copyWith(
      corruptionLevel: 5,
      state: DollState.cursed,
    );
    _eventController.add(DollEvent(
      reaction: DollReaction.scream,
      timestamp: DateTime.now(),
      soundKey: 'scream_01',
    ));
  }

  void reset() {
    state = state.copyWith(
      corruptionLevel: 0,
      state: DollState.calm,
      health: state.maxHealth,
    );
  }

  void takeDamage(int amount) {
    if (amount <= 0) return;
    final int newHealth = (state.health - amount).clamp(0, state.maxHealth);
    state = state.copyWith(health: newHealth);
    
    // Optional: trigger a reaction like a crack or scream based on damage
    final reaction = newHealth == 0 ? DollReaction.scream : DollReaction.crackAppears;
    _eventController.add(DollEvent(
      reaction: reaction,
      timestamp: DateTime.now(),
      soundKey: newHealth == 0 ? 'scream_01' : 'crack_01',
    ));
  }

  void heal(int amount) {
    if (amount <= 0) return;
    final int newHealth = (state.health + amount).clamp(0, state.maxHealth);
    state = state.copyWith(health: newHealth);

    _eventController.add(DollEvent(
      reaction: DollReaction.healPulse,
      timestamp: DateTime.now(),
      soundKey: 'heal_01',
    ));
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}

final playerDollProvider = StateNotifierProvider<SoulDollController, SoulDoll>((ref) {
  return SoulDollController(SoulDoll.initial(id: 'player_1', ownerName: 'You', isPlayerControlled: true));
});

final opponentDollProvider = StateNotifierProvider<SoulDollController, SoulDoll>((ref) {
  return SoulDollController(SoulDoll.initial(id: 'opponent_1', ownerName: 'The Visitor', isPlayerControlled: false));
});
