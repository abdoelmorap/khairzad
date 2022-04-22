import 'package:equatable/equatable.dart';

class PrayTimesEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class startEvent extends PrayTimesEvents {}

class Cardpressed extends PrayTimesEvents {
  final String? id;
  Cardpressed({this.id});
}
