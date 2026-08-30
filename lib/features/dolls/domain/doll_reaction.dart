enum DollReaction {
  blink,
  twitch,
  neckTilt,
  whisper,
  crackAppears,
  stare,
  laugh,
  scream,
  healPulse,
  cursePulse;

  String get subtitle {
    switch (this) {
      case DollReaction.blink: return '*blinks*';
      case DollReaction.twitch: return '*twitches violently*';
      case DollReaction.neckTilt: return '*neck snaps to the side*';
      case DollReaction.whisper: return '"...they are coming..."';
      case DollReaction.crackAppears: return '*a sickening crack echoes*';
      case DollReaction.stare: return 'It stares directly into your soul.';
      case DollReaction.laugh: return '*childish giggling echoes in the dark*';
      case DollReaction.scream: return '*a deafening, silent scream*';
      case DollReaction.healPulse: return '*a warm light knits the porcelain*';
      case DollReaction.cursePulse: return '*the darkness deepens*';
    }
  }
}
