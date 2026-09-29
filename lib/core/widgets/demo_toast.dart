import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../l10n/l10n.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import 'mother_mark.dart';

/// A short note from Mother AI, such as when something couldn't be done,
/// so a tap never ends in silence.
///
/// It is Mother AI speaking, so it carries the mark. It rises from below,
/// comes to rest on a soft cushion, and a violet line under the text runs
/// down to show how long it stays. It leaves on an ease-in-out, dropping
/// and fading together. A close button is always there, and a flick down
/// dismisses it too. A new toast replaces the one showing.
///
/// [clearance] is how far above the bottom safe area (or the keyboard) it
/// sits: enough for the tab bar by default.
void showDemoToast(
  BuildContext context, {
  required String title,
  String? description,
  double clearance = 84,
}) {
  final overlay = Overlay.of(context);
  _current?.dismiss();

  late final OverlayEntry entry;
  final handle = _ToastHandle();
  entry = OverlayEntry(
    builder: (context) => _Toast(
      handle: handle,
      title: title,
      description: description,
      clearance: clearance,
      onGone: () {
        entry.remove();
        entry.dispose();
        if (identical(_current, handle)) _current = null;
      },
    ),
  );
  _current = handle;
  overlay.insert(entry);
}

_ToastHandle? _current;

/// Lets a new toast ask the one showing to leave.
class _ToastHandle {
  VoidCallback? _dismiss;
  bool _dismissed = false;

  void dismiss() {
    _dismissed = true;
    _dismiss?.call();
  }
}

class _Toast extends StatefulWidget {
  const _Toast({
    required this.handle,
    required this.title,
    required this.description,
    required this.onGone,
    required this.clearance,
  });

  final _ToastHandle handle;
  final String title;
  final String? description;
  final VoidCallback onGone;
  final double clearance;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with TickerProviderStateMixin {
  static const _stay = Duration(seconds: 5);

  late final _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 640),
    reverseDuration: const Duration(milliseconds: 320),
  );

  /// Runs down over the toast's stay; its value is the time left.
  late final _countdown = AnimationController(vsync: this, duration: _stay);

  /// How far the toast has been dragged down, in points.
  final _drag = ValueNotifier<double>(0);

  /// Eases a short flick back into place instead of snapping.
  late final _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  double _settleFrom = 0;
  bool _leaving = false;

  // Arrival: quick fade, rise and grow onto a soft overshoot.
  // Departure: all three together, easing in and out.
  late final _rise = CurvedAnimation(
    parent: _motion,
    curve: AppMotion.cushion,
    reverseCurve: Curves.easeInOutCubic,
  );
  late final _fade = CurvedAnimation(
    parent: _motion,
    curve: const Interval(0, 0.35, curve: Curves.easeOut),
    reverseCurve: const Interval(0.2, 1, curve: Curves.easeInOut),
  );
  late final _mark = CurvedAnimation(
    parent: _motion,
    curve: const Interval(0.18, 1, curve: AppMotion.cushion),
    reverseCurve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    widget.handle._dismiss = _leave;
    _settle.addListener(_onSettle);
    if (widget.handle._dismissed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onGone());
      return;
    }
    _countdown.reverse(from: 1);
    _countdown.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) _leave();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motion.isDismissed && !_leaving) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _motion.value = 1;
      } else {
        _motion.forward();
      }
    }
  }

  Future<void> _leave() async {
    if (_leaving || !mounted) return;
    _leaving = true;
    _countdown.stop();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = 0;
    } else {
      await _motion.reverse();
    }
    if (mounted) widget.onGone();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _settle.stop();
    _drag.value = (_drag.value + details.delta.dy).clamp(-8.0, 200.0);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_drag.value > 36 || details.velocity.pixelsPerSecond.dy > 500) {
      _leave();
    } else {
      _settleFrom = _drag.value;
      _settle.forward(from: 0);
    }
  }

  void _onSettle() {
    final t = AppMotion.cushion.transform(_settle.value);
    _drag.value = _settleFrom * (1 - t);
  }

  @override
  void dispose() {
    widget.handle._dismiss = null;
    _rise.dispose();
    _fade.dispose();
    _mark.dispose();
    _motion.dispose();
    _countdown.dispose();
    _settle.dispose();
    _drag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Clear of the tab bar or a chat's composer, and of the keyboard. Read
    // from the window itself: the overlay's own MediaQuery has the system
    // bars' padding taken out already.
    // The keyboard covers the safe area, so the two never add up.
    final view = MediaQueryData.fromView(View.of(context));
    final bottom =
        math.max(
          MediaQuery.viewInsetsOf(context).bottom,
          view.viewPadding.bottom,
        ) +
        widget.clearance;
    final card = _Card(
      title: widget.title,
      description: widget.description,
      countdown: _countdown,
      mark: _mark,
      onClose: _leave,
    );

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottom,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GestureDetector(
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            child: AnimatedBuilder(
              animation: Listenable.merge([_motion, _drag]),
              child: RepaintBoundary(child: card),
              builder: (context, child) {
                final rise = _rise.value;
                return Transform.translate(
                  offset: Offset(0, (1 - rise) * 96 + _drag.value),
                  child: Transform.scale(
                    scale: 0.92 + 0.08 * rise,
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: _fade.value.clamp(0.0, 1.0),
                      // Announced as it arrives, not once the fade is done.
                      alwaysIncludeSemantics: true,
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The toast itself: the mark, what happened, the countdown and a close
/// button.
class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.description,
    required this.countdown,
    required this.mark,
    required this.onClose,
  });

  final String title;
  final String? description;
  final Animation<double> countdown;
  final Animation<double> mark;
  final VoidCallback onClose;

  static const _radius = BorderRadius.all(Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    return Semantics(
      liveRegion: true,
      container: true,
      // One soft shadow, painted once under the card.
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: _radius,
          border: Border.fromBorderSide(BorderSide(color: AppColors.line)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1F3B2A7A),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 6, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaleTransition(scale: mark, child: const MotherMark(size: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 1),
                      Text(
                        title,
                        style: AppText.rowTitle.copyWith(fontSize: 15),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(description, style: AppText.secondary),
                      ],
                      const SizedBox(height: 10),
                      ExcludeSemantics(
                        child: SizedBox(
                          width: double.infinity,
                          height: 2,
                          child: CustomPaint(
                            painter: _CountdownPainter(countdown),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                ShadIconButton.ghost(
                  width: 44,
                  height: 44,
                  iconSize: 18,
                  foregroundColor: AppColors.muted,
                  icon: Icon(
                    LucideIcons.x,
                    semanticLabel: context.tr('Dismiss'),
                  ),
                  decoration: const ShadDecoration(
                    border: ShadBorder(
                      radius: BorderRadius.all(Radius.circular(22)),
                    ),
                  ),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// How long the toast has left, as a line that runs down from full width.
/// It repaints on its own, so the countdown never rebuilds the toast.
class _CountdownPainter extends CustomPainter {
  _CountdownPainter(this.left) : super(repaint: left);

  final Animation<double> left;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = AppColors.voiceTint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & Size(size.width * left.value, size.height),
        radius,
      ),
      Paint()..color = AppColors.voice,
    );
  }

  @override
  bool shouldRepaint(_CountdownPainter old) => old.left != left;
}
