import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class MainLayoutCubit extends Cubit<int> {
  MainLayoutCubit() : super(0);

  void changeIndex(int index) {
    emit(index);
  }
}
