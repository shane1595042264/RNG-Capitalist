// Test file to verify cooldown functionality
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/purchase_history.dart';
import '../lib/utils/format_utils.dart';

void main() {
  group('Cooldown System Tests', () {
    test('Calculate cooldown for different price/budget ratios', () {
      // Test case 1: $10 item with $100 budget (10% ratio)
      final cooldown1 = PurchaseHistory.calculateCooldownUntil(10.0, 100.0);
      final expectedDays1 = (0.1 * 365 + 1).round(); // 37.5 -> 38 days
      expect(cooldown1.isAfter(DateTime.now().add(Duration(days: expectedDays1 - 1))), true);
      expect(cooldown1.isBefore(DateTime.now().add(Duration(days: expectedDays1 + 1))), true);
      
      // Test case 2: $50 item with $100 budget (50% ratio)
      final cooldown2 = PurchaseHistory.calculateCooldownUntil(50.0, 100.0);
      final expectedDays2 = (0.5 * 365 + 1).round(); // 183.5 -> 184 days
      expect(cooldown2.isAfter(DateTime.now().add(Duration(days: expectedDays2 - 1))), true);
      expect(cooldown2.isBefore(DateTime.now().add(Duration(days: expectedDays2 + 1))), true);
      
      // Test case 3: $100 item with $100 budget (100% ratio)
      final cooldown3 = PurchaseHistory.calculateCooldownUntil(100.0, 100.0);
      final expectedDays3 = (1.0 * 365 + 1).round(); // 366 days (capped at 365)
      expect(cooldown3.isAfter(DateTime.now().add(const Duration(days: 364))), true);
      expect(cooldown3.isBefore(DateTime.now().add(const Duration(days: 366))), true);
    });

    test('Minimum cooldown is 1 day', () {
      // Test very small item price
      final cooldown = PurchaseHistory.calculateCooldownUntil(0.01, 1000.0);
      expect(cooldown.isAfter(DateTime.now()), true);
      expect(cooldown.isBefore(DateTime.now().add(const Duration(days: 2))), true);
    });

    test('Maximum cooldown is 1 year', () {
      // Test very expensive item
      final cooldown = PurchaseHistory.calculateCooldownUntil(1000.0, 10.0);
      expect(cooldown.isAfter(DateTime.now().add(const Duration(days: 364))), true);
      expect(cooldown.isBefore(DateTime.now().add(const Duration(days: 366))), true);
    });

    test('Zero budget defaults to maximum cooldown', () {
      final cooldown = PurchaseHistory.calculateCooldownUntil(50.0, 0.0);
      expect(cooldown.isAfter(DateTime.now().add(const Duration(days: 364))), true);
      expect(cooldown.isBefore(DateTime.now().add(const Duration(days: 366))), true);
    });

    test('isOnCooldown works correctly', () {
      // Create a rejected item with cooldown
      final rejectedItem = PurchaseHistory(
        id: '1',
        itemName: 'Test Item',
        price: 10.0,
        date: DateTime.now(),
        wasPurchased: false,
        threshold: 0.5,
        rollValue: 0.3,
        availableBudget: 100.0,
        cooldownUntil: DateTime.now().add(const Duration(days: 1)),
      );
      
      expect(rejectedItem.isOnCooldown, true);
      expect(rejectedItem.remainingCooldown, isNotNull);
      
      // Create a purchased item (should not be on cooldown)
      final purchasedItem = PurchaseHistory(
        id: '2',
        itemName: 'Purchased Item',
        price: 10.0,
        date: DateTime.now(),
        wasPurchased: true,
        threshold: 0.5,
        rollValue: 0.7,
        availableBudget: 100.0,
        cooldownUntil: null,
      );
      
      expect(purchasedItem.isOnCooldown, false);
      expect(purchasedItem.remainingCooldown, isNull);
    });

    test('Format cooldown duration correctly', () {
      expect(FormatUtils.formatCooldownDuration(const Duration(days: 400)), '~1 year');
      expect(FormatUtils.formatCooldownDuration(const Duration(days: 60)), '2 months');
      expect(FormatUtils.formatCooldownDuration(const Duration(days: 14)), '2 weeks');
      expect(FormatUtils.formatCooldownDuration(const Duration(days: 1)), '1 day');
      expect(FormatUtils.formatCooldownDuration(const Duration(hours: 5)), '5 hours');
      expect(FormatUtils.formatCooldownDuration(const Duration(minutes: 30)), '30 minutes');
      expect(FormatUtils.formatCooldownDuration(const Duration(seconds: 30)), 'Less than a minute');
    });
  });
}
