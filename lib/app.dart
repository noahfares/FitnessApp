import 'package:flutter/material.dart';

/// Root widget.
///
/// Deliberately bare. Theming arrives with F-THM-001/002 (batch 0.3) and the
/// navigation shell with F-NAV-001/002 (batch 0.4); this exists so Phase 0
/// batch 0.1 has something that builds, runs, and can be smoke-tested in CI.
class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FitnessApp',
      debugShowCheckedModeBanner: false,
      home: _PlaceholderHome(),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Phase 0 — foundation')));
  }
}
