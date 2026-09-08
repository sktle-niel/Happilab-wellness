import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/errors/app_exception.dart';
import 'package:happilab/core/utils/json_reader.dart';

enum _Stage { joined, purchased }

void main() {
  group('JsonReader', () {
    final json = <String, Object?>{
      'name': 'Ivy',
      'points': 1240,
      'whole': 12.0,
      'active': true,
      'joined': '2025-03-12T00:00:00Z',
      'stage': 'purchased',
      'nested': {'code': 'FCV'},
      'items': [
        {'n': 1},
        {'n': 2},
      ],
      'missing': null,
    };

    test('reads the fields the contract promised', () {
      final reader = JsonReader.of(json);

      expect(reader.string('name'), 'Ivy');
      expect(reader.integer('points'), 1240);
      expect(reader.integer('whole'), 12);
      expect(reader.boolean('active'), isTrue);
      expect(reader.dateTime('joined'), DateTime.utc(2025, 3, 12));
      expect(reader.enumerated('stage', _Stage.values), _Stage.purchased);
      expect(reader.object('nested').string('code'), 'FCV');
      expect(reader.list('items', (i) => i.integer('n')), [1, 2]);
      expect(reader.optionalString('missing'), isNull);
      expect(reader.optionalInteger('absent'), isNull);
    });

    test('refuses every shape it was not promised', () {
      final reader = JsonReader.of(json);
      const bad = TypeMatcher<DataFormatException>();

      expect(() => reader.string('points'), throwsA(bad));
      expect(() => reader.integer('name'), throwsA(bad));
      expect(() => reader.integer('absent'), throwsA(bad));
      expect(() => reader.boolean('name'), throwsA(bad));
      expect(() => reader.dateTime('name'), throwsA(bad));
      expect(() => reader.enumerated('name', _Stage.values), throwsA(bad));
      expect(() => reader.object('items'), throwsA(bad));
      expect(() => reader.list('nested', (i) => i), throwsA(bad));
      expect(() => JsonReader.of([1, 2]), throwsA(bad));
      expect(() => JsonReader.listOf({}, (i) => i), throwsA(bad));
    });
  });
}
