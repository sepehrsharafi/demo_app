import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../articles.dart';

/// "Health · 4 min read": what an article is about and how long it is,
/// said once, under its title. A link elsewhere says so instead.
class ArticleMeta extends StatelessWidget {
  const ArticleMeta({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${context.tr(article.topic.label)}  ·  ${_length(context, article)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppText.figure,
    );
  }

  static String _length(BuildContext context, Article article) =>
      article.opensOutside
      ? context.tr('Opens a website')
      : context.tr('{minutes} min read', {'minutes': article.minutes!});
}
