import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/settings_service.dart';

enum TutorialStep {
  welcome,
  modeSelect,
  difficultySelect,
  matchIntro,
  firstMove,
  spellIntro,
  completed
}

final tutorialControllerProvider = StateNotifierProvider<TutorialController, TutorialStep>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return TutorialController(settings);
});

class TutorialController extends StateNotifier<TutorialStep> {
  final SettingsService _settingsService;

  TutorialController(this._settingsService) : super(_initFromSettings(_settingsService.tutorialProgress));

  static TutorialStep _initFromSettings(int progress) {
    if (progress >= TutorialStep.completed.index) {
      return TutorialStep.completed;
    }
    return TutorialStep.values[progress];
  }

  void completeStep(TutorialStep completedStep) {
    if (completedStep.index >= state.index) {
      final nextStepIndex = completedStep.index + 1;
      final nextStep = nextStepIndex < TutorialStep.values.length
          ? TutorialStep.values[nextStepIndex]
          : TutorialStep.completed;
      
      state = nextStep;
      _settingsService.setTutorialProgress(nextStep.index);
    }
  }

  void skipTutorial() {
    state = TutorialStep.completed;
    _settingsService.setTutorialProgress(TutorialStep.completed.index);
  }

  void resetTutorial() {
    state = TutorialStep.welcome;
    _settingsService.setTutorialProgress(0);
  }
}
