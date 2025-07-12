// lib/components/social_sharing_widget.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/smart_expense.dart';
import '../services/spending_analytics_service.dart';

class SocialSharingWidget extends StatefulWidget {
  final List<SmartExpense> expenses;

  const SocialSharingWidget({
    super.key,
    required this.expenses,
  });

  @override
  State<SocialSharingWidget> createState() => _SocialSharingWidgetState();
}

class _SocialSharingWidgetState extends State<SocialSharingWidget> {
  final SpendingAnalyticsService _analyticsService = SpendingAnalyticsService();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.share, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Share Budget Achievements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Share your D&D budget victories with your party members!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildShareButton(
                  'Monthly Summary',
                  Icons.calendar_month,
                  () => _shareMonthlySummary(),
                ),
                _buildShareButton(
                  'Budget Victory',
                  Icons.emoji_events,
                  () => _shareBudgetVictory(),
                ),
                _buildShareButton(
                  'D&D Spending',
                  Icons.casino,
                  () => _shareDnDSpending(),
                ),
                _buildShareButton(
                  'Savings Goal',
                  Icons.savings,
                  () => _shareSavingsGoal(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[50],
        foregroundColor: Colors.purple[700],
        elevation: 0,
      ),
    );
  }

  void _shareMonthlySummary() {
    final now = DateTime.now();
    final monthName = _getMonthName(now.month);
    final patterns = _analyticsService.analyzeSpendingPatterns(widget.expenses);
    
    // Calculate monthly totals
    final monthStart = DateTime(now.year, now.month, 1);
    final monthExpenses = widget.expenses.where((e) => e.date.isAfter(monthStart)).toList();
    final totalSpent = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final dndSpent = monthExpenses.where((e) => e.isDnDExpense).fold(0.0, (sum, e) => sum + e.amount);
    
    String topCategory = 'N/A';
    if (patterns.isNotEmpty) {
      topCategory = patterns.first.categoryName;
    }

    final message = '''
🎲 D&D Budget Report - $monthName ${now.year} 🎲

📊 Total Spending: \$${totalSpent.toStringAsFixed(2)}
🎮 D&D Expenses: \$${dndSpent.toStringAsFixed(2)}
🏆 Top Category: $topCategory
📱 Tracked with RNG Capitalist

Ready for the next adventure! 🗡️✨

#DnD #BudgetingLife #RPG #FinancialHealth
    ''';

    Share.share(message, subject: 'My D&D Budget Summary');
  }

  void _shareBudgetVictory() {
    final patterns = _analyticsService.analyzeSpendingPatterns(widget.expenses);
    final underBudgetCategories = patterns.where((p) => 
      p.budgetUtilization > 0 && p.budgetUtilization < 0.9
    ).toList();

    if (underBudgetCategories.isEmpty) {
      _showNoVictoryDialog();
      return;
    }

    final bestCategory = underBudgetCategories.reduce((a, b) => 
      a.budgetUtilization < b.budgetUtilization ? a : b
    );

    final savedAmount = bestCategory.budgetUtilization > 0 
        ? (1 - bestCategory.budgetUtilization) * (bestCategory.totalSpent / bestCategory.budgetUtilization)
        : 0;

    final message = '''
🏆 BUDGET VICTORY! 🏆

Successfully stayed under budget for ${bestCategory.categoryName}!

📊 Used only ${bestCategory.formattedBudgetUtilization} of my budget
💰 Saved approximately \$${savedAmount.toStringAsFixed(2)}
🎯 Goal achieved: Smart D&D spending

The party's financial wizard strikes again! 🧙‍♂️💰

#BudgetVictory #DnD #SmartSpending #RNGCapitalist
    ''';

    Share.share(message, subject: 'Budget Victory!');
  }

  void _shareDnDSpending() {
    final dndExpenses = widget.expenses.where((e) => e.isDnDExpense).toList();
    
    if (dndExpenses.isEmpty) {
      _showNoDnDExpensesDialog();
      return;
    }

    final totalDnD = dndExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final diceExpenses = dndExpenses.where((e) => e.category.id == 'dice').length;
    final bookExpenses = dndExpenses.where((e) => e.category.id == 'books').length;
    final miniExpenses = dndExpenses.where((e) => e.category.id == 'miniatures').length;

    final message = '''
🎲 My D&D Adventure Fund Report 🎲

💰 Total D&D Investment: \$${totalDnD.toStringAsFixed(2)}
🎯 Dice Sets: $diceExpenses purchases
📚 Books & Guides: $bookExpenses items
🏰 Miniatures: $miniExpenses models

Living the best adventurer life! ⚔️✨
Every coin spent brings new epic moments! 🌟

#DnD #TabletopGaming #RPGLife #AdventurerLifestyle
    ''';

    Share.share(message, subject: 'My D&D Adventure Fund');
  }

  void _shareSavingsGoal() {
    final patterns = _analyticsService.analyzeSpendingPatterns(widget.expenses);
    final totalBudget = patterns.fold(0.0, (sum, p) => sum + (p.budgetUtilization > 0 ? p.totalSpent / p.budgetUtilization : 0));
    final totalSpent = patterns.fold(0.0, (sum, p) => sum + p.totalSpent);
    final totalSaved = totalBudget - totalSpent;

    if (totalSaved <= 0) {
      _showNoSavingsDialog();
      return;
    }

    // Calculate what could be bought with savings
    String savingsGoal = '';
    if (totalSaved >= 100) {
      savingsGoal = 'a new D&D sourcebook collection';
    } else if (totalSaved >= 50) {
      savingsGoal = 'a premium dice set or miniature';
    } else if (totalSaved >= 25) {
      savingsGoal = 'some quality gaming accessories';
    } else {
      savingsGoal = 'a few more dice for the collection';
    }

    final message = '''
💰 SAVINGS MILESTONE ACHIEVED! 💰

I've saved \$${totalSaved.toStringAsFixed(2)} this month by staying under budget! 🎯

💡 That's enough for $savingsGoal!
📊 Budget discipline level: Expert Adventurer
🎲 Next goal: Even MORE epic D&D gear!

Smart spending = More adventures ahead! ⚔️✨

#SavingsGoal #DnD #BudgetingWin #SmartSpending
    ''';

    Share.share(message, subject: 'Savings Milestone Achieved!');
  }

  void _showNoVictoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Victory Yet'),
        content: const Text(
          'You don\'t have any budget victories to share yet. Keep tracking your expenses and stay under budget to unlock sharing achievements!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNoDnDExpensesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No D&D Expenses'),
        content: const Text(
          'You haven\'t tracked any D&D expenses yet. Start adding your gaming purchases to share your adventure fund!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNoSavingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Savings Yet'),
        content: const Text(
          'You haven\'t achieved any savings goals yet. Try staying under budget in some categories to unlock savings achievements!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

// Achievement badges widget
class AchievementBadges extends StatelessWidget {
  final List<SmartExpense> expenses;

  const AchievementBadges({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = _calculateAchievements();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Achievements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: achievements.map((achievement) => _buildBadge(achievement)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Achievement achievement) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.isUnlocked ? Colors.amber : Colors.grey,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            achievement.icon,
            size: 16,
            color: achievement.isUnlocked ? Colors.amber[700] : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            achievement.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: achievement.isUnlocked ? Colors.amber[700] : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<Achievement> _calculateAchievements() {
    final dndExpenses = expenses.where((e) => e.isDnDExpense).toList();
    final totalExpenses = expenses.length;
    final totalDnDSpent = dndExpenses.fold(0.0, (sum, e) => sum + e.amount);

    return [
      Achievement(
        name: 'First Roll',
        icon: Icons.casino,
        isUnlocked: dndExpenses.isNotEmpty,
      ),
      Achievement(
        name: 'Dice Collector',
        icon: Icons.hexagon,
        isUnlocked: dndExpenses.where((e) => e.category.id == 'dice').length >= 3,
      ),
      Achievement(
        name: 'Bookworm',
        icon: Icons.menu_book,
        isUnlocked: dndExpenses.where((e) => e.category.id == 'books').length >= 2,
      ),
      Achievement(
        name: 'Miniature Master',
        icon: Icons.castle,
        isUnlocked: dndExpenses.where((e) => e.category.id == 'miniatures').length >= 5,
      ),
      Achievement(
        name: 'Budget Tracker',
        icon: Icons.track_changes,
        isUnlocked: totalExpenses >= 10,
      ),
      Achievement(
        name: 'Big Spender',
        icon: Icons.attach_money,
        isUnlocked: totalDnDSpent >= 200,
      ),
      Achievement(
        name: 'Party Financier',
        icon: Icons.group,
        isUnlocked: dndExpenses.where((e) => e.category.id == 'food_gaming').length >= 5,
      ),
    ];
  }
}

class Achievement {
  final String name;
  final IconData icon;
  final bool isUnlocked;

  const Achievement({
    required this.name,
    required this.icon,
    required this.isUnlocked,
  });
}
