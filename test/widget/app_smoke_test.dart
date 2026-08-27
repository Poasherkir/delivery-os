import 'package:delivery_os/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the root widget builds without throwing', (tester) async {
    await tester.pumpWidget(const DeliveryOsApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
