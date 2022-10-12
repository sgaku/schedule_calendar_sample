import 'package:calendar_sample/common/main.dart';
import 'package:calendar_sample/repository/event_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEventDataNotifier extends StateNotifier<AddEventDataState> {
  AddEventDataNotifier() : super((const AddEventDataState(addEventData: null)));



  ///値の追加
  addEvents(EventData data) {
    state = state.copyWith(addEventData: data);
    //TODO:driftにデータを追加
    dataBase.addEvent(data);
  }
}
