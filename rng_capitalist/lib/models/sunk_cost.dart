// lib/models/sunk_cost.dart
import 'dart:math';

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

  SunkCost({
    String? id,
    required this.name,
    required this.amount,
    required this.category,
    this.isActive = true,
  }) : id = id ?? _generateId();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'isActive': isActive,
    };
  }

  factory SunkCost.fromJson(Map<String, dynamic> json) {
    return SunkCost(
      id: json['id'],
      name: json['name'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      isActive: json['isActive'] ?? true,
    );
  }

  SunkCost copyWith({
    String? name,
    double? amount,
    String? category,
    bool? isActive,
  }) {
    return SunkCost(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
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
