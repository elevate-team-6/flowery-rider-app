import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class BaseCubit<State, UiEvent> extends Cubit<State> {
  BaseCubit(super.initialState);

  final StreamController<UiEvent> _eventController = StreamController();

  Stream<UiEvent> get eventStream => _eventController.stream;
  @override
  void emit(State state) {
    if (!isClosed) {
      super.emit(state);
    }
  }
  void emitEvent(UiEvent event) {
     if (isClosed || _eventController.isClosed) return;
    _eventController.add(event);
  }

  @override
  Future<void> close() async{
    await _eventController.close();
    return super.close();
  }
}
