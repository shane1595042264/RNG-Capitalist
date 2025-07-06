class PurchaseHistory {
  final String id;
  final String itemName;
  final double price;
  final DateTime date;
  final bool wasPurchased;
  final double threshold;
  final double rollValue;

  PurchaseHistory({
    required this.id,
    required this.itemName,
    required this.price,
    required this.date,
    required this.wasPurchased,
    required this.threshold,
    required this.rollValue,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemName': itemName,
    'price': price,
    'date': date.toIso8601String(),
    'wasPurchased': wasPurchased,
    'threshold': threshold,
    'rollValue': rollValue,
  };

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) => PurchaseHistory(
    id: json['id'],
    itemName: json['itemName'],
    price: json['price'],
    date: DateTime.parse(json['date']),
    wasPurchased: json['wasPurchased'],
    threshold: json['threshold'],
    rollValue: json['rollValue'],
  );
}
