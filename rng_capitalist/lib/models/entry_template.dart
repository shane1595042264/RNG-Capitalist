// lib/models/entry_template.dart
import 'dart:math';

String _generateTemplateId() {
  final random = Random();
  return DateTime.now().millisecondsSinceEpoch.toString() + 
         random.nextInt(1000).toString();
}

class EntryTemplate {
  final String id;
  final String name;
  final String description;
  final double? amount; // Optional preset amount
  final bool isAddition; // true for add, false for subtract
  final bool isDefault; // Default templates cannot be deleted
  final DateTime createdAt;

  EntryTemplate({
    String? id,
    required this.name,
    required this.description,
    this.amount,
    this.isAddition = true,
    this.isDefault = false,
    DateTime? createdAt,
  }) : id = id ?? _generateTemplateId(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'isAddition': isAddition,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EntryTemplate.fromJson(Map<String, dynamic> json) {
    return EntryTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      amount: json['amount']?.toDouble(),
      isAddition: json['isAddition'] ?? true,
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  EntryTemplate copyWith({
    String? name,
    String? description,
    double? amount,
    bool? isAddition,
    bool? isDefault,
  }) {
    return EntryTemplate(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isAddition: isAddition ?? this.isAddition,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }

  // Default templates
  static List<EntryTemplate> getDefaultTemplates() {
    return [
      EntryTemplate(
        id: 'default_rent',
        name: 'Monthly Rent',
        description: 'Monthly rent payment',
        amount: 1200.00, // Common rent amount as example
        isAddition: true,
        isDefault: true,
      ),
      EntryTemplate(
        id: 'default_groceries',
        name: 'Groceries',
        description: 'Food and household items',
        amount: 150.00,
        isAddition: true,
        isDefault: true,
      ),
      EntryTemplate(
        id: 'default_utilities',
        name: 'Utilities',
        description: 'Electric, water, internet, phone',
        amount: 200.00,
        isAddition: true,
        isDefault: true,
      ),
      EntryTemplate(
        id: 'default_transportation',
        name: 'Gas/Transport',
        description: 'Gas, public transit, parking',
        amount: 80.00,
        isAddition: true,
        isDefault: true,
      ),
      EntryTemplate(
        id: 'default_subscription',
        name: 'Subscription',
        description: 'Monthly subscription service',
        amount: 15.00,
        isAddition: true,
        isDefault: true,
      ),
      EntryTemplate(
        id: 'default_refund',
        name: 'Refund',
        description: 'Money back from returns or refunds',
        amount: 50.00,
        isAddition: false, // This is a subtraction
        isDefault: true,
      ),
      EntryTemplate(
        id: 'default_correction',
        name: 'Correction',
        description: 'Fixing an error or adjustment',
        amount: null, // No preset amount
        isAddition: false,
        isDefault: true,
      ),
    ];
  }
}
