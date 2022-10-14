import 'package:calendar_sample/view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../common/schedule_config_cell.dart';
import 'add_event_state_notifier.dart';
import '../model/event_data.dart';

///イベントを追加する際に使うプロバイダー
final eventStateProvider =
    StateNotifierProvider.autoDispose<AddEventStateNotifier, AddEventDataState>(
        (ref) {
  return AddEventStateNotifier(ref);
});

class AddScheduleView extends ConsumerStatefulWidget {
  const AddScheduleView({super.key});

  @override
  ScheduleDetailState createState() => ScheduleDetailState();
}

class ScheduleDetailState extends ConsumerState<AddScheduleView> {
  late FocusNode myFocusNode;

  ///代入するデータのパラメータ（stateNotifierに入れるための変数）
  String title = "";
  bool isAllDay = false;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  String comment = "";

  DateFormat dateFormatForDateAndTime = DateFormat('yyyy-MM-dd HH:mm');
  DateFormat dateFormatForDate = DateFormat('yyyy-MM-dd');
  var uuid = Uuid();

  @override
  void initState() {
    myFocusNode = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue = ref.watch(selectedDayProvider);
    final fetchDataBaseValue = ref.watch(fetchDataBaseProvider);

    return Focus(
      focusNode: myFocusNode,
      child: GestureDetector(
        onTap: myFocusNode.requestFocus,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color.fromARGB(255, 240, 238, 237),
          appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed:

                        ///タイトルとコメントに何も入力されていなかったら（デフォルトで""が入っている）非活性に
                        title.isEmpty || comment.isEmpty
                            ? null
                            : () async {
                                ///EventDataクラスで状態管理しているため、そのクラスに格納する形でdriftに追加
                                final data = EventData(
                                    id: uuid.v1(),
                                    selectedDate: selectedValue,
                                    title: title,
                                    isAllDay: isAllDay,
                                    startTime: startTime,
                                    endTime: endTime,
                                    comment: comment);
                                ref
                                    .read(eventStateProvider.notifier)
                                    .addEvents(data);

                                ///eventLoaderに表示するデータを更新
                                await fetchDataBaseValue.fetchDataList();
                                Navigator.popUntil(
                                    context, ModalRoute.withName("/"));
                              },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.white;
                          }
                          return Colors.white;
                        },
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return const Color(0xFFAEAEAE);
                          }
                          return Colors.black;
                        },
                      ),
                    ),
                    child: const Text("保存"),
                  ),
                )
              ],
              title: const Text("予定の追加")),
          body: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    initialValue: "",
                    autofocus: true,
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "タイトルを入力してください",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      setState(() {
                        title = text;
                      });
                    },
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(
                        top: 12, bottom: 1, left: 12, right: 12),
                    child: ScheduleConfigCell(
                        leading: const Text("開始"),
                        trailing: Switch(
                            value: isAllDay,
                            onChanged: (value) {
                              setState(() {
                                isAllDay = value;
                              });
                            }))
                    // const Text("開始"),

                    ),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                    child: ScheduleConfigCell(
                        leading: const Text("開始"),
                        trailing: TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.black),
                          child: Text(

                              ///終日だったら日付のみ、そうでなければ日付と時間を表示
                              isAllDay
                                  ? dateFormatForDate.format(startTime)
                                  : dateFormatForDateAndTime.format(startTime)),
                          onPressed: () {
                            int initialMinute = startTime.minute;
                            if (initialMinute % 15 != 0) {
                              initialMinute =
                                  initialMinute - initialMinute % 15 + 15;
                            }
                            _showCupertinoPicker(
                              CupertinoDatePicker(
                                minuteInterval: 15,
                                initialDateTime: DateTime(
                                    startTime.year,
                                    startTime.month,
                                    startTime.day,
                                    startTime.hour,
                                    initialMinute),
                                mode:

                                    ///終日だったら日付のみ、そうでなければ日付と時間を表示
                                    isAllDay
                                        ? CupertinoDatePickerMode.date
                                        : CupertinoDatePickerMode.dateAndTime,
                                use24hFormat: true,
                                onDateTimeChanged: (dateTime) {
                                  setState(() {
                                    startTime = dateTime;
                                  });
                                },
                              ),
                            );
                          },
                        ))
                    // const Text("開始"),

                    ),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                    child: ScheduleConfigCell(
                        leading: const Text("開始"),
                        trailing: TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.black),
                          child: Text(

                              ///終日だったら日付のみ、そうでなければ日付と時間を表示
                              isAllDay
                                  ? dateFormatForDate.format(endTime)
                                  : dateFormatForDateAndTime.format(endTime)),
                          onPressed: () {
                            int initialMinute = endTime.minute;
                            if (initialMinute % 15 != 0) {
                              initialMinute =
                                  initialMinute - initialMinute % 15 + 15;
                            }
                            _showCupertinoPicker(
                              CupertinoDatePicker(
                                minuteInterval: 15,
                                initialDateTime: DateTime(
                                    endTime.year,
                                    endTime.month,
                                    endTime.day,
                                    endTime.hour,
                                    (initialMinute)),
                                mode:

                                    ///終日だったら日付のみ、そうでなければ日付と時間を表示
                                    isAllDay
                                        ? CupertinoDatePickerMode.date
                                        : CupertinoDatePickerMode.dateAndTime,
                                use24hFormat: true,
                                onDateTimeChanged: (dateTime) {
                                  setState(() {
                                    endTime = dateTime;
                                  });
                                },
                              ),
                            );
                          },
                        ))
                    // const Text("開始"),

                    ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    initialValue: "",
                    maxLines: null,
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "コメントを入力してください",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      setState(() {
                        comment = text;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCupertinoPicker(Widget child) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("キャンセル")),
                  TextButton(
                      onPressed: () {
                        final isEndTimeBefore = endTime.isBefore(startTime);
                        final isEqual = endTime.microsecondsSinceEpoch ==
                            startTime.millisecondsSinceEpoch;

                        switch (isAllDay) {
                          case true:
                            if (isEndTimeBefore || isEqual) {
                              setState(() {
                                endTime = startTime;
                              });
                            }
                            break;
                          case false:
                            if (isEndTimeBefore || isEqual) {
                              setState(() {
                                endTime =
                                    startTime.add(const Duration(hours: 1));
                              });
                            }
                            break;
                        }

                        Navigator.pop(context);
                      },
                      child: const Text("完了")),
                ],
              ),
            ),
            Expanded(child: SafeArea(top: false, child: child)),
          ],
        ),
      ),
    );
  }
}