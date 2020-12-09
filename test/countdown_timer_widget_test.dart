import 'package:test/test.dart';

import 'package:musicscool/widgets/countdown_timer_widget.dart';

void main() {
  test('Duration Strings', () {
    var from = DateTime.parse('2020-12-06 22:21:32');
    var to = DateTime.parse('2020-12-24 18:00:00');
    var duration = DurationStrings(to.difference(from));
    expect(duration.days, '17');
    expect(duration.hours, '19');
    expect(duration.minutes, '38');
    expect(duration.seconds, '28');
  });
}