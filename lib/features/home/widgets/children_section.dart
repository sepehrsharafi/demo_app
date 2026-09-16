import 'package:flutter/material.dart';

import '../../../core/models/child_profile.dart';
import '../../../core/theme/app_theme.dart';

class ChildrenSection extends StatelessWidget {
  const ChildrenSection({
    super.key,
    required this.children,
    required this.onChildTap,
  });

  final List<ChildProfile> children;
  final ValueChanged<ChildProfile> onChildTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final child in children) ...[
          _ChildCard(data: child, onTap: () => onChildTap(child)),
          if (child != children.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.data, required this.onTap});

  final ChildProfile data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gradientEnd = Color.lerp(data.cardEnd, data.avatarBackground, 0.38)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, data.cardStart, gradientEnd],
          stops: const [0, 0.45, 1],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Color.lerp(AppColors.line, data.avatarBackground, 0.5)!,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D263965),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ChildCardMotif(data.avatarBackground),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 13, 13),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: data.avatarBackground,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.9),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          data.name.isNotEmpty
                              ? data.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  data.name,
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontSize: 17),
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    '·  ${data.age}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.inkMuted,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Recent topic  ·  ${data.lastChatDate}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.inkMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: AppColors.navy,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildCardMotif extends CustomPainter {
  const _ChildCardMotif(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width - 8, -5),
      55,
      Paint()..color = color.withValues(alpha: 0.42),
    );
    canvas.drawCircle(
      Offset(size.width - 11, -3),
      37,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final sweep = Path()
      ..moveTo(size.width * 0.63, size.height)
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.73,
        size.width * 0.9,
        size.height * 0.72,
        size.width,
        size.height * 0.55,
      );
    canvas.drawPath(
      sweep,
      Paint()
        ..color = color.withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
  }

  @override
  bool shouldRepaint(covariant _ChildCardMotif oldDelegate) =>
      oldDelegate.color != color;
}
