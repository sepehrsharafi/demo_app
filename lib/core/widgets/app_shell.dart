import 'package:flutter/material.dart';

import '../../features/chat/chat_history_page.dart';
import '../../features/home/home_page.dart';
import '../../features/learn/learn_page.dart';
import '../../features/profile/profile_page.dart';
import 'app_nav_bar.dart';

/// The app's persistent chrome: a single [AppNavBar] instance that stays
/// mounted while the body underneath slides and fades between tabs, so
/// switching tabs never rebuilds or re-animates the navigation bar.
///
/// Every tab stays mounted (like an [IndexedStack]) and is transitioned rather
/// than swapped, which keeps each tab's scroll position and state intact across
/// switches. An inactive tab sits at zero opacity, which the renderer skips
/// painting entirely, so the resting cost matches an [IndexedStack].
///
/// Each tab also rests on the side it lives on relative to the selected one, so
/// a tab to the right of the current one slides in from the right and a tab to
/// the left slides in from the left — matching the order of the nav bar itself,
/// with no need to track which tab you came from.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _switchTab(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      HomeTab(onSwitchTab: _switchTab),
      const ChatHistoryTab(),
      const LearnTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Positioned.fill(
              child: _TabTransition(
                key: ValueKey('tab_$i'),
                // -1 = this tab lives to the left of the open one, 1 = right.
                direction: i.compareTo(_selectedIndex),
                child: tabs[i],
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 522),
                child: AppNavBar(
                  selectedIndex: _selectedIndex,
                  onSelected: _switchTab,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabTransition extends StatelessWidget {
  const _TabTransition({
    super.key,
    required this.direction,
    required this.child,
  });

  static const _duration = Duration(milliseconds: 260);

  /// How far, as a fraction of the page's width, a waiting tab sits off to its
  /// side. Small on purpose: enough to read as movement, not a carousel swipe.
  static const _restingOffset = 0.08;

  /// -1 when this tab sits to the left of the open one, 1 to the right, and
  /// 0 when it is the open tab.
  final int direction;
  final Widget child;

  bool get _active => direction == 0;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_active,
      child: ExcludeSemantics(
        excluding: !_active,
        // Both animations must stay OUTSIDE TickerMode. Muting a tab's tickers
        // in the same frame its exit starts freezes that animation mid-flight,
        // which leaves the outgoing tab painted on top of everything for good.
        child: AnimatedSlide(
          offset: Offset(direction * _restingOffset, 0),
          duration: _duration,
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _active ? 1 : 0,
            duration: _duration,
            curve: Curves.easeInOut,
            // Giving each tab its own layer keeps the slide and fade to
            // compositor work on a cached raster, rather than a full repaint
            // of both pages on every frame.
            child: RepaintBoundary(
              // Inactive tabs keep their state but stop ticking, so nothing
              // animates off-screen.
              child: TickerMode(enabled: _active, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
