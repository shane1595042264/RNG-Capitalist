// lib/models/sunk_cost_entry.dart
import 'dart:math';

String _generateEntryId() {
  final random = Random();
  return DateTime.now().millisecondsSinceEpoch.toString() + 
         random.nextInt(1000).toString();
}

class SunkCostEntry {
  final String id;
  final double amount;
  final String note;
  final DateTime createdAt;
  final String? category; // Optional subcategory for the entry

  SunkCostEntry({
    String? id,
    required this.amount,
    required this.note,
    DateTime? createdAt,
    this.category,
  }) : id = id ?? _generateEntryId(),
        createdAt = createdAt ?? DateTime.now();

  // Helper methods to check entry type
  bool get isAddition => amount >= 0;
  bool get isSubtraction => amount < 0;
  double get absoluteAmount => amount.abs();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }

  factory SunkCostEntry.fromJson(Map<String, dynamic> json) {
    return SunkCostEntry(
      id: json['id'],
      amount: json['amount'].toDouble(),
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
      category: json['category'],
    );
  }

  SunkCostEntry copyWith({
    double? amount,
    String? note,
    DateTime? createdAt,
    String? category,
  }) {
    return SunkCostEntry(
      id: id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SunkCostEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
