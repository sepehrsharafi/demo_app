import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ChildData {
  const ChildData({
    required this.name,
    required this.lastChatDate,
    required this.lastMessage,
    required this.avatarBackground,
    required this.cardStart,
    required this.cardEnd,
  });

  final String name;
  final String lastChatDate;
  final String lastMessage;
  final Color avatarBackground;
  final Color cardStart;
  final Color cardEnd;
}

class ChildrenSection extends StatelessWidget {
  const ChildrenSection({
    super.key,
    required this.children,
    required this.onChildTap,
  });

  final List<ChildData> children;
  final ValueChanged<ChildData> onChildTap;

  @override
  Widget build(BuildContext context) {
    return Column(
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

  final ChildData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [data.cardStart, data.cardEnd]),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C263965),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: data.avatarBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    data.name.isNotEmpty ? data.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Last chat · ${data.lastChatDate}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontSize: 12.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.navy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
