import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/tracking_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/tracking_states.dart';
import 'package:injectable/injectable.dart';

@injectable
class TrackingCubit extends BaseCubit<TrackingStates, BaseUiEvent> {
  TrackingCubit() : super(const TrackingStates());

  void doEvent(TrackingEvents event) {
    switch (event) {}
  }
}
