import 'package:flutter_bloc/flutter_bloc.dart';

// State Definition
abstract class HomePageState {}

class HomePageInitial extends HomePageState {}

class HomePageTabChanged extends HomePageState {
  final int currentIndex;
  HomePageTabChanged(this.currentIndex);
}

// Event Definition
abstract class HomePageEvent {}

class ChangeTabEvent extends HomePageEvent {
  final int index;
  ChangeTabEvent(this.index);
}

// Bloc Implementation
class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc() : super(HomePageInitial());

  @override
  Stream<HomePageState> mapEventToState(HomePageEvent event) async* {
    if (event is ChangeTabEvent) {
      yield HomePageTabChanged(
          event.index); // Emit the new state with the updated index
    }
  }
}
