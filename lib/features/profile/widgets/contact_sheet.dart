import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/demo_toast.dart';
import '../../../core/widgets/sheet_depth.dart';

/// Where support messages go. A placeholder until Mother AI has an inbox of
/// its own: change it here, and only here.
const supportEmail = 'support@motherai.app';

/// The version the app reports in a support email; the same one Profile
/// shows.
const appVersion = '1.0.0';

/// How to reach a person: by email, written in the parent's own mail app,
/// with the address to copy when there isn't one.
Future<void> showContactSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (context) => ShadSheet(
      draggable: true,
      scrollable: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      title: Text(context.tr('Contact support')),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr(
                  'Questions about the app, something that didn’t work, or '
                  'an idea: write to us and we’ll reply by email.',
                ),
                style: AppText.body.copyWith(fontSize: 15.5),
              ).cascadeIn(context, 0),
              const SizedBox(height: 12),
              Text(
                context.tr(
                  'Support can’t give medical advice. If your child is '
                  'unwell, ask Mother AI or a health professional, and in an '
                  'emergency call your local emergency number.',
                ),
                style: AppText.secondary,
              ).cascadeIn(context, 1),
              const SizedBox(height: 20),
              const _Address().cascadeIn(context, 2),
              const SizedBox(height: 20),
              ShadButton(
                size: ShadButtonSize.lg,
                textStyle: AppText.button,
                leading: const Icon(LucideIcons.mail, size: 18),
                onPressed: () => _write(context),
                child: Text(context.tr('Write an email')),
              ).cascadeIn(context, 3),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Opens the parent's mail app with the address, a subject and the app's
/// version filled in. Without a mail app, copies the address instead.
Future<void> _write(BuildContext context) async {
  final subject = context.tr('Mother AI support');
  final body = '\n\n—\nMother AI $appVersion';
  final mail = Uri(
    scheme: 'mailto',
    path: supportEmail,
    query:
        'subject=${Uri.encodeComponent(subject)}'
        '&body=${Uri.encodeComponent(body)}',
  );
  var opened = false;
  try {
    opened = await launchUrl(mail);
  } catch (error) {
    debugPrint('No mail app: $error');
  }
  if (opened || !context.mounted) return;
  await _copy(context);
}

Future<void> _copy(BuildContext context) async {
  await Clipboard.setData(const ClipboardData(text: supportEmail));
  if (!context.mounted) return;
  showDemoToast(
    context,
    title: context.tr('Address copied'),
    description: context.tr('Paste it into your email app.'),
  );
}

/// The address itself, with a way to copy it.
class _Address extends StatelessWidget {
  const _Address();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: AppColors.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(LucideIcons.mail, size: 18, color: AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                supportEmail,
                textDirection: TextDirection.ltr,
                style: AppText.rowTitle,
              ),
            ),
            ShadIconButton.ghost(
              width: 44,
              height: 44,
              iconSize: 18,
              foregroundColor: AppColors.muted,
              icon: Icon(
                LucideIcons.copy,
                semanticLabel: context.tr('Copy address'),
              ),
              onPressed: () => _copy(context),
            ),
          ],
        ),
      ),
    );
  }
}
