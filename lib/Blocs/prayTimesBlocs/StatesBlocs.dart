import 'package:equatable/equatable.dart';

class CardState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class IntialState extends CardState {
  final String? result;
  IntialState({this.result});
}

class LoadingState extends CardState {}

class GetPrayTimeStateFailed extends CardState {}
