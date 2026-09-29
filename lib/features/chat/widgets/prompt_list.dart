import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/directional_icons.dart';

/// A short list of questions to start from. Each one sends itself, in the
/// app's language.
class PromptList extends StatelessWidget {
  const PromptList({super.key, required this.prompts, required this.onPrompt});

  final List<String> prompts;
  final ValueChanged<String> onPrompt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < prompts.length; i++)
          _PromptRow(
            key: ValueKey(prompts[i]),
            prompt: prompts[i],
            divider: i != 0,
            onTap: () => onPrompt(context.tr(prompts[i])),
          ).maybeAnimate(
            context,
            (row) => row
                .animate(delay: (40 * i).ms)
                .veilIn(duration: 260.ms, curve: Curves.easeOutCubic)
                .slideY(begin: 0.25, end: 0, curve: AppMotion.settle),
          ),
      ],
    );
  }
}

class _PromptRow extends StatelessWidget {
  const _PromptRow({
    super.key,
    required this.prompt,
    required this.divider,
    required this.onTap,
  });

  final String prompt;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? const Border(top: BorderSide(color: AppColors.line))
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Expanded(child: Text(context.tr(prompt), style: AppText.body)),
              const SizedBox(width: 12),
              Icon(context.outArrow, size: 18, color: AppColors.voice),
            ],
          ),
        ),
      ),
    );
  }
}
