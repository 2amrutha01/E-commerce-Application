abstract class HomePageState {}

class HomePageInitial extends HomePageState {}

class HomePageTabChanged extends HomePageState {
  final int currentIndex;

  HomePageTabChanged(this.currentIndex);
}
