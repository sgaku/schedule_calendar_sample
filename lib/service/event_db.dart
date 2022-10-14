import 'package:calendar_sample/model/event_data.dart';
import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'event_db.g.dart';

class Events extends Table {
  TextColumn get id => text()();

  DateTimeColumn get selectedDate => dateTime()();

  TextColumn get title => text()();

  BoolColumn get isAllDay => boolean()();

  DateTimeColumn get startDateTime => dateTime()();

  DateTimeColumn get endDateTime => dateTime()();

  TextColumn get comment => text()();
}

@DriftDatabase(tables: [Events])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Event>> get allEventsData => select(events).get();

  Future<int> addEvent(EventData e) {
    return into(events).insert(EventsCompanion(
      id: Value(e.id),
      selectedDate: Value(e.selectedDate),
      title: Value(e.title),
      isAllDay: Value(e.isAllDay),
      startDateTime: Value(e.startTime),
      endDateTime: Value(e.endTime),
      comment: Value(e.comment),
    ));
  }


  Future<int> updateEvent(EventData event) {
    return (update(events)..where((tbl) => tbl.id.equals(event.id)))
        .write(EventsCompanion(
      id: Value(event.id),
      selectedDate: Value(event.selectedDate),
      title: Value(event.title),
      isAllDay: Value(event.isAllDay),
      startDateTime: Value(event.startTime),
      endDateTime: Value(event.endTime),
      comment: Value(event.comment),
    ));
  }

  Future<void> deleteAllEvent(List<EventData> e) {
    return (delete(events).go());
  }

  Future<void> deleteEvent(EventData e) {
    return (delete(events)..where((tbl) => tbl.id.equals(e.id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
