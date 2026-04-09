import 'package:flutter/material.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class TestResultPage extends StatelessWidget {
  final String sessionId;

  const TestResultPage({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: EmptyState(
            title: 'Test Result',
            subtitle: 'Session $sessionId is routed correctly and ready for result wiring.',
            icon: Icons.fact_check_outlined,
          ),
        ),
      ),
    );
  }
}
