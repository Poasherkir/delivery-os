import 'package:delivery_os/domain/entities/company.dart';
import 'package:test/test.dart';

Company aCompany({
  String id = 'c1',
  String name = 'Yalidine',
  int version = 1,
  String? phone,
}) => Company(id: id, name: name, version: version, contactPhone: phone);

void main() {
  group('identity is the id and the version together', () {
    test('the same row at the same version is the same company', () {
      expect(aCompany(), aCompany());
    });

    test('a different row is not', () {
      expect(aCompany(id: 'c1'), isNot(aCompany(id: 'c2')));
    });

    test('and the same row after an edit is not', () {
      // Deliberate. A widget holding a stale company must rebuild when the row
      // moves under it, and a value type that called the two equal would let a
      // list keep rendering the old name.
      expect(aCompany(version: 1), isNot(aCompany(version: 2)));
    });

    test('a company is not equal to something else entirely', () {
      expect(aCompany(), isNot('Yalidine'));
    });

    test('hashCode agrees with ==', () {
      // An inconsistent hashCode never throws; it just loses a lookup in a map
      // that demonstrably contains the key.
      expect(aCompany().hashCode, aCompany().hashCode);
      expect(
        aCompany(version: 1).hashCode,
        isNot(aCompany(version: 2).hashCode),
      );
    });

    test('and survives a set', () {
      expect(<Company>{aCompany(), aCompany()}, hasLength(1));
      expect(<Company>{aCompany(id: 'c1'), aCompany(id: 'c2')}, hasLength(2));
    });
  });

  group('toString', () {
    test('names the row so a log line can be traced back', () {
      expect(aCompany().toString(), contains('c1'));
      expect(aCompany().toString(), contains('v1'));
      expect(aCompany().toString(), contains('Yalidine'));
    });

    test('and leaves the contact number out', () {
      // A company is a business, not a household, so the name is safe. The
      // number is left out anyway: it costs nothing, and it is the one field
      // here that could turn out to be somebody's personal mobile.
      final String rendered = aCompany(phone: '0770112233').toString();

      expect(rendered, isNot(contains('0770112233')));
      expect(rendered, isNot(contains('770112233')));
    });
  });

  test('phone and notes are optional', () {
    // The only thing a driver has to type is a name.
    expect(aCompany().contactPhone, isNull);
    expect(aCompany().notes, isNull);
  });
}
