class StoreState {
  final int playerLevel;
  final int playerXp;
  final int soulFragments;
  final int goldCoins;
  final List<String> ownedItemIds;
  final String? equippedDollId;
  final String? equippedBoardId;
  final int dailyAdSoulsClaimed;
  final bool isLoading;

  const StoreState({
    required this.playerLevel,
    required this.playerXp,
    required this.soulFragments,
    required this.goldCoins,
    required this.ownedItemIds,
    this.equippedDollId,
    this.equippedBoardId,
    this.dailyAdSoulsClaimed = 0,
    this.isLoading = false,
  });

  factory StoreState.initial() {
    return const StoreState(
      playerLevel: 1,
      playerXp: 0,
      soulFragments: 5000, // Initial test balance
      goldCoins: 1000,     // Initial test balance
      ownedItemIds: [],
      dailyAdSoulsClaimed: 0,
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
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
