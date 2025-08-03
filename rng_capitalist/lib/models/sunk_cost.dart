// lib/models/sunk_cost.dart
import 'dart:math';
import 'sunk_cost_entry.dart';

String _generateId() {
  final random = Random();
  return DateTime.now().millisecondsSinceEpoch.toString() + 
         random.nextInt(1000).toString();
}

class SunkCost {
  final String id;
  final String name;
  final double amount;
  final String category;
  final bool isActive;
  final List<SunkCostEntry> entries;

  SunkCost({
    String? id,
    required this.name,
    required this.amount,
    required this.category,
    this.isActive = true,
    List<SunkCostEntry>? entries,
  }) : id = id ?? _generateId(),
        entries = entries ?? [];

  /// Total amount including all entries
  double get totalAmount {
    final entriesTotal = entries.fold(0.0, (sum, entry) => sum + entry.amount);
    return amount + entriesTotal;
  }

  /// Get the base amount (original sunk cost amount)
  double get baseAmount => amount;

  /// Get the total amount from entries only
  double get entriesAmount {
    return entries.fold(0.0, (sum, entry) => sum + entry.amount);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'isActive': isActive,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
  }

  factory SunkCost.fromJson(Map<String, dynamic> json) {
    return SunkCost(
      id: json['id'],
      name: json['name'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      isActive: json['isActive'] ?? true,
      entries: (json['entries'] as List<dynamic>?)
          ?.map((entryJson) => SunkCostEntry.fromJson(entryJson))
          .toList() ?? [],
    );
  }

  SunkCost copyWith({
    String? name,
    double? amount,
    String? category,
    bool? isActive,
    List<SunkCostEntry>? entries,
  }) {
    return SunkCost(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      entries: entries ?? List.from(this.entries),
    );
  }

  /// Add a new entry to this sunk cost
  SunkCost addEntry(SunkCostEntry entry) {
    final newEntries = List<SunkCostEntry>.from(entries);
    newEntries.add(entry);
    return copyWith(entries: newEntries);
  }

  /// Remove an entry from this sunk cost
  SunkCost removeEntry(String entryId) {
    final newEntries = entries.where((entry) => entry.id != entryId).toList();
    return copyWith(entries: newEntries);
  }

  /// Update an entry in this sunk cost
  SunkCost updateEntry(SunkCostEntry updatedEntry) {
    final newEntries = entries.map((entry) {
      return entry.id == updatedEntry.id ? updatedEntry : entry;
    }).toList();
    return copyWith(entries: newEntries);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SunkCost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Schedule time period model
class SchedulePeriod {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final SunkCost sunkCost;
  final String activity;

  SchedulePeriod({
    String? id,
    required this.startTime,
    required this.endTime,
    required this.sunkCost,
    required this.activity,
  }) : id = id ?? _generateId();

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'sunkCost': sunkCost.toJson(),
      'activity': activity,
    };
  }

  factory SchedulePeriod.fromJson(Map<String, dynamic> json) {
    return SchedulePeriod(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      sunkCost: SunkCost.fromJson(json['sunkCost']),
      activity: json['activity'],
    );
  }
}

// Daily schedule model
class DailySchedule {
  final String id;
  final DateTime date;
  final List<SchedulePeriod> periods;
  final double totalSunkCostValue;

  DailySchedule({
    String? id,
    required this.date,
    required this.periods,
    required this.totalSunkCostValue,
  }) : id = id ?? _generateId();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'periods': periods.map((p) => p.toJson()).toList(),
      'totalSunkCostValue': totalSunkCostValue,
    };
  }

  factory DailySchedule.fromJson(Map<String, dynamic> json) {
    return DailySchedule(
      id: json['id'],
      date: DateTime.parse(json['date']),
      periods: (json['periods'] as List)
          .map((p) => SchedulePeriod.fromJson(p))
          .toList(),
      totalSunkCostValue: json['totalSunkCostValue'].toDouble(),
    );
  }
}
