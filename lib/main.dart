import 'package:flutter/material.dart';

void main() {
  runApp(const DeliveryOsApp());
}

/// Root widget of Delivery OS.
///
/// Deliberately minimal. Theming arrives in M0-04, localization in M0-05 and
/// routing in M0-06; until then this renders nothing user-facing, so there are
/// no hardcoded strings to localize (invariant 10).
class DeliveryOsApp extends StatelessWidget {
  const DeliveryOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: SizedBox.shrink()));
  }
}
