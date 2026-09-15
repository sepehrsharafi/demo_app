import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';

class MotherPromptField extends StatefulWidget {
  const MotherPromptField({super.key, required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<MotherPromptField> createState() => _MotherPromptFieldState();
}

class _MotherPromptFieldState extends State<MotherPromptField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: Colors.white),
        boxShadow: const [
          BoxShadow(
            color: Color(0x130D2350),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      isAntiAlias: true,
      child: Row(
        children: [
          const SizedBox(width: 18),
          SvgPicture.asset(
            'assets/icons/chat.svg',
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(
              AppColors.inkMuted,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: TextField(
              key: const Key('motherPromptField'),
              controller: _controller,
              onSubmitted: widget.onSubmit,
              textInputAction: TextInputAction.send,
              style: const TextStyle(color: AppColors.navy, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Ask Mother AI anything...',
                hintStyle: TextStyle(color: AppColors.inkMuted, fontSize: 16),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Send question',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => widget.onSubmit(_controller.text),
                child: Ink(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF8799F0), Color(0xFFC778D2)],
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
