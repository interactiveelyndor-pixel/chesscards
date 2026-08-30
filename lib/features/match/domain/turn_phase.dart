enum TurnPhase {
  move,
  card,
  waiting,
  gameOver;

  String get displayName {
    switch (this) {
      case TurnPhase.move: return 'Move Phase';
      case TurnPhase.card: return 'Card Phase';
      case TurnPhase.waiting: return 'Waiting...';
      case TurnPhase.gameOver: return 'Game Over';
    }
  }
}
