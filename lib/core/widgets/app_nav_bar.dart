import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../l10n/l10n.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

const double _barHeight = 64;
const double _pillHeight = 44;
const double _iconSize = 22;
const double _labelGap = 8;
const double _pillPadding = 16;

/// Room between the pill and the edges of the tab it sits in.
const double _cellMargin = 8;

const _labelStyle = TextStyle(
  fontFamily: AppFonts.ui,
  package: AppFonts.uiPackage,
  fontSize: 14,
  height: 1,
  // A fixed weight reuses the same glyphs through the motion.
  fontWeight: FontWeight.w600,
  letterSpacing: -0.1,
);

/// Where the tab bar's island is drawn, so things flying over the page (a
/// photo's Hero into an article) can pass beneath it rather than over it.
final navIslandKey = GlobalKey(debugLabel: 'navIsland');

/// The persistent tab bar: an island floating over the bottom of the page.
///
/// Only the open tab says its name: it sits in a solid violet pill, and the
/// other tabs are icons. Choosing another tab makes the pill travel like a
/// drop of liquid. Its leading edge runs ahead, the trailing edge lets go a
/// beat later, and the pill stretches across the gap before gathering into
/// the new tab. The tabs make room as it goes, and the label opens inside.
class AppNavBar extends StatefulWidget {
  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar>
    with SingleTickerProviderStateMixin {
  static const _items = [
    ('Home', LucideIcons.house),
    ('Chats', LucideIcons.messagesSquare),
    ('Learn', LucideIcons.bookOpen),
    ('Profile', LucideIcons.userRound),
  ];

  /// The two edges share one controller but not one clock.
  static const _lead = Interval(0, 0.72, curve: AppMotion.settle);
  static const _trail = Interval(0.18, 1, curve: AppMotion.settle);

  late final AnimationController _controller;

  /// Measured in tabs: 1.5 means halfway between Chats and Learn.
  late double _origin;
  late double _target;

  @override
  void initState() {
    super.initState();
    _origin = _target = widget.selectedIndex.toDouble();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant AppNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == oldWidget.selectedIndex) return;
    // Relaunch from wherever the pill is, so a tap mid-travel bends its path
    // instead of snapping it back.
    _origin = _at(AppMotion.settle, _controller.value);
    _target = widget.selectedIndex.toDouble();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _at(Curve curve, double t) =>
      _origin + (_target - _origin) * curve.transform(t);

  void _select(int index) {
    if (index != widget.selectedIndex) HapticFeedback.selectionClick();
    widget.onSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: DecoratedBox(
              key: navIslandKey,
              decoration: _island,
              child: SizedBox(
                height: _barHeight,
                child: Material(
                  type: MaterialType.transparency,
                  // The pill moves every frame of a switch; the island and
                  // its shadow don't, so they stay out of that repaint.
                  child: RepaintBoundary(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Android lays out the first frame at zero width, and
                        // there is no bar to draw in that.
                        final width = constraints.maxWidth - 2 * _islandInset;
                        if (width < _pillHeight * _items.length) {
                          return const SizedBox.shrink();
                        }
                        final geometry = _Geometry(
                          width: width,
                          labelWidths: [
                            for (final (label, _) in _items)
                              _measure(context.tr(label), scaler),
                          ],
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _islandInset,
                          ),
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) => _buildBar(geometry),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// White, a hairline and one soft lavender shadow, as a stadium. With the
  /// pill's own margin this leaves an even 10pt ring around the pill.
  static const _islandInset = 2.0;
  static const _island = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(_barHeight / 2)),
    border: Border.fromBorderSide(BorderSide(color: AppColors.line)),
    boxShadow: [
      BoxShadow(
        color: Color(0x1F3B2A7A),
        blurRadius: 28,
        offset: Offset(0, 10),
      ),
      BoxShadow(color: Color(0x0D1F1B3D), blurRadius: 3, offset: Offset(0, 1)),
    ],
  );

  static double _measure(String label, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: AppText.tune(_labelStyle)),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  Widget _buildBar(_Geometry geometry) {
    final t = _controller.value;
    final position = _at(AppMotion.settle, t);
    final lead = _at(_lead, t);
    final trail = _at(_trail, t);

    final cells = geometry.cells(position);
    final movingRight = _target >= _origin;
    final (front, back) = movingRight
        ? (geometry.pillRight(cells, lead), geometry.pillLeft(cells, trail))
        : (geometry.pillLeft(cells, lead), geometry.pillRight(cells, trail));
    var left = movingRight ? back : front;
    var right = movingRight ? front : back;
    if (right - left < _pillHeight) {
      final middle = (left + right) / 2;
      left = middle - _pillHeight / 2;
      right = middle + _pillHeight / 2;
    }

    // The tabs are laid out by a row, which reads from the right in Arabic
    // and Persian; the pill is placed by hand, so it is mirrored to match.
    final mirrored = Directionality.of(context) == TextDirection.rtl;
    return Stack(
      children: [
        Positioned(
          left: mirrored ? geometry.width - right : left,
          width: right - left,
          top: (_barHeight - _pillHeight) / 2,
          height: _pillHeight,
          child: const IgnorePointer(
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: AppColors.voice,
                shape: StadiumBorder(),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                SizedBox(
                  width: cells[i].width,
                  child: _NavItem(
                    label: context.tr(_items[i].$1),
                    icon: _items[i].$2,
                    arrival: _arrival(i, position),
                    selected: i == widget.selectedIndex,
                    onTap: () => _select(i),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 0 while the pill is a tab or more away from [index], 1 once it is there.
double _arrival(int index, double position) =>
    (1 - (index - position).abs()).clamp(0.0, 1.0);

typedef _Cell = ({double left, double width});

/// Where the tabs and the pill sit for a pill position between tabs.
class _Geometry {
  _Geometry({required this.width, required this.labelWidths})
    : pillWidths = [
        for (final label in labelWidths)
          _pillPadding * 2 + _iconSize + _labelGap + label,
      ];

  final double width;
  final List<double> labelWidths;
  final List<double> pillWidths;

  int get _count => labelWidths.length;

  /// The open tab widens to hold its pill; the rest share what is left.
  List<_Cell> cells(double position) {
    final flex = <double>[];
    for (var i = 0; i < _count; i++) {
      final open = pillWidths[i] + _cellMargin * 2;
      final closed = (width - open) / (_count - 1);
      // Too narrow for the open tab to widen: share the bar evenly.
      final grow = closed > 0 ? open / closed - 1 : 0.0;
      flex.add(1 + _arrival(i, position) * grow);
    }
    final total = flex.fold<double>(0, (sum, f) => sum + f);
    final cells = <_Cell>[];
    var left = 0.0;
    for (final f in flex) {
      final cellWidth = width * f / total;
      cells.add((left: left, width: cellWidth));
      left += cellWidth;
    }
    return cells;
  }

  double _centre(List<_Cell> cells, double position) {
    final (from, to, fraction) = _between(position);
    double centre(int i) => cells[i].left + cells[i].width / 2;
    return centre(from) + (centre(to) - centre(from)) * fraction;
  }

  double _pillWidth(double position) {
    final (from, to, fraction) = _between(position);
    return pillWidths[from] + (pillWidths[to] - pillWidths[from]) * fraction;
  }

  double pillLeft(List<_Cell> cells, double position) =>
      _centre(cells, position) - _pillWidth(position) / 2;

  double pillRight(List<_Cell> cells, double position) =>
      _centre(cells, position) + _pillWidth(position) / 2;

  (int, int, double) _between(double position) {
    final clamped = position.clamp(0.0, _count - 1.0);
    final from = clamped.floor();
    final to = (from + 1).clamp(0, _count - 1);
    return (from, to, clamped - from);
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.arrival,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;

  /// 0 while the pill is a tab or more away, 1 once it has landed here.
  final double arrival;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  void _press(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final arrival = widget.arrival;
    final ink = Color.lerp(AppColors.muted, Colors.white, arrival)!;
    return Semantics(
      selected: widget.selected,
      button: true,
      label: widget.label,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _press(true),
          onTapCancel: () => _press(false),
          onTapUp: (_) => _press(false),
          onTap: widget.onTap,
          child: Center(
            child: AnimatedScale(
              scale: _pressed ? 0.88 : 1,
              duration: const Duration(milliseconds: 160),
              curve: AppMotion.settle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: _iconSize, color: ink),
                  ClipRect(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: arrival,
                      child: Opacity(
                        opacity: Curves.easeIn.transform(arrival),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: _labelGap,
                          ),
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            softWrap: false,
                            style: AppText.tune(_labelStyle)
                                .copyWith(color: ink),
                          ),
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
    );
  }
}
