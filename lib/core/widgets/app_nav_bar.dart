import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

const double _barHeight = 72;
const double _pillHeight = 32;
const double _pillMaxWidth = 64;
const double _labelHeight = 12;
const double _iconLabelGap = 5;

/// Where the pill sits so the icon it frames stays optically centred above
/// the label.
const double _pillTop =
    (_barHeight - (_pillHeight + _iconLabelGap + _labelHeight)) / 2;

/// The active icon and label colour. Deeper than [AppColors.lavender], which
/// only reaches about 3.3:1 on white and is too light to carry a 12px label.
const Color _activeInk = Color(0xFF6B45C9);

/// The tint behind the active icon.
const Color _pillFill = Color(0xFFEDE6FB);

/// The shared bottom navigation used across the primary tabs.
///
/// Kept as a single reusable component so every screen renders an identical
/// height, radius, padding, icon sizing and active-state behaviour — only the
/// active tab changes.
///
/// The active tab is marked by one pill behind its icon, which slides to the
/// tab you pick while the icons and labels colour across with it. A single
/// controller drives both so they cannot drift apart.
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
    ('Home', 'assets/icons/home.svg'),
    ('Chat', 'assets/icons/chat.svg'),
    ('Learn', 'assets/icons/book.svg'),
    ('Profile', 'assets/icons/profile.svg'),
  ];

  static const _duration = Duration(milliseconds: 280);

  late final AnimationController _controller;

  /// Both are in cell space — the pill's position is measured in tabs, so 1.5
  /// means "halfway between Chat and Learn".
  late double _origin;
  late double _target;

  @override
  void initState() {
    super.initState();
    _origin = _target = widget.selectedIndex.toDouble();
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant AppNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == oldWidget.selectedIndex) return;
    // Re-launch from wherever the pill actually is, so tapping a third tab
    // mid-slide bends its path instead of teleporting it back to the old one.
    _origin = _positionAt(_controller.value);
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

  double _positionAt(double t) =>
      _origin + (_target - _origin) * Curves.easeOutCubic.transform(t);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140D2350),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        height: _barHeight,
        // The ink layer must share the bar's physical outline. Previously the
        // white decoration was rounded but the Material remained rectangular,
        // allowing press ripples to paint beyond the visible corners.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Material(
            color: Colors.white,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellWidth = constraints.maxWidth / _items.length;
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => _buildBar(cellWidth),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBar(double cellWidth) {
    final position = _positionAt(_controller.value);
    final pillWidth = math.min(cellWidth - 16, _pillMaxWidth);

    return Stack(
      children: [
        Positioned(
          left: cellWidth * (position + 0.5) - pillWidth / 2,
          top: _pillTop,
          width: pillWidth,
          height: _pillHeight,
          child: const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _pillFill,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    label: _items[i].$1,
                    iconPath: _items[i].$2,
                    // How fully the pill has arrived over this tab.
                    arrival: (1 - (i - position).abs()).clamp(0.0, 1.0),
                    selected: i == widget.selectedIndex,
                    onTap: () => widget.onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    required this.iconPath,
    required this.arrival,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconPath;

  /// 0 when the pill is a full tab away or further, 1 once it has landed.
  final double arrival;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  void _setFocused(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    final ink = Color.lerp(AppColors.inkMuted, _activeInk, widget.arrival)!;
    final feedbackAlpha = _pressed
        ? 0.11
        : _focused
        ? 0.08
        : _hovered
        ? 0.045
        : 0.0;

    return Semantics(
      selected: widget.selected,
      button: true,
      label: widget.label,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: _setPressed,
        onHover: _setHovered,
        onFocusChange: _setFocused,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lavender.withValues(alpha: feedbackAlpha),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            AnimatedScale(
              scale: _pressed ? 0.965 : 1,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: _pillHeight,
                    child: Center(
                      child: SvgPicture.asset(
                        widget.iconPath,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(ink, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(height: _iconLabelGap),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: ink,
                      fontFamily: 'Urbanist',
                      fontSize: _labelHeight,
                      height: 1,
                      // A fixed weight lets Flutter reuse the same shaped/
                      // rasterized glyphs throughout the selection motion.
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
