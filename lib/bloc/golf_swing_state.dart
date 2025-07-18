import 'package:hm_golf/models/golf_swing.dart';

abstract class GolfSwingState {
  const GolfSwingState();
}

class GolfSwingInitial extends GolfSwingState {}

class GolfSwingLoading extends GolfSwingState {}

class GolfSwingLoaded extends GolfSwingState {
  final List<GolfSwing> swings;
  final GolfSwing? selectedSwing;
  final int currentIndex;

  const GolfSwingLoaded({
    required this.swings,
    this.selectedSwing,
    this.currentIndex = 0,
  });

  bool get canGoPrevious => currentIndex > 0;

  bool get canGoNext => currentIndex < swings.length - 1;

  GolfSwingLoaded copyWith({
    List<GolfSwing>? swings,
    GolfSwing? selectedSwing,
    int? currentIndex,
  }) {
    return GolfSwingLoaded(
      swings: swings ?? this.swings,
      selectedSwing: selectedSwing ?? this.selectedSwing,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

}

class GolfSwingError extends GolfSwingState {
  final String message;

  const GolfSwingError(this.message);
}

class GolfSwingEmpty extends GolfSwingState {
  const GolfSwingEmpty();
}
