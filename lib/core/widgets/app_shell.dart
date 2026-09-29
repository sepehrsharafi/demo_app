import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/chat/chat_history_page.dart';
import '../../features/home/home_page.dart';
import '../../features/learn/articles.dart';
import '../../features/learn/learn_page.dart';
import '../../features/profile/profile_page.dart';
import '../theme/app_motion.dart';
import 'app_nav_bar.dart';
import 'sheet_depth.dart';

/// The app's persistent chrome: a single [AppNavBar] instance that stays
/// mounted while the body underneath slides between tabs, so
/// switching tabs never rebuilds or re-animates the navigation bar.
///
/// Every tab stays mounted (like an [IndexedStack]) and is transitioned rather
/// than swapped, which keeps each tab's scroll position and state intact across
/// switches. An inactive tab sits at zero opacity, which the renderer skips
/// painting entirely, so the resting cost matches an [IndexedStack].
///
/// Tabs rest one page away on the side where they live. Switching uses only a
/// retained-layer translation: no blur, scale, or full-screen alpha blending.
/// This keeps the nav bar's spatial order clear while remaining inexpensive on
/// Android devices using the OpenGLES Impeller backend.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late final List<Widget> _tabs;
  bool _visualWarmUpScheduled = false;

  @override
  void initState() {
    super.initState();
    // Keep the exact same widget instances across shell rebuilds. Recreating
    // them on every selection made all four (including the large Learn and
    // Profile trees) rebuild just as the transition started, invalidating the
    // repaint boundaries that are meant to make the slide compositor-only.
    _tabs = [
      HomeTab(onSwitchTab: _switchTab),
      const ChatHistoryTab(),
      const LearnTab(),
      const ProfileTab(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_visualWarmUpScheduled) return;
    _visualWarmUpScheduled = true;

    // Let Home win the first frame, then decode the images used by the other
    // tabs and the pushed chat screen before a transition needs to paint them.
    // Using the same ResizeImage keys as the widgets is important: warming the
    // original asset alone would still leave Flutter to perform the resized
    // decode on first navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_warmVisualAssets());
    });
  }

  Future<void> _warmVisualAssets() async {
    // The Learn photos are the only raster art. Each is decoded once at
    // full size and shared by every place it appears (Home, Learn, the
    // article), so a photo flying between them never waits on a decode.
    final images = <ImageProvider<Object>>[
      for (final article in learnLibrary)
        if (article.imagePath case final path?) AssetImage(path),
    ];

    // Sequentially: a concurrent burst can steal enough CPU to make an early
    // tap miss a frame.
    for (final image in images) {
      if (!mounted) return;
      await precacheImage(image, context, onError: (_, _) {});
    }
  }

  void _switchTab(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) _switchTab(0);
      },
      child: RecedeBehindSheets(
        child: Scaffold(
          extendBody: true,
          // The keyboard overlays the persistent bottom navigation instead of
          // lifting it into the content area. Individual pushed screens (such
          // as an open chat) still manage their own keyboard resizing.
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Positioned.fill(
                  child: _TabTransition(
                    key: ValueKey('tab_$i'),
                    // -1 = this tab lives to the left of the open one, 1 = right.
                    direction: i.compareTo(_selectedIndex),
                    child: _tabs[i],
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AppNavBar(
                  selectedIndex: _selectedIndex,
                  onSelected: _switchTab,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabTransition extends StatefulWidget {
  const _TabTransition({
    super.key,
    required this.direction,
    required this.child,
  });

  /// -1 when this tab sits to the left of the open one, 1 to the right, and
  /// 0 when it is the open tab.
  final int direction;
  final Widget child;

  @override
  State<_TabTransition> createState() => _TabTransitionState();
}

class _TabTransitionState extends State<_TabTransition>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 340);
  static const _pageOffset = 1.0;

  late final AnimationController _controller;
  late Animation<Offset> _position;
  late bool _visible;

  bool get _active => widget.direction == 0;

  Offset _restingPosition(int direction) => Offset(direction * _pageOffset, 0);

  @override
  void initState() {
    super.initState();
    _visible = _active;
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
      value: 1,
    )..addStatusListener(_handleAnimationStatus);
    _position = AlwaysStoppedAnimation(
      _active ? Offset.zero : _restingPosition(widget.direction),
    );
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_active && _visible) {
      setState(() => _visible = false);
    }
  }

  @override
  void didUpdateWidget(covariant _TabTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.direction == oldWidget.direction) return;

    final wasActive = oldWidget.direction == 0;
    if (!wasActive && !_active) {
      // A skipped-over tab should move to its new resting side invisibly,
      // rather than sweeping across the screen between the two chosen tabs.
      _controller.stop();
      _position = AlwaysStoppedAnimation(_restingPosition(widget.direction));
      _visible = false;
      return;
    }

    final currentPosition = _position.value;
    _visible = true;

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _position = AlwaysStoppedAnimation(
        _active ? Offset.zero : _restingPosition(widget.direction),
      );
      _visible = _active;
      return;
    }

    _controller.duration = _duration;
    _position = Tween<Offset>(
      begin: currentPosition,
      end: _active ? Offset.zero : _restingPosition(widget.direction),
    ).animate(CurvedAnimation(parent: _controller, curve: AppMotion.settle));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_active,
      child: ExcludeSemantics(
        excluding: !_active,
        // Visibility changes only after the physical slide completes. Keeping
        // this transition outside TickerMode lets an outgoing page finish its
        // movement while its own content animations are already paused.
        child: SlideTransition(
          // Tabs rest on the side their place in the bar is on, and the bar
          // reads from the right in Arabic and Persian.
          textDirection: Directionality.of(context),
          position: _position,
          child: FadeTransition(
            // A stopped 1/0 animation lets the renderer skip fully hidden tabs
            // without creating an animated full-screen opacity layer.
            opacity: AlwaysStoppedAnimation(_visible ? 1 : 0),
            child: RepaintBoundary(
              // With no animated scale around this boundary, Flutter can
              // retain the page as a layer and only translate it during the
              // transition instead of resampling a full-screen image.
              // Hidden tabs keep their Heroes out of pushes, so an article
              // opened from Home doesn't fly in from Learn's copy of it.
              child: HeroMode(
                enabled: _active,
                child: TickerMode(enabled: _active, child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
