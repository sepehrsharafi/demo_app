import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/l10n.dart';
import '../../core/widgets/demo_toast.dart';
import 'article_page.dart';
import 'articles.dart';

/// Opens something from Learn: an article in the app's reader, or a link in
/// the phone's in-app browser, so the parent is one swipe from coming back.
Future<void> openArticle(BuildContext context, Article article) async {
  final url = article.url;
  if (url == null) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ArticlePage(article: article)),
    );
    return;
  }

  final uri = Uri.parse(url);
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    if (!opened) {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    showDemoToast(
      context,
      title: context.tr('That page wouldn’t open'),
      description: context.tr('Check your connection and try again.'),
    );
  }
}
