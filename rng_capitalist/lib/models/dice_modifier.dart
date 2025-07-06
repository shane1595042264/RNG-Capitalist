// lib/models/dice_modifier.dart
import 'package:flutter/material.dart';

class DiceModifier {
  final String id;
  final String name;
  final String description;
  final int value;
  final IconData icon;
  final bool isActive;
  final ModifierType type;
  final bool isUnlocked;
  final String? unlockCondition;

  DiceModifier({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.icon,
    this.isActive = false,
    required this.type,
    this.isUnlocked = true,
    this.unlockCondition,
  });

  DiceModifier copyWith({
    String? id,
    String? name,
    String? description,
    int? value,
    IconData? icon,
    bool? isActive,
    ModifierType? type,
    bool? isUnlocked,
    String? unlockCondition,
  }) {
    return DiceModifier(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      value: value ?? this.value,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockCondition: unlockCondition ?? this.unlockCondition,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'value': value,
    'icon': icon.codePoint,
    'isActive': isActive,
    'type': type.toString(),
    'isUnlocked': isUnlocked,
    'unlockCondition': unlockCondition,
  };

  factory DiceModifier.fromJson(Map<String, dynamic> json) => DiceModifier(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    value: json['value'],
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    isActive: json['isActive'] ?? false,
    type: ModifierType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => ModifierType.general,
    ),
    isUnlocked: json['isUnlocked'] ?? true,
    unlockCondition: json['unlockCondition'],
  );

  // Static method to create preset modifiers
  static List<DiceModifier> getPresetModifiers() {
    return [
      DiceModifier(
        id: 'lucky',
        name: 'Lucky',
        description: 'Feeling lucky today!',
        value: 3,
        icon: Icons.star,
        type: ModifierType.general,
        isUnlocked: true,
      ),
      DiceModifier(
        id: 'payday',
        name: 'Payday',
        description: 'Just got paid!',
        value: 2,
        icon: Icons.attach_money,
        type: ModifierType.circumstance,
        isUnlocked: true,
      ),
      DiceModifier(
        id: 'stressed',
        name: 'Stressed',
        description: 'Retail therapy time',
        value: -2,
        icon: Icons.sentiment_very_dissatisfied,
        type: ModifierType.general,
        isUnlocked: true,
      ),
      DiceModifier(
        id: 'on_sale',
        name: 'On Sale',
        description: 'It\'s a bargain!',
        value: 1,
        icon: Icons.local_offer,
        type: ModifierType.circumstance,
        isUnlocked: true,
      ),
    ];
  }
}

enum ModifierType {
  general,
  skill,
  circumstance,
  magical,
  item,
}

extension ModifierTypeExtension on ModifierType {
  Color get color {
    switch (this) {
      case ModifierType.general:
        return Colors.blue;
      case ModifierType.skill:
        return Colors.green;
      case ModifierType.circumstance:
        return Colors.orange;
      case ModifierType.magical:
        return Colors.purple;
      case ModifierType.item:
        return Colors.brown;
    }
  }

  String get displayName {
    switch (this) {
      case ModifierType.general:
        return 'General';
      case ModifierType.skill:
        return 'Skill';
      case ModifierType.circumstance:
        return 'Circumstance';
      case ModifierType.magical:
        return 'Magical';
      case ModifierType.item:
        return 'Item';
    }
  }
}
