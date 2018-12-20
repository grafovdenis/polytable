import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:polytable/data/CalendarData.dart';

void main() {
  test("Data get test", () async {
    CalendarData data = CalendarData("33531/2");
    List<Day> days = await data.load();
    expect(true, days != null);
  });
}