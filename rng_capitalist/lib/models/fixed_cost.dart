class FixedCost {
  final String id;
  final String name;
  final double amount;
  final String category;
  final bool isActive;

  FixedCost({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'category': category,
    'isActive': isActive,
  };

  factory FixedCost.fromJson(Map<String, dynamic> json) => FixedCost(
    id: json['id'],
    name: json['name'],
    amount: json['amount'],
    category: json['category'],
    isActive: json['isActive'] ?? true,
  );
}
