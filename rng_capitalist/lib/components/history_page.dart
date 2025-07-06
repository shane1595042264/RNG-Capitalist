import 'package:flutter/material.dart';
import '../models/purchase_history.dart';
import '../utils/format_utils.dart';

class HistoryPage extends StatelessWidget {
  final List<PurchaseHistory> purchaseHistory;

  const HistoryPage({
    Key? key,
    required this.purchaseHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Purchase History',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFF323130),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your last ${purchaseHistory.length} decisions',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF605E5C),
            ),
          ),
          const SizedBox(height: 32),
          
          if (purchaseHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'No purchase decisions yet. Start consulting the Oracle!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF605E5C),
                  ),
                ),
              ),
            )
          else
            ...List.generate(
              purchaseHistory.length > 20 ? 20 : purchaseHistory.length,
              (index) {
                final item = purchaseHistory[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(
                        color: item.wasPurchased ? Colors.green : Colors.red,
                        width: 4,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.wasPurchased ? Icons.shopping_bag : Icons.block,
                        color: item.wasPurchased ? Colors.green : Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.itemName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${item.price.toStringAsFixed(2)} • ${FormatUtils.formatDate(item.date)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF605E5C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.wasPurchased ? 'BOUGHT' : 'SKIPPED',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: item.wasPurchased ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            '${(item.rollValue * 100).toStringAsFixed(1)}% vs ${(item.threshold * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF605E5C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
