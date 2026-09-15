import 'package:flutter/material.dart';

/// The small amount of child context needed across Home, Chat and Profile.
///
/// Keeping this shared prevents each surface from inventing its own version of
/// the family and gives a chat an explicit person to be about.
class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.birthday,
    required this.avatarBackground,
    required this.cardStart,
    required this.cardEnd,
    required this.lastChatDate,
    required this.lastMessage,
  });

  final String id;
  final String name;
  final String age;
  final String birthday;
  final Color avatarBackground;
  final Color cardStart;
  final Color cardEnd;
  final String lastChatDate;
  final String lastMessage;
}

/// Placeholder family data used by this prototype until profiles come from
/// persistence/backend state.
const demoChildren = <ChildProfile>[
  ChildProfile(
    id: 'emma',
    name: 'Emma',
    age: '6 months old',
    birthday: 'Born 14 Mar 2026',
    avatarBackground: Color(0xFFFCE1DF),
    cardStart: Color(0xFFFFFDFC),
    cardEnd: Color(0xFFFFF3F0),
    lastChatDate: '12 Sep 2026',
    lastMessage: 'Fever after vaccines',
  ),
  ChildProfile(
    id: 'daniel',
    name: 'Daniel',
    age: '2 years old',
    birthday: 'Born 2 May 2024',
    avatarBackground: Color(0xFFE3E7FB),
    cardStart: Color(0xFFFCFDFF),
    cardEnd: Color(0xFFF1F3FF),
    lastChatDate: '10 Sep 2026',
    lastMessage: 'Bedtime routine help',
  ),
];
