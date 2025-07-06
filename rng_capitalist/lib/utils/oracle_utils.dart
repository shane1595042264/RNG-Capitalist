import 'dart:math';
import '../models/purchase_history.dart';

class DecisionResult {
  final bool shouldBuy;
  final String decisionText;
  final String explanationText;
  final String statsText;
  final PurchaseHistory historyItem;

  DecisionResult({
    required this.shouldBuy,
    required this.decisionText,
    required this.explanationText,
    required this.statsText,
    required this.historyItem,
  });
}

class OracleUtils {
  static DecisionResult consultOracle({
    required double balance,
    required double fixedCosts,
    required double price,
    required String itemName,
    required double lastMonthSpend,
    required double strictnessLevel,
  }) {
    // Calculate remaining budget (available budget - fixed costs)
    final availableBudget = balance - lastMonthSpend;
    final remainingBudget = availableBudget - fixedCosts;
    
    // Validation
    if (balance <= 0 || price <= 0) {
      return _createErrorResult(
        'INVALID INPUT',
        'Please enter valid amounts!',
        '',
        itemName,
        price,
      );
    }
    
    if (price > remainingBudget) {
      return _createErrorResult(
        'NO WAY!',
        remainingBudget <= 0 
            ? 'No remaining budget after fixed costs!'
            : 'This would exceed your remaining budget!',
        'Remaining Budget: \$${remainingBudget.toStringAsFixed(2)}',
        itemName,
        price,
      );
    }
    
    // New RNG Logic based on remaining budget
    // Pure price ratio with strictness multiplier (no base threshold)
    final priceRatio = remainingBudget > 0 ? (price / remainingBudget).clamp(0.0, 1.0) : 1.0;
    final threshold = strictnessLevel * priceRatio; // Pure strictness * price ratio
    final randomValue = Random().nextDouble();
    final shouldBuy = randomValue > threshold;
    
    // Create history item
    final historyItem = PurchaseHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: itemName.isEmpty ? 'Unknown Item' : itemName,
      price: price,
      date: DateTime.now(),
      wasPurchased: shouldBuy,
      threshold: threshold,
      rollValue: randomValue,
    );
    
    // Generate responses
    final buyMessages = [
      'Life is short, money is fake!',
      'You only live once!',
      'Future you can deal with it!',
      'The universe has spoken!',
      'Treat yourself, champion!',
      'Money comes and goes!'
    ];
    
    final skipMessages = [
      'Your wallet thanks you.',
      'The stars say not today.',
      'Save it for something better!',
      'Future you will be grateful.',
      'The universe is protecting you.',
      'Not meant to be... this time.'
    ];
    
    return DecisionResult(
      shouldBuy: shouldBuy,
      decisionText: shouldBuy ? 'BUY IT!' : 'SKIP IT!',
      explanationText: shouldBuy 
          ? buyMessages[Random().nextInt(buyMessages.length)]
          : skipMessages[Random().nextInt(skipMessages.length)],
      statsText: 'RNG rolled ${(randomValue * 100).toStringAsFixed(1)}% ${shouldBuy ? '>' : '<'} ${(threshold * 100).toStringAsFixed(1)}%\nPrice is ${(priceRatio * 100).toStringAsFixed(1)}% of remaining budget',
      historyItem: historyItem,
    );
  }

  static DecisionResult _createErrorResult(
    String decisionText,
    String explanationText,
    String statsText,
    String itemName,
    double price,
  ) {
    return DecisionResult(
      shouldBuy: false,
      decisionText: decisionText,
      explanationText: explanationText,
      statsText: statsText,
      historyItem: PurchaseHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemName: itemName.isEmpty ? 'Unknown Item' : itemName,
        price: price,
        date: DateTime.now(),
        wasPurchased: false,
        threshold: 0.0,
        rollValue: 0.0,
      ),
    );
  }
}
