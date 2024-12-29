abstract class HomePageEvent {}

class ChangeTabEvent extends HomePageEvent {
  final int index;

  ChangeTabEvent(this.index);
}
