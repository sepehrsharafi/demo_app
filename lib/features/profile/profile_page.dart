import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/data/app_scope.dart';
import '../../core/l10n/l10n.dart';
import '../../core/models/preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/child_monogram.dart';
import 'child_form_page.dart';
import 'child_sheet.dart';
import 'document_page.dart';
import 'documents.dart';
import 'widgets/contact_sheet.dart';
import 'widgets/notice_sheet.dart';
import 'widgets/option_sheet.dart';
import 'widgets/settings_group.dart';

/// The Profile tab: the account, the family, and how Mother AI answers.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  /// The account, plans and sign-out are in the design but not built yet:
  /// they look tappable and do nothing.
  static void _notYet() {}

  Future<void> _chooseLanguage(BuildContext context) async {
    final store = AppScope.of(context, listen: false);
    final language = await pickOption(
      context,
      title: context.tr('Language'),
      description: context.tr('Mother AI answers in this language.'),
      options: [
        for (final language in AppLanguage.values)
          (language, language.nativeName),
      ],
      selected: store.language,
    );
    if (language != null) await store.setLanguage(language);
  }

  Future<void> _chooseUnits(BuildContext context) async {
    final store = AppScope.of(context, listen: false);
    final units = await pickOption(
      context,
      title: context.tr('Units'),
      description: context.tr(
        'How Mother AI writes weights, lengths and temperatures.',
      ),
      options: [
        for (final units in Units.values)
          (
            units,
            '${context.tr(units.label)}  ·  ${context.tr(units.examples)}',
          ),
      ],
      selected: store.units,
    );
    if (units != null) await store.setUnits(units);
  }

  void _showDisclaimer(BuildContext context) {
    showNoticeSheet(
      context,
      title: context.tr('Medical disclaimer'),
      paragraphs: [
        context.tr(
          'Mother AI offers general parenting guidance and is not a medical '
          'service. It can’t diagnose, treat or replace advice from your '
          'doctor, midwife or health visitor.',
        ),
        context.tr(
          'If your child is seriously unwell, or you are worried about their '
          'breathing, alertness or hydration, contact your local emergency '
          'number straight away.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final l10n = context.l10n;
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 128),
            children: [
              Text(context.tr('Profile'), style: AppText.display),
              const SizedBox(height: 24),
              const _Account(),
              const SizedBox(height: 16),
              const _Plus(),
              const SizedBox(height: 32),
              SettingsGroup(
                heading: context.tr('Children'),
                rows: [
                  for (final child in store.children)
                    SettingsRow(
                      leading: ChildMonogram(child: child, size: 28),
                      title: child.name,
                      subtitle: context.tr('{age} · born {date}', {
                        'age': l10n.age(child),
                        'date': l10n.date(child.birthday),
                      }),
                      onTap: () => showChildSheet(context, child),
                    ),
                  SettingsRow(
                    icon: LucideIcons.plus,
                    title: context.tr('Add a child'),
                    onTap: () => editChild(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SettingsGroup(
                heading: context.tr('Preferences'),
                rows: [
                  SettingsRow(
                    icon: LucideIcons.globe,
                    title: context.tr('Language'),
                    value: store.language.nativeName,
                    onTap: () => _chooseLanguage(context),
                  ),
                  SettingsRow(
                    icon: LucideIcons.ruler,
                    title: context.tr('Units'),
                    value: context.tr(store.units.label),
                    onTap: () => _chooseUnits(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SettingsGroup(
                heading: context.tr('Help'),
                rows: [
                  SettingsRow(
                    icon: LucideIcons.shieldAlert,
                    title: context.tr('Medical disclaimer'),
                    subtitle: context.tr('Mother AI is not a doctor'),
                    onTap: () => _showDisclaimer(context),
                  ),
                  SettingsRow(
                    icon: LucideIcons.lifeBuoy,
                    title: context.tr('Help centre'),
                    onTap: () => openDocument(context, helpCentre),
                  ),
                  SettingsRow(
                    icon: LucideIcons.mail,
                    title: context.tr('Contact support'),
                    onTap: () => showContactSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SettingsGroup(
                heading: context.tr('About'),
                rows: [
                  SettingsRow(
                    icon: LucideIcons.fileText,
                    title: context.tr('Terms of service'),
                    onTap: () => openDocument(context, termsOfService),
                  ),
                  SettingsRow(
                    icon: LucideIcons.fileLock,
                    title: context.tr('Privacy policy'),
                    onTap: () => openDocument(context, privacyPolicy),
                  ),
                  SettingsRow(
                    icon: LucideIcons.info,
                    title: context.tr('Version'),
                    value: appVersion,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ShadButton.outline(
                size: ShadButtonSize.lg,
                textStyle: AppText.button,
                foregroundColor: const Color(0xFFD92D40),
                leading: const Icon(LucideIcons.logOut, size: 18),
                onPressed: _notYet,
                child: Text(context.tr('Sign out')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder account; the name and email are sample data.
class _Account extends StatelessWidget {
  const _Account();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.ink,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: 56,
            child: Center(
              child: Text(
                'SM',
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sarah Mitchell', style: AppText.rowTitle),
              const SizedBox(height: 2),
              Text(
                'sarah.mitchell@email.com',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.secondary,
              ),
            ],
          ),
        ),
        ShadButton.outline(
          size: ShadButtonSize.sm,
          onPressed: ProfileTab._notYet,
          child: Text(context.tr('Edit')),
        ),
      ],
    );
  }
}

class _Plus extends StatelessWidget {
  const _Plus();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('Mother AI Plus'), style: AppText.rowTitle),
                  const SizedBox(height: 2),
                  Text(
                    context.tr(
                      'Sample plan: unlimited chats, deeper answers, no ads.',
                    ),
                    style: AppText.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ShadButton.outline(
              size: ShadButtonSize.sm,
              onPressed: ProfileTab._notYet,
              child: Text(context.tr('See plans')),
            ),
          ],
        ),
      ),
    );
  }
}
