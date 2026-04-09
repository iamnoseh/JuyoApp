import 'package:flutter/material.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class ExamSessionPage extends StatelessWidget {
  const ExamSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: l10n.testsExamMode, subtitle: l10n.commonSoon),
              const SizedBox(height: 16),
              EmptyState(
                title: l10n.testsExamMode,
                subtitle: 'Focused exam flow scaffold is ready for the next API slice.',
                icon: Icons.school_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
