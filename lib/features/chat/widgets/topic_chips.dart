import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/models/ask_topic.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';

/// The topics a question can start from. Choosing one only frames the
/// question; the parent still says what is happening. Tapping the chosen
/// topic again clears it.
///
/// The tiles rise in one after another the first time they appear, and a
/// chosen topic's icon does its own small thing: the stethoscope beats, the
/// bottle tips, the moon rocks, the sprout grows and the smile hops.
class TopicChips extends StatelessWidget {
  const TopicChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AskTopic? selected;
  final ValueChanged<AskTopic?> onSelected;

  /// Three across, then two: an even grid that ends flush with the
  /// composer above it.
  static final _rows = [
    AskTopic.values.sublist(0, 3),
    AskTopic.values.sublist(3),
  ];

  @override
  Widget build(BuildContext context) {
    var order = 0;
    return Column(
      children: [
        for (final (r, row) in _rows.indexed) ...[
          if (r > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (final (i, topic) in row.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child:
                      _Chip(
                        topic: topic,
                        selected: topic == selected,
                        onTap: () =>
                            onSelected(topic == selected ? null : topic),
                      ).maybeAnimate(
                        context,
                        (chip) => chip
                            .animate(delay: (90 + 45 * order++).ms)
                            .veilIn(
                              duration: 260.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .slideY(
                              begin: 0.35,
                              end: 0,
                              duration: 520.ms,
                              curve: AppMotion.settle,
                            ),
                      ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// A topic: its hue's icon square, then its name, on a hairline tile.
/// Chosen, the tile takes Mother AI's violet and the square fills solid.
class _Chip extends StatefulWidget {
  const _Chip({
    required this.topic,
    required this.selected,
    required this.onTap,
  });

  final AskTopic topic;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_Chip> createState() => _ChipState();
}

class _ChipState extends State<_Chip> {
  bool _pressed = false;

  static const _radius = BorderRadius.all(Radius.circular(16));
  static const _squareRadius = BorderRadius.all(Radius.circular(10));
  static const _duration = Duration(milliseconds: 220);

  void _press(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final selected = widget.selected;
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 160),
        curve: AppMotion.settle,
        child: AnimatedContainer(
          duration: _duration,
          curve: AppMotion.settle,
          decoration: BoxDecoration(
            color: selected ? AppColors.voiceTint : AppColors.ground,
            borderRadius: _radius,
            border: Border.all(
              color: selected ? AppColors.voice : AppColors.line,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: _radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onTap();
              },
              onHighlightChanged: _press,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 8, 5),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: _duration,
                      curve: AppMotion.settle,
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.voice : topic.tint,
                        borderRadius: _squareRadius,
                      ),
                      child: TopicGlyph(
                        topic: topic,
                        play: selected,
                        size: 17,
                        color: selected ? Colors.white : topic.tone,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // On a narrow phone a long name shrinks rather than clips.
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.tr(topic.label),
                          maxLines: 1,
                          style: AppText.rowTitle.copyWith(
                            fontSize: 14,
                            color: selected
                                ? AppColors.voiceDeep
                                : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A topic's icon, which plays its own gesture each time [play] turns on.
/// Transforms only, so it costs nothing to draw.
class TopicGlyph extends StatefulWidget {
  const TopicGlyph({
    super.key,
    required this.topic,
    required this.play,
    required this.size,
    required this.color,
  });

  final AskTopic topic;
  final bool play;
  final double size;
  final Color color;

  @override
  State<TopicGlyph> createState() => _TopicGlyphState();
}

class _TopicGlyphState extends State<TopicGlyph>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );

  @override
  void didUpdateWidget(covariant TopicGlyph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      if (MediaQuery.disableAnimationsOf(context)) return;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// A smooth bump from 0 up to 1 and back over [from]..[to].
  static double _bump(double t, double from, double to) {
    if (t <= from || t >= to) return 0;
    return math.sin(math.pi * (t - from) / (to - from));
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      widget.topic.icon,
      size: widget.size,
      color: widget.color,
    );
    return AnimatedBuilder(
      animation: _controller,
      child: icon,
      builder: (context, child) {
        final t = _controller.value;
        if (t == 0 || t == 1) return child!;
        final fade = 1 - t;
        return switch (widget.topic) {
          // Two beats, the second softer.
          AskTopic.health => Transform.scale(
            scale: 1 + 0.26 * _bump(t, 0, 0.32) + 0.16 * _bump(t, 0.36, 0.66),
            child: child,
          ),
          // Tips to pour, and rights itself.
          AskTopic.feeding => Transform.rotate(
            angle: -0.55 * math.sin(t * math.pi * 2.2) * fade,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
          // Rocks like a cradle.
          AskTopic.sleep => Transform.rotate(
            angle: 0.42 * math.sin(t * math.pi * 3) * fade,
            child: child,
          ),
          // Grows up out of the ground.
          AskTopic.growth => Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.diagonal3Values(
              1,
              0.45 + 0.55 * Curves.elasticOut.transform(t),
              1,
            ),
            child: child,
          ),
          // Two hops, the second smaller.
          AskTopic.behaviour => Transform.translate(
            offset: Offset(
              0,
              -6 * _bump(t, 0, 0.42) - 2.5 * _bump(t, 0.46, 0.74),
            ),
            child: child,
          ),
        };
      },
    );
  }
}

/// What leads Home's composer: Mother AI's sparkle, which turns into the
/// chosen topic's icon square and back, so choosing a topic visibly lands
/// in the field it frames.
class ComposerTopicMark extends StatelessWidget {
  const ComposerTopicMark({super.key, required this.topic});

  final AskTopic? topic;

  @override
  Widget build(BuildContext context) {
    final topic = this.topic;
    return SizedBox.square(
      dimension: 30,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 480),
        reverseDuration: const Duration(milliseconds: 200),
        switchInCurve: AppMotion.cushion,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: RotationTransition(
            turns: Tween(begin: -0.12, end: 0.0).animate(animation),
            child: child,
          ),
        ),
        child: topic == null
            ? const ExcludeSemantics(
                key: ValueKey('sparkle'),
                child: Center(
                  child: Icon(
                    LucideIcons.sparkles,
                    size: 20,
                    color: AppColors.voice,
                  ),
                ),
              )
            : ExcludeSemantics(
                key: ValueKey(topic),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: topic.tint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Icon(topic.icon, size: 16, color: topic.tone),
                  ),
                ),
              ),
      ),
    );
  }
}
