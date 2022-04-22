import 'package:ana_almuslim/Blocs/prayTimesBlocs/StatesBlocs.dart';
import 'package:ana_almuslim/Blocs/prayTimesBlocs/eventsBloc.dart';
import 'package:ana_almuslim/repo/repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainBloc extends Bloc<PrayTimesEvents, CardState> {
  MainBloc(IntialState intialStateAuth, RepoHttpSer mainRepository)
      : super(CardState()) {
    on<Cardpressed>(
      (events, emit) async {
        emit(LoadingState());
        // emit(GetProfileState(id: events.id!));
      },
    );

    on<startEvent>(
      (events, emit) async {
        emit(LoadingState());
        final results = await mainRepository.prayTime();
        emit(IntialState(result: results));
      },
    );
  }
}
