import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/text_menu.dart';

/// The field a parent asks in. The send button wakes up in Mother AI's
/// colour once there is something to send, and rests while Mother AI is
/// still answering.
class AskComposer extends StatelessWidget {
  const AskComposer({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.onSend,
    this.busy = false,
    this.fieldKey,
    this.focusNode,
    this.raised = false,
    this.leading,
  });

  final TextEditingController controller;
  final String placeholder;
  final VoidCallback onSend;

  /// An answer is still being written, so the next question waits.
  final bool busy;
  final Key? fieldKey;

  /// Lets a topic chip move the caret into the field.
  final FocusNode? focusNode;

  /// Home's composer: white, with one soft lavender shadow lifting it off
  /// the morning wash. The only resting shadow in the app, because it is
  /// the one thing Home is for.
  final bool raised;

  /// What leads the text, such as the chosen topic's mark on Home.
  final Widget? leading;

  static const _radius = BorderRadius.all(Radius.circular(26));
  static const _lift = [
    BoxShadow(color: Color(0x145B3FB0), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A1F1B3D), blurRadius: 3, offset: Offset(0, 1)),
  ];

  @override
  Widget build(BuildContext context) {
    // One fill, shared with the placeholder's fade so the two always match.
    final fill = raised ? Colors.white : AppColors.panel;

    final input = ShadInput(
      contextMenuBuilder: textMenu,
      key: fieldKey,
      controller: controller,
      focusNode: focusNode,
      placeholder: _Placeholder(text: placeholder, ground: fill),
      minLines: 1,
      maxLines: 5,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => onSend(),
      style: AppText.body,
      placeholderStyle: AppText.body.copyWith(color: AppColors.muted),
      padding: EdgeInsetsDirectional.fromSTEB(
        leading != null ? 16 : 18,
        6,
        6,
        6,
      ),
      gap: leading != null ? 10 : 6,
      constraints: const BoxConstraints(minHeight: 56),
      crossAxisAlignment: CrossAxisAlignment.center,
      // The field around it draws the fill and the hairline, so focusing
      // (a topic chip does it) never nudges the text.
      decoration: const ShadDecoration(
        color: Colors.transparent,
        border: ShadBorder.none,
        focusedBorder: ShadBorder.none,
        secondaryFocusedBorder: ShadBorder.none,
      ),
      leading: leading,
      trailing: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final ready = !busy && value.text.trim().isNotEmpty;
          return AnimatedScale(
            scale: ready ? 1 : 0.86,
            duration: const Duration(milliseconds: 220),
            curve: AppMotion.settle,
            child: ShadIconButton(
              width: 44,
              height: 44,
              iconSize: 20,
              icon: Icon(
                LucideIcons.arrowUp,
                semanticLabel: context.tr('Send'),
              ),
              backgroundColor: ready ? AppColors.voice : AppColors.voiceTint,
              hoverBackgroundColor: ready
                  ? AppColors.voiceDeep
                  : AppColors.voiceTint,
              foregroundColor: ready ? Colors.white : AppColors.voice,
              decoration: const ShadDecoration(
                border: ShadBorder(
                  radius: BorderRadius.all(Radius.circular(22)),
                ),
              ),
              onPressed: ready ? onSend : null,
            ),
          );
        },
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: _radius,
        border: Border.all(color: AppColors.line),
        boxShadow: raised ? _lift : null,
      ),
      child: input,
    );
  }
}

/// The invitation in the empty field. When it changes (a topic was chosen)
/// the new line rises into place as the old one lifts away.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.text, required this.ground});

  final String text;

  /// The field's fill, which the change fades over.
  final Color ground;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      reverseDuration: const Duration(milliseconds: 180),
      switchInCurve: AppMotion.settle,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, animation) => AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) => FractionalTranslation(
          // Arriving from below; leaving upward.
          translation: Offset(
            0,
            (animation.status == AnimationStatus.reverse ? -0.5 : 0.5) *
                (1 - animation.value),
          ),
          child: GroundVeil(
            visible: animation.value,
            ground: ground,
            child: child!,
          ),
        ),
      ),
      child: Text(
        text,
        key: ValueKey(text),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
