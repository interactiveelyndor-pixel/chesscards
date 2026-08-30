// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
  Map<String, dynamic> json,
) => _$LeaderboardEntryImpl(
  uid: json['uid'] as String,
  displayName: json['displayName'] as String,
  totalSouls: (json['totalSouls'] as num?)?.toInt() ?? 0,
  multiplayerWins: (json['multiplayerWins'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
  _$LeaderboardEntryImpl instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'displayName': instance.displayName,
  'totalSouls': instance.totalSouls,
  'multiplayerWins': instance.multiplayerWins,
};
