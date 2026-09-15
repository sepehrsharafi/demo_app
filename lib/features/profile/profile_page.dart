import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The Profile tab: account, children, preferences, privacy, support and
/// legal — everything that isn't part of the day-to-day chat flow.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _pushNotifications = true;
  bool _dailyTips = true;
  bool _weeklySummary = false;

  static const _children = <_ChildEntry>[
    _ChildEntry(
      name: 'Emma',
      age: '6 months old',
      birthday: 'Born 14 Mar 2026',
      background: Color(0xFFFCE1DF),
    ),
    _ChildEntry(
      name: 'Daniel',
      age: '2 years old',
      birthday: 'Born 2 May 2024',
      background: Color(0xFFE3E7FB),
    ),
  ];

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

  Future<void> _confirmSignOut() async {
    final signOut = await _confirm(
      title: 'Sign out?',
      message: 'Your chats stay saved to your account.',
      confirmLabel: 'Sign out',
    );
    if (signOut) _showMessage('Signed out');
  }

  Future<void> _confirmDeleteAccount() async {
    final delete = await _confirm(
      title: 'Delete account?',
      message:
          'This permanently removes your account, your children’s '
          'profiles and every conversation. This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (delete) _showMessage('Account deletion requested');
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: destructive ? AppColors.coral : AppColors.lavender,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showDisclaimer() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          'Medical disclaimer',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(
          'Mother AI offers general parenting guidance and is not a medical '
          'service. It cannot diagnose, treat or replace advice from your '
          'doctor, midwife or health visitor.\n\nIf your child is seriously '
          'unwell, or you are worried about their breathing, alertness or '
          'hydration, contact your local emergency number straight away.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Got it',
              style: TextStyle(
                color: AppColors.lavender,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        const Positioned.fill(child: _ProfileBackground()),
        SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 4),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Profile', style: textTheme.displayLarge),
                          const SizedBox(height: 4),
                          Text(
                            'Your account and family.',
                            style: textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 128),
                    sliver: SliverList.list(
                      children: [
                        _AccountCard(
                          onEdit: () => _showMessage('Edit profile'),
                        ),
                        const SizedBox(height: 14),
                        _PlanCard(
                          onUpgrade: () => _showMessage('Mother AI Plus'),
                        ),

                        const _GroupLabel('YOUR CHILDREN'),
                        _SettingsGroup(
                          children: [
                            for (final child in _children)
                              _SettingsRow(
                                leading: _ChildAvatar(data: child),
                                title: child.name,
                                subtitle: '${child.age} · ${child.birthday}',
                                onTap: () => _showMessage(child.name),
                              ),
                            _SettingsRow(
                              icon: Icons.add_rounded,
                              iconColor: AppColors.lavender,
                              iconBackground: const Color(0xFFEEE6FF),
                              title: 'Add a child',
                              onTap: () => _showMessage('Add a child'),
                            ),
                          ],
                        ),

                        const _GroupLabel('PREFERENCES'),
                        _SettingsGroup(
                          children: [
                            _SettingsRow(
                              icon: Icons.notifications_none_rounded,
                              iconColor: AppColors.lavender,
                              iconBackground: const Color(0xFFEEE6FF),
                              title: 'Push notifications',
                              trailing: _RowSwitch(
                                value: _pushNotifications,
                                onChanged: (value) =>
                                    setState(() => _pushNotifications = value),
                              ),
                            ),
                            _SettingsRow(
                              icon: Icons.lightbulb_outline_rounded,
                              iconColor: const Color(0xFFE39A2E),
                              iconBackground: const Color(0xFFFCEBCF),
                              title: 'Daily tips',
                              subtitle: 'One small idea each morning',
                              trailing: _RowSwitch(
                                value: _dailyTips,
                                onChanged: (value) =>
                                    setState(() => _dailyTips = value),
                              ),
                            ),
                            _SettingsRow(
                              icon: Icons.insights_rounded,
                              iconColor: AppColors.green,
                              iconBackground: const Color(0xFFD8F1E7),
                              title: 'Weekly summary',
                              subtitle: 'A recap of what you asked about',
                              trailing: _RowSwitch(
                                value: _weeklySummary,
                                onChanged: (value) =>
                                    setState(() => _weeklySummary = value),
                              ),
                            ),
                            _SettingsRow(
                              icon: Icons.language_rounded,
                              iconColor: AppColors.blue,
                              iconBackground: AppColors.sky,
                              title: 'Language',
                              value: 'English',
                              onTap: () => _showMessage('Language'),
                            ),
                            _SettingsRow(
                              icon: Icons.straighten_rounded,
                              iconColor: const Color(0xFF7657EB),
                              iconBackground: const Color(0xFFE7E1FB),
                              title: 'Units',
                              value: 'Metric',
                              onTap: () => _showMessage('Units'),
                            ),
                          ],
                        ),

                        const _GroupLabel('PRIVACY & DATA'),
                        _SettingsGroup(
                          children: [
                            _SettingsRow(
                              icon: Icons.lock_outline_rounded,
                              iconColor: AppColors.blue,
                              iconBackground: AppColors.sky,
                              title: 'Data & privacy',
                              subtitle: 'What we store and why',
                              onTap: () => _showMessage('Data & privacy'),
                            ),
                            _SettingsRow(
                              icon: Icons.download_rounded,
                              iconColor: AppColors.green,
                              iconBackground: const Color(0xFFD8F1E7),
                              title: 'Export my data',
                              onTap: () => _showMessage('Export my data'),
                            ),
                            _SettingsRow(
                              icon: Icons.delete_outline_rounded,
                              iconColor: AppColors.coral,
                              iconBackground: const Color(0xFFFCE1DF),
                              title: 'Delete account',
                              destructive: true,
                              onTap: _confirmDeleteAccount,
                            ),
                          ],
                        ),

                        const _GroupLabel('SUPPORT'),
                        _SettingsGroup(
                          children: [
                            _SettingsRow(
                              icon: Icons.help_outline_rounded,
                              iconColor: AppColors.lavender,
                              iconBackground: const Color(0xFFEEE6FF),
                              title: 'Help centre',
                              onTap: () => _showMessage('Help centre'),
                            ),
                            _SettingsRow(
                              icon: Icons.mail_outline_rounded,
                              iconColor: AppColors.blue,
                              iconBackground: AppColors.sky,
                              title: 'Contact support',
                              onTap: () => _showMessage('Contact support'),
                            ),
                            _SettingsRow(
                              icon: Icons.favorite_border_rounded,
                              iconColor: AppColors.coral,
                              iconBackground: const Color(0xFFFCE1DF),
                              title: 'Send feedback',
                              onTap: () => _showMessage('Send feedback'),
                            ),
                          ],
                        ),

                        const _GroupLabel('ABOUT'),
                        _SettingsGroup(
                          children: [
                            _SettingsRow(
                              icon: Icons.health_and_safety_outlined,
                              iconColor: AppColors.coral,
                              iconBackground: const Color(0xFFFCE1DF),
                              title: 'Medical disclaimer',
                              subtitle: 'Mother AI is not a doctor',
                              onTap: _showDisclaimer,
                            ),
                            _SettingsRow(
                              icon: Icons.description_outlined,
                              iconColor: AppColors.inkMuted,
                              iconBackground: const Color(0xFFEFF1F7),
                              title: 'Terms of service',
                              onTap: () => _showMessage('Terms of service'),
                            ),
                            _SettingsRow(
                              icon: Icons.policy_outlined,
                              iconColor: AppColors.inkMuted,
                              iconBackground: const Color(0xFFEFF1F7),
                              title: 'Privacy policy',
                              onTap: () => _showMessage('Privacy policy'),
                            ),
                            const _SettingsRow(
                              icon: Icons.info_outline_rounded,
                              iconColor: AppColors.inkMuted,
                              iconBackground: Color(0xFFEFF1F7),
                              title: 'Version',
                              value: '1.0.0',
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),
                        _SignOutButton(onPressed: _confirmSignOut),
                        const SizedBox(height: 18),
                        const Center(
                          child: Text(
                            'Made with ♡ for every parent',
                            style: TextStyle(
                              color: AppColors.whisper,
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Name, email and plan, with the avatar the rest of the app uses.
class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08263965),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8499F3), Color(0xFFC078D8)],
                ),
              ),
              child: const Text(
                'SM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sarah Mitchell',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'sarah.mitchell@email.com',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Member since March 2026',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFFEEE6FF),
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: AppColors.lavender,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navy,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onUpgrade,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8499F3), Color(0xFFC078D8)],
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mother AI Plus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Unlimited chats, deeper answers and no ads.',
                      style: TextStyle(
                        color: Color(0xFFB9C2DE),
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(
                    'Upgrade',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 26, 4, 10),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

/// One rounded card holding a run of rows, hair-lined between them.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08263965),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.white.withValues(alpha: 0.85),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 62),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.line,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    this.icon,
    this.iconColor,
    this.iconBackground,
    this.leading,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackground;

  /// Used instead of [icon] when a row needs a richer leading element.
  final Widget? leading;

  final String title;
  final String? subtitle;

  /// Right-aligned current setting, e.g. "English".
  final String? value;

  /// Replaces the chevron, e.g. with a switch.
  final Widget? trailing;

  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: 15.5,
      color: destructive ? AppColors.coral : AppColors.navy,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        child: Row(
          children: [
            leading ??
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 10),
              Text(
                value!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 13.5),
              ),
            ],
            const SizedBox(width: 6),
            trailing ??
                (onTap == null
                    ? const SizedBox.shrink()
                    : const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.inkMuted,
                        size: 22,
                      )),
          ],
        ),
      ),
    );
  }
}

class _RowSwitch extends StatelessWidget {
  const _RowSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _ChildAvatar extends StatelessWidget {
  const _ChildAvatar({required this.data});

  final _ChildEntry data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: data.background,
        shape: BoxShape.circle,
      ),
      child: Text(
        data.name[0],
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08263965),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.white.withValues(alpha: 0.85),
          child: InkWell(
            onTap: onPressed,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: AppColors.coral,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sign out',
                    style: TextStyle(
                      color: AppColors.coral,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileBackground extends StatelessWidget {
  const _ProfileBackground();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBF7FF), AppColors.background],
            stops: [0.0, 0.4],
          ),
        ),
      ),
    );
  }
}

class _ChildEntry {
  const _ChildEntry({
    required this.name,
    required this.age,
    required this.birthday,
    required this.background,
  });

  final String name;
  final String age;
  final String birthday;
  final Color background;
}
