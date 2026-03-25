
class NavigationState {
  final int currentIndex;
  const NavigationState({this.currentIndex = 0});

  NavigationState copyWith({int? currentIndex}) =>
      NavigationState(currentIndex: currentIndex ?? this.currentIndex);
}