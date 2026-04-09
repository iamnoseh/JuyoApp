import 'package:flutter/material.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class TestRunnerPage extends StatelessWidget {
  final String sessionId;

  const TestRunnerPage({
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
            title: 'Test Runner',
            subtitle: 'Session $sessionId is routed correctly and ready for question wiring.',
            icon: Icons.quiz_outlined,
          ),
        ),
      ),
    );
  }
}
