import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/directional_icons.dart';
import 'documents.dart';
import 'widgets/contact_sheet.dart';

/// Opens [document] as a page of its own: the Help centre as questions to
/// open one at a time, the terms and the policy as text to read through.
Future<void> openDocument(BuildContext context, Document document) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DocumentPage(document: document)),
    );

class DocumentPage extends StatelessWidget {
  const DocumentPage({super.key, required this.document});

  final Document document;

  /// The Help centre is the one made of questions.
  bool get _questions => document.updated == null;

  @override
  Widget build(BuildContext context) {
    final updated = document.updated;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                const _Header(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          context.tr(document.title),
                          style: AppText.title.copyWith(fontSize: 30),
                        ),
                      ),
                      if (updated != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          context.tr('Last updated {date}', {
                            'date': context.l10n.date(
                              DateTime(
                                updated.year,
                                updated.month,
                                updated.day,
                              ),
                            ),
                          }),
                          style: AppText.figure,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(context.tr(document.intro), style: _paragraph),
                      const SizedBox(height: 20),
                      if (_questions) ...[
                        for (final (i, section) in document.sections.indexed)
                          _Question(section: section, divider: i > 0),
                        const SizedBox(height: 32),
                        Text(
                          context.tr('Still need help?'),
                          style: AppText.section,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(
                            'Write to us about anything the app couldn’t help with.',
                          ),
                          style: AppText.secondary,
                        ),
                        const SizedBox(height: 16),
                        ShadButton.outline(
                          size: ShadButtonSize.lg,
                          textStyle: AppText.button,
                          leading: const Icon(LucideIcons.mail, size: 18),
                          onPressed: () => showContactSheet(context),
                          child: Text(context.tr('Contact support')),
                        ),
                      ] else
                        for (final section in document.sections)
                          _Section(section: section),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle get _paragraph => AppText.body.copyWith(fontSize: 15.5);

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 16, 6),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: ShadIconButton.ghost(
          width: 44,
          height: 44,
          iconSize: 22,
          icon: Icon(context.backChevron, semanticLabel: context.tr('Back')),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
    );
  }
}

/// A part of the terms or the policy, read straight through.
class _Section extends StatelessWidget {
  const _Section({required this.section});

  final DocumentSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(context.tr(section.heading), style: AppText.section),
          ),
          const SizedBox(height: 8),
          for (final paragraph in section.paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(context.tr(paragraph), style: _paragraph),
            ),
        ],
      ),
    );
  }
}

/// A question in the Help centre. Tapping it opens its answer beneath it.
class _Question extends StatefulWidget {
  const _Question({required this.section, required this.divider});

  final DocumentSection section;

  /// A hairline above it; every question but the first has one.
  final bool divider;

  @override
  State<_Question> createState() => _QuestionState();
}

class _QuestionState extends State<_Question> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final duration = still ? Duration.zero : const Duration(milliseconds: 280);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: widget.divider
            ? const Border(top: BorderSide(color: AppColors.line))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _open,
            child: InkWell(
              onTap: () => setState(() => _open = !_open),
              borderRadius: BorderRadius.circular(AppTheme.radius),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr(widget.section.heading),
                        style: AppText.rowTitle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: duration,
                      curve: AppMotion.settle,
                      child: const Icon(
                        LucideIcons.chevronDown,
                        size: 20,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Clipped as it grows, so the answer is uncovered rather than
          // faded in: no opacity layer over text on a slow phone.
          AnimatedSize(
            duration: duration,
            curve: AppMotion.settle,
            alignment: AlignmentDirectional.topStart,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final paragraph in widget.section.paragraphs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              context.tr(paragraph),
                              style: _paragraph,
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
