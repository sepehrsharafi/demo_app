import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The menu a text field shows over a selection: cut, copy, paste and select
/// all, and nothing else.
///
/// Android also offers every installed app that "processes text" (other AI
/// assistants, translators, search), which turned a four-item menu into a
/// long list that has nothing to do with Mother AI. The manifest no longer
/// asks to see those apps; this also leaves them out on phones old enough
/// to show them anyway, along with look up, web search and share.
///
/// Pass it as every field's `contextMenuBuilder`.
Widget textMenu(BuildContext context, EditableTextState field) {
  final value = field.textEditingValue;
  final selection = value.selection;
  final selected = selection.isValid && !selection.isCollapsed;
  final everything =
      selected && selection.start == 0 && selection.end == value.text.length;
  final labels = MaterialLocalizations.of(context);
  final items = [
    for (final item in field.contextMenuButtonItems)
      if (switch (item.type) {
        ContextMenuButtonType.cut || ContextMenuButtonType.copy => selected,
        ContextMenuButtonType.paste => true,
        ContextMenuButtonType.selectAll => !everything,
        _ => false,
      })
        (
          item,
          switch (item.type) {
            ContextMenuButtonType.cut => labels.cutButtonLabel,
            ContextMenuButtonType.copy => labels.copyButtonLabel,
            ContextMenuButtonType.paste => labels.pasteButtonLabel,
            _ => labels.selectAllButtonLabel,
          },
        ),
  ];
  if (items.isEmpty) return const SizedBox.shrink();
  return FocusScope(
    // Taking focus from the field would close the menu before it shows.
    canRequestFocus: false,
    child: ShadContextMenu(
      visible: true,
      anchor: ShadGlobalAnchor(field.contextMenuAnchors.primaryAnchor),
      items: [
        for (final (item, label) in items)
          ShadContextMenuItem(
            onTapDown: item.onPressed == null
                ? null
                : (_) {
                    item.onPressed!();
                    // So cut or copy can follow straight after.
                    if (item.type == ContextMenuButtonType.selectAll) {
                      field.showToolbar();
                    }
                  },
            child: Text(label),
          ),
      ],
      child: const SizedBox.shrink(),
    ),
  );
}
