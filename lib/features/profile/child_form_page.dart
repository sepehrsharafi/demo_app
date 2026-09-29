import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/data/app_scope.dart';
import '../../core/l10n/l10n.dart';
import '../../core/l10n/text_direction.dart';
import '../../core/models/child_profile.dart';
import '../../core/models/context_note.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/sheet_depth.dart';
import '../../core/widgets/demo_toast.dart';
import '../../core/widgets/directional_icons.dart';
import '../../core/widgets/text_menu.dart';

/// Adds a child, or changes what Mother AI knows about [child]. Resolves
/// to the saved child, or null if the parent backed out or removed them.
Future<ChildProfile?> editChild(BuildContext context, {ChildProfile? child}) =>
    Navigator.of(context).push<ChildProfile>(
      MaterialPageRoute(builder: (_) => ChildFormPage(child: child)),
    );

/// A name and a birthday are all Mother AI needs; the health details are
/// there for the parent who wants answers to take them into account, and
/// the context is what Mother AI has picked up from chats, for the parent
/// to correct.
class ChildFormPage extends StatefulWidget {
  const ChildFormPage({super.key, this.child});

  final ChildProfile? child;

  @override
  State<ChildFormPage> createState() => _ChildFormPageState();
}

class _ChildFormPageState extends State<ChildFormPage> {
  final _form = GlobalKey<ShadFormState>();
  bool _saving = false;

  /// The child's context as it was when the page opened, each note with
  /// the field it is edited in. Removing one takes it out of this list.
  late final List<(ContextNote, TextEditingController)> _notes;
  final _removed = <int>{};

  static const _destructive = Color(0xFFD92D40);

  @override
  void initState() {
    super.initState();
    final store = AppScope.of(context, listen: false);
    _notes = [
      for (final note in store.contextOf(widget.child))
        (note, TextEditingController(text: note.text)),
    ];
  }

  @override
  void dispose() {
    for (final (_, field) in _notes) {
      field.dispose();
    }
    super.dispose();
  }

  /// What the parent changed in the context: rewritten notes, and the ones
  /// removed or emptied.
  ContextUpdate get _contextChanges {
    final edited = <int, String>{};
    final removed = {..._removed};
    for (final (note, field) in _notes) {
      final text = field.text.trim();
      if (text.isEmpty) {
        removed.add(note.id);
      } else if (text != note.text) {
        edited[note.id] = text;
      }
    }
    return ContextUpdate(edited: edited, removed: removed);
  }

  Future<void> _save() async {
    final form = _form.currentState!;
    if (_saving || !form.saveAndValidate()) return;
    final value = form.value;
    setState(() => _saving = true);
    try {
      final store = AppScope.of(context, listen: false);
      final saved = await store.saveChild(
        id: widget.child?.id,
        name: value['name'] as String,
        birthday: value['birthday'] as DateTime,
        allergies: value['allergies'] as String?,
        conditions: value['conditions'] as String?,
        medications: value['medications'] as String?,
        notes: value['notes'] as String?,
      );
      await store.reviseContext(saved, _contextChanges);
      if (mounted) Navigator.of(context).pop(saved);
    } catch (error) {
      debugPrint('Couldn’t save the child: $error');
      if (!mounted) return;
      setState(() => _saving = false);
      showDemoToast(
        context,
        title: context.tr('That didn’t save'),
        description: context.tr('Try again.'),
      );
    }
  }

  Future<void> _remove(ChildProfile child) async {
    final confirmed = await showAppDialog<bool>(
      context,
      builder: (context) => ShadDialog.alert(
        title: Text(context.tr('Remove {name}?', {'name': child.name})),
        description: Text(
          context.tr(
            'Their details and every chat about them are deleted. This can’t '
            'be undone.',
          ),
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('Cancel')),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.tr('Remove')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AppScope.of(context, listen: false).removeChild(child);
    if (mounted) Navigator.of(context).pop();
  }

  void _forget(ContextNote note) {
    setState(() {
      final i = _notes.indexWhere((entry) => entry.$1 == note);
      _notes.removeAt(i).$2.dispose();
      _removed.add(note.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final today = DateUtils.dateOnly(DateTime.now());
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                _Header(
                  title: child == null ? context.tr('Add a child') : child.name,
                ),
                Expanded(
                  child: ShadForm(
                    key: _form,
                    initialValue: {
                      'name': child?.name ?? '',
                      'birthday': child?.birthday,
                      'allergies': child?.allergies ?? '',
                      'conditions': child?.conditions ?? '',
                      'medications': child?.medications ?? '',
                      'notes': child?.notes ?? '',
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      children: [
                        ShadInputFormField(
                          id: 'name',
                          label: Text(context.tr('Name')),
                          placeholder: Text(
                            context.tr('First name or nickname'),
                          ),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          maxLength: 40,
                          contextMenuBuilder: textMenu,
                          validator: (name) => name.trim().isEmpty
                              ? context.tr('Add their name.')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        ShadDatePickerFormField(
                          id: 'birthday',
                          label: Text(context.tr('Date of birth')),
                          placeholder: Text(context.tr('Choose a date')),
                          width: double.infinity,
                          captionLayout: ShadCalendarCaptionLayout.dropdown,
                          fromMonth: DateTime(today.year - 18, today.month),
                          toMonth: DateTime(today.year, today.month),
                          initialMonth: child?.birthday,
                          selectableDayPredicate: (day) => !day.isAfter(today),
                          formatDate: context.l10n.date,
                          validator: (day) => day == null
                              ? context.tr('Add their date of birth.')
                              : null,
                        ),
                        const SizedBox(height: 36),
                        _SectionHead(
                          title: context.tr('Health details'),
                          description: context.tr(
                            'Optional. Mother AI keeps these in mind when you '
                            'ask about them.',
                          ),
                        ),
                        _Detail(
                          id: 'allergies',
                          label: context.tr('Allergies'),
                          hint: context.tr('Peanuts, penicillin'),
                          description: context.tr(
                            'What they react to, and how.',
                          ),
                        ),
                        _Detail(
                          id: 'conditions',
                          label: context.tr('Conditions'),
                          hint: context.tr('Eczema, asthma'),
                          description: context.tr(
                            'Anything a doctor has diagnosed.',
                          ),
                        ),
                        _Detail(
                          id: 'medications',
                          label: context.tr('Medicines'),
                          hint: context.tr('Vitamin D drops'),
                          description: context.tr(
                            'What they take, and how often.',
                          ),
                        ),
                        _Detail(
                          id: 'notes',
                          label: context.tr('Notes'),
                          hint: context.tr('Anything else worth knowing'),
                          lines: 4,
                        ),
                        if (child != null) ...[
                          const SizedBox(height: 20),
                          _SectionHead(
                            title: context.tr('Context'),
                            description: context.tr(
                              'What Mother AI has picked up from your chats. '
                              'It keeps this up to date as you talk; change '
                              'or remove anything that isn’t right.',
                            ),
                          ),
                          if (_notes.isEmpty)
                            Text(
                              context.tr(
                                'Nothing yet. What you tell Mother AI about '
                                '{name} will show up here.',
                                {'name': child.name},
                              ),
                              style: AppText.body.copyWith(
                                fontSize: 15,
                                color: AppColors.muted,
                              ),
                            )
                          else
                            for (final (note, field) in _notes)
                              _NoteField(
                                key: ObjectKey(note),
                                note: note,
                                controller: field,
                                onRemove: () => _forget(note),
                              ),
                          const SizedBox(height: 28),
                          ShadButton.ghost(
                            foregroundColor: _destructive,
                            hoverForegroundColor: _destructive,
                            leading: const Icon(LucideIcons.trash2, size: 18),
                            onPressed: () => _remove(child),
                            child: Text(
                              context.tr('Remove {name}', {'name': child.name}),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: ShadButton(
                    size: ShadButtonSize.lg,
                    width: double.infinity,
                    textStyle: AppText.button,
                    onPressed: _saving ? null : _save,
                    child: Text(
                      context.tr(child == null ? 'Add child' : 'Save'),
                    ),
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

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 16, 6),
        child: Row(
          children: [
            ShadIconButton.ghost(
              width: 44,
              height: 44,
              iconSize: 22,
              icon: Icon(
                context.backChevron,
                semanticLabel: context.tr('Back'),
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.rowTitle.copyWith(fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A part of the form: its heading and what it is for.
class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: AppText.section)),
          const SizedBox(height: 4),
          Text(description, style: AppText.secondary),
        ],
      ),
    );
  }
}

/// One optional health detail, in the parent's own words. Allergies can be
/// a word or a few sentences ("peanuts: hives within minutes"), so each
/// field starts two lines tall and grows as they write.
class _Detail extends StatelessWidget {
  const _Detail({
    required this.id,
    required this.label,
    required this.hint,
    this.description,
    this.lines = 2,
  });

  final String id;
  final String label;
  final String hint;
  final String? description;

  /// How tall it starts; it grows to twice that before it scrolls.
  final int lines;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ShadInputFormField(
        id: id,
        label: Text(label),
        placeholder: Text(hint),
        description: description == null ? null : Text(description),
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        textCapitalization: TextCapitalization.sentences,
        minLines: lines,
        maxLines: lines * 2,
        maxLength: 300,
        contextMenuBuilder: textMenu,
      ),
    );
  }
}

/// A note from the child's context, as a field the parent can correct,
/// with a way to remove it altogether.
class _NoteField extends StatelessWidget {
  const _NoteField({
    super.key,
    required this.note,
    required this.controller,
    required this.onRemove,
  });

  final ContextNote note;
  final TextEditingController controller;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadInput(
                  controller: controller,
                  textDirection: directionOfText(note.text),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: 200,
                  contextMenuBuilder: textMenu,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 2),
                  child: Text(
                    context.l10n.date(note.updatedAt),
                    style: AppText.figure,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          ShadIconButton.ghost(
            width: 44,
            height: 44,
            iconSize: 18,
            foregroundColor: AppColors.muted,
            icon: Icon(
              LucideIcons.x,
              semanticLabel: context.tr('Remove this note'),
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
