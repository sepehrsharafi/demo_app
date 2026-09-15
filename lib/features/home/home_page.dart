import 'package:flutter/material.dart';

import '../../core/models/child_profile.dart';
import '../../core/theme/app_theme.dart';
import '../chat/chat_page.dart';
import 'widgets/children_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/learn_spotlight_card.dart';
import 'widgets/mother_prompt_field.dart';

/// The Home tab's body, embedded in the persistent app shell.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.onSwitchTab});

  /// Lets Home hand off to another tab (e.g. the Learn spotlight card).
  final ValueChanged<int> onSwitchTab;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: Offset.zero,
    ).animate(_fadeAnimation);
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navy,
        ),
      );
  }

  void _askMotherAi(String value) {
    final prompt = value.trim();
    if (prompt.isEmpty) {
      _showMessage('Ask me anything about your day');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ChatPage(initialPrompt: prompt)),
    );
  }

  void _openChildChat(ChildProfile child) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ChatPage(selectedChild: child)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _SoftBackground()),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: HeroSection()),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 116),
                      sliver: SliverList.list(
                        children: [
                          MotherPromptField(onSubmit: _askMotherAi),
                          const SizedBox(height: 16),
                          ChildrenSection(
                            children: demoChildren,
                            onChildTap: _openChildChat,
                          ),
                          const SizedBox(height: 14),
                          LearnSpotlightCard(
                            onTap: () => widget.onSwitchTab(2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SoftBackground extends StatelessWidget {
  const _SoftBackground();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: ColoredBox(
        color: AppColors.background,
        child: CustomPaint(painter: _BottomBackgroundPainter()),
      ),
    );
  }
}

class _BottomBackgroundPainter extends CustomPainter {
  const _BottomBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final lavenderOuter = Path()
      ..moveTo(0, size.height - 216)
      ..cubicTo(
        39,
        size.height - 199,
        70,
        size.height - 166,
        84,
        size.height - 128,
      )
      ..cubicTo(100, size.height - 82, 87, size.height - 40, 63, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(lavenderOuter, Paint()..color = const Color(0xFFF4F1FF));

    final lavenderInner = Path()
      ..moveTo(0, size.height - 174)
      ..cubicTo(
        31,
        size.height - 157,
        53,
        size.height - 126,
        60,
        size.height - 94,
      )
      ..cubicTo(67, size.height - 59, 51, size.height - 27, 37, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(lavenderInner, Paint()..color = const Color(0xFFECEAFF));

    final blushCorner = Path()
      ..moveTo(size.width, size.height - 182)
      ..cubicTo(
        size.width - 42,
        size.height - 169,
        size.width - 68,
        size.height - 131,
        size.width - 73,
        size.height - 91,
      )
      ..cubicTo(
        size.width - 78,
        size.height - 53,
        size.width - 55,
        size.height - 21,
        size.width - 35,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(blushCorner, Paint()..color = const Color(0xFFFFF2F2));
  }

  @override
  bool shouldRepaint(covariant _BottomBackgroundPainter oldDelegate) => false;
}
