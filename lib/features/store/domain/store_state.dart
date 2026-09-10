class StoreState {
  final int playerLevel;
  final int playerXp;
  final int soulFragments;
  final int goldCoins;
  final List<String> ownedItemIds;
  final String? equippedDollId;
  final String? equippedBoardId;
  final int dailyAdSoulsClaimed;
  final int dailyAdGoldClaimed;
  final bool isLoading;

  const StoreState({
    required this.playerLevel,
    required this.playerXp,
    required this.soulFragments,
    required this.goldCoins,
    required this.ownedItemIds,
    this.equippedDollId,
    this.equippedBoardId = 'board_crimson_crypt',
    this.dailyAdSoulsClaimed = 0,
    this.dailyAdGoldClaimed = 0,
    this.isLoading = false,
  });

  factory StoreState.initial() {
    return const StoreState(
      playerLevel: 1,
      playerXp: 0,
      soulFragments: 1500, // Balanced initial balance
      goldCoins: 2000,     // Balanced initial balance
      ownedItemIds: ['board_crimson_crypt'],
      equippedBoardId: 'board_crimson_crypt',
      dailyAdSoulsClaimed: 0,
      dailyAdGoldClaimed: 0,
    );
  }

  StoreState copyWith({
    int? playerLevel,
    int? playerXp,
    int? soulFragments,
    int? goldCoins,
    List<String>? ownedItemIds,
    String? equippedDollId,
    String? equippedBoardId,
    int? dailyAdSoulsClaimed,
    int? dailyAdGoldClaimed,
    bool? isLoading,
  }) {
    return StoreState(
      playerLevel: playerLevel ?? this.playerLevel,
      playerXp: playerXp ?? this.playerXp,
      soulFragments: soulFragments ?? this.soulFragments,
      goldCoins: goldCoins ?? this.goldCoins,
      ownedItemIds: ownedItemIds ?? this.ownedItemIds,
      equippedDollId: equippedDollId ?? this.equippedDollId,
      equippedBoardId: equippedBoardId ?? this.equippedBoardId,
      dailyAdSoulsClaimed: dailyAdSoulsClaimed ?? this.dailyAdSoulsClaimed,
      dailyAdGoldClaimed: dailyAdGoldClaimed ?? this.dailyAdGoldClaimed,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
