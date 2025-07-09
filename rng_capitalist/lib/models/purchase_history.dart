class PurchaseHistory {
  final String id;
  final String itemName;
  final double price;
  final DateTime date;
  final bool wasPurchased;
  final double threshold;
  final double rollValue;
  final double? availableBudget; // Budget available at time of purchase
  final DateTime? cooldownUntil; // When cooldown expires (only for rejected items)

  PurchaseHistory({
    required this.id,
    required this.itemName,
    required this.price,
    required this.date,
    required this.wasPurchased,
    required this.threshold,
    required this.rollValue,
    this.availableBudget,
    this.cooldownUntil,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemName': itemName,
    'price': price,
    'date': date.toIso8601String(),
    'wasPurchased': wasPurchased,
    'threshold': threshold,
    'rollValue': rollValue,
    'availableBudget': availableBudget,
    'cooldownUntil': cooldownUntil?.toIso8601String(),
  };

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) => PurchaseHistory(
    id: json['id'],
    itemName: json['itemName'],
    price: json['price'],
    date: DateTime.parse(json['date']),
    wasPurchased: json['wasPurchased'],
    threshold: json['threshold'],
    rollValue: json['rollValue'],
    availableBudget: json['availableBudget'],
    cooldownUntil: json['cooldownUntil'] != null ? DateTime.parse(json['cooldownUntil']) : null,
  );

  /// Calculates cooldown period for a rejected item based on price/budget ratio
  static DateTime calculateCooldownUntil(double price, double availableBudget) {
    if (availableBudget <= 0) return DateTime.now().add(const Duration(days: 365));
    
    final ratio = price / availableBudget;
    final cooldownDays = (ratio * 365 + 1).round(); // minimum 1 day, max around 1 year
    const maxCooldown = 365; // cap at 1 year
    
    final actualCooldownDays = cooldownDays > maxCooldown ? maxCooldown : cooldownDays;
    return DateTime.now().add(Duration(days: actualCooldownDays));
  }

  /// Check if this item is currently on cooldown
  bool get isOnCooldown {
    if (wasPurchased || cooldownUntil == null) return false;
    return DateTime.now().isBefore(cooldownUntil!);
  }

  /// Get remaining cooldown time
  Duration? get remainingCooldown {
    if (!isOnCooldown) return null;
    return cooldownUntil!.difference(DateTime.now());
  }

  /// Create a copy with updated cooldown
  PurchaseHistory copyWith({
    String? id,
    String? itemName,
    double? price,
    DateTime? date,
    bool? wasPurchased,
    double? threshold,
    double? rollValue,
    double? availableBudget,
    DateTime? cooldownUntil,
  }) {
    return PurchaseHistory(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      price: price ?? this.price,
      date: date ?? this.date,
      wasPurchased: wasPurchased ?? this.wasPurchased,
      threshold: threshold ?? this.threshold,
      rollValue: rollValue ?? this.rollValue,
      availableBudget: availableBudget ?? this.availableBudget,
      cooldownUntil: cooldownUntil ?? this.cooldownUntil,
    );
  }
}
