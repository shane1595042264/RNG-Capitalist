import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const RNGCapitalistApp());
}

class RNGCapitalistApp extends StatelessWidget {
  const RNGCapitalistApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNG Capitalist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0078D4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// Data models for Phase 2
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _balanceController = TextEditingController();
  final _fixedCostsController = TextEditingController();
  final _priceController = TextEditingController();
  final _itemNameController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _showResult = false;
  bool _shouldBuy = false;
  String _decisionText = '';
  String _explanationText = '';
  String _statsText = '';
  
  // Phase 2 additions
  double _strictnessLevel = 0.70; // Default strictness
  List<FixedCost> _fixedCosts = [];
  List<PurchaseHistory> _purchaseHistory = [];
  String _currentPage = 'Oracle';
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _strictnessLevel = prefs.getDouble('strictness') ?? 0.70;
      _balanceController.text = prefs.getString('lastBalance') ?? '';
      
      // Load fixed costs
      final fixedCostsJson = prefs.getStringList('fixedCosts') ?? [];
      _fixedCosts = fixedCostsJson.map((json) => FixedCost.fromJson(jsonDecode(json))).toList();
      
      // Load purchase history
      final historyJson = prefs.getStringList('purchaseHistory') ?? [];
      _purchaseHistory = historyJson.map((json) => PurchaseHistory.fromJson(jsonDecode(json))).toList();
    });
    _calculateTotalFixedCosts();
  }
  
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('strictness', _strictnessLevel);
    await prefs.setString('lastBalance', _balanceController.text);
    
    // Save fixed costs
    final fixedCostsJson = _fixedCosts.map((cost) => jsonEncode(cost.toJson())).toList();
    await prefs.setStringList('fixedCosts', fixedCostsJson);
    
    // Save purchase history
    final historyJson = _purchaseHistory.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('purchaseHistory', historyJson);
  }
  
  void _calculateTotalFixedCosts() {
    double total = 0;
    for (var cost in _fixedCosts.where((c) => c.isActive)) {
      total += cost.amount;
    }
    _fixedCostsController.text = total.toStringAsFixed(2);
  }
  
  @override
  void dispose() {
    _balanceController.dispose();
    _fixedCostsController.dispose();
    _priceController.dispose();
    _itemNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _consultOracle() {
    final balance = double.tryParse(_balanceController.text) ?? 0;
    final fixedCosts = double.tryParse(_fixedCostsController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final itemName = _itemNameController.text.isEmpty ? 'Unknown Item' : _itemNameController.text;
    
    // Validation
    if (balance <= 0 || price <= 0) {
      setState(() {
        _showResult = true;
        _shouldBuy = false;
        _decisionText = 'INVALID INPUT';
        _explanationText = 'Please enter valid amounts!';
        _statsText = '';
      });
      _animationController.forward(from: 0);
      return;
    }
    
    if (price > balance) {
      setState(() {
        _showResult = true;
        _shouldBuy = false;
        _decisionText = 'NO WAY!';
        _explanationText = 'You literally don\'t have the money!';
        _statsText = '';
      });
      _animationController.forward(from: 0);
      return;
    }
    
    // RNG Logic with adjustable strictness
    final available = balance - fixedCosts;
    final availableRatio = (available / balance).clamp(0.0, 1.0);
    final threshold = 0.10 + (_strictnessLevel * availableRatio);
    final randomValue = Random().nextDouble();
    final shouldBuy = randomValue > threshold;
    
    // Save to history
    final historyItem = PurchaseHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: itemName,
      price: price,
      date: DateTime.now(),
      wasPurchased: shouldBuy,
      threshold: threshold,
      rollValue: randomValue,
    );
    
    setState(() {
      _purchaseHistory.insert(0, historyItem);
      if (_purchaseHistory.length > 100) {
        _purchaseHistory.removeLast();
      }
    });
    
    _saveSettings();
    
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
    
    setState(() {
      _showResult = true;
      _shouldBuy = shouldBuy;
      _decisionText = shouldBuy ? 'BUY IT!' : 'SKIP IT!';
      _explanationText = shouldBuy 
          ? buyMessages[Random().nextInt(buyMessages.length)]
          : skipMessages[Random().nextInt(skipMessages.length)];
      _statsText = 'RNG rolled ${(randomValue * 100).toStringAsFixed(1)}% ${shouldBuy ? '>' : '<'} ${(threshold * 100).toStringAsFixed(1)}%';
    });
    
    _animationController.forward(from: 0);
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
  }
  
  void _navigateTo(String page) {
    setState(() {
      _currentPage = page;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              border: Border(
                right: BorderSide(
                  color: Colors.black.withOpacity(0.08),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // App Logo
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0078D4), Color(0xFF005A9E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.casino,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'RNG Capitalist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildNavItem(Icons.home, 'Oracle', _currentPage == 'Oracle'),
                _buildNavItem(Icons.history, 'History', _currentPage == 'History'),
                _buildNavItem(Icons.account_balance_wallet, 'Fixed Costs', _currentPage == 'Fixed Costs'),
                _buildNavItem(Icons.settings, 'Settings', _currentPage == 'Settings'),
                const Spacer(),
                _buildNavItem(Icons.info_outline, 'About', _currentPage == 'About'),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent() {
    switch (_currentPage) {
      case 'Oracle':
        return _buildOraclePage();
      case 'History':
        return _buildHistoryPage();
      case 'Fixed Costs':
        return _buildFixedCostsPage();
      case 'Settings':
        return _buildSettingsPage();
      case 'About':
        return _buildAboutPage();
      default:
        return _buildOraclePage();
    }
  }
  
  Widget _buildOraclePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Consult the Oracle',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFF323130),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let chaos manage your wallet',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF605E5C),
            ),
          ),
          const SizedBox(height: 32),
          
          // Input Card
          Container(
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
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  'Current Balance (\$)',
                  _balanceController,
                  '1000',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        'Monthly Fixed Costs (\$)',
                        _fixedCostsController,
                        '800',
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: () => _navigateTo('Fixed Costs'),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  'Item Name (Optional)',
                  _itemNameController,
                  'That thing you want',
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  'Item Price (\$)',
                  _priceController,
                  '50',
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _consultOracle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'CONSULT THE ORACLE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Oracle Response
          if (_showResult)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.only(top: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _shouldBuy
                              ? [const Color(0xFF10C876), const Color(0xFF00B67A)]
                              : [const Color(0xFFE81123), const Color(0xFFC50E1F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: (_shouldBuy ? Colors.green : Colors.red).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            _shouldBuy ? Icons.celebration : Icons.block,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'The Oracle has spoken...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _decisionText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _explanationText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _statsText,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontFamily: 'Consolas',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          
          const SizedBox(height: 32),
          
          // Formula Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 4,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎲 How the Oracle Decides',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Decision Threshold = 10% + (${(_strictnessLevel * 100).toStringAsFixed(0)}% × Available/Balance)\n'
                  'If random > threshold → BUY IT!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistoryPage() {
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
            'Your last ${_purchaseHistory.length} decisions',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF605E5C),
            ),
          ),
          const SizedBox(height: 32),
          
          if (_purchaseHistory.isEmpty)
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
              _purchaseHistory.length > 20 ? 20 : _purchaseHistory.length,
              (index) {
                final item = _purchaseHistory[index];
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
                              '\$${item.price.toStringAsFixed(2)} • ${_formatDate(item.date)}',
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
  
  Widget _buildFixedCostsPage() {
    final categories = ['Housing', 'Transportation', 'Food', 'Utilities', 'Insurance', 'Other'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Fixed Monthly Costs',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF323130),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddFixedCostDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Cost'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0078D4),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total: \$${_fixedCosts.where((c) => c.isActive).fold(0.0, (sum, cost) => sum + cost.amount).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF605E5C),
            ),
          ),
          const SizedBox(height: 32),
          
          if (_fixedCosts.isEmpty)
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
                  'No fixed costs added yet. Click "Add Cost" to get started!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF605E5C),
                  ),
                ),
              ),
            )
          else
            ...categories.map((category) {
              final costsInCategory = _fixedCosts.where((c) => c.category == category).toList();
              if (costsInCategory.isEmpty) return const SizedBox.shrink();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF323130),
                      ),
                    ),
                  ),
                  ...costsInCategory.map((cost) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: cost.isActive,
                        onChanged: (value) {
                          setState(() {
                            final index = _fixedCosts.indexOf(cost);
                            _fixedCosts[index] = FixedCost(
                              id: cost.id,
                              name: cost.name,
                              amount: cost.amount,
                              category: cost.category,
                              isActive: value ?? true,
                            );
                            _calculateTotalFixedCosts();
                            _saveSettings();
                          });
                        },
                      ),
                      title: Text(
                        cost.name,
                        style: TextStyle(
                          decoration: cost.isActive ? null : TextDecoration.lineThrough,
                          color: cost.isActive ? null : Colors.grey,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${cost.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cost.isActive ? const Color(0xFF323130) : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _fixedCosts.removeWhere((c) => c.id == cost.id);
                                _calculateTotalFixedCosts();
                                _saveSettings();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildSettingsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFF323130),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Customize your Oracle',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF605E5C),
            ),
          ),
          const SizedBox(height: 32),
          
          Container(
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
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Strictness Level',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF323130),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adjust how strict the Oracle is with your spending decisions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF605E5C),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.sentiment_very_satisfied, color: Colors.green),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFF0078D4),
                          inactiveTrackColor: Colors.grey[300],
                          thumbColor: const Color(0xFF0078D4),
                          overlayColor: const Color(0xFF0078D4).withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _strictnessLevel,
                          min: 0.1,
                          max: 0.9,
                          divisions: 8,
                          label: '${(_strictnessLevel * 100).toStringAsFixed(0)}%',
                          onChanged: (value) {
                            setState(() {
                              _strictnessLevel = value;
                            });
                            _saveSettings();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _getStrictnessDescription(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0078D4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
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
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF323130),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear History?'),
                            content: const Text('This will delete all your purchase history. This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _purchaseHistory.clear();
                                  });
                                  _saveSettings();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Clear History'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About RNG Capitalist',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFF323130),
            ),
          ),
          const SizedBox(height: 32),
          Container(
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
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎲 Philosophy',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'RNG Capitalist is built on the principle of bounded rationality. We don\'t have infinite willpower or mental bandwidth, so why not externalize decision-making into an algorithm?\n\n'
                  'We\'re not solving for "maximize financial success" - we\'re solving for "reduce mental burden and regret." Let chaos manage your wallet!',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 32),
                const Text(
                  '📊 The Formula',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Decision Threshold = 10% + (Strictness × Available/Balance)\n\n'
                  'If a random number (0-100%) is greater than the threshold, the Oracle says BUY IT!\n\n'
                  'The more money you have available after fixed costs, the more likely you are to get a "yes" - but it\'s never guaranteed!',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 32),
                const Text(
                  '🚀 Roadmap',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '✅ Phase 1: MVP - Basic Yes/No decisions\n'
                  '✅ Phase 2: Budget Helper - Track fixed costs & adjustable strictness\n'
                  '🚧 Phase 3: AI Mode - Smart budget analysis\n'
                  '🎯 Phase 4: Personality Modes - Reckless, Zen, and more!',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0078D4).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isActive ? const Color(0xFF0078D4) : const Color(0xFF605E5C),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? const Color(0xFF0078D4) : const Color(0xFF323130),
          ),
        ),
        onTap: () => _navigateTo(label),
      ),
    );
  }
  
  Widget _buildInputField(String label, TextEditingController controller, String hint, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF323130),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: label.contains('\$') ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF0078D4), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            fillColor: readOnly ? Colors.grey[100] : null,
            filled: readOnly,
          ),
        ),
      ],
    );
  }
  
  void _showAddFixedCostDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Other';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Fixed Cost'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g., Rent, Car Payment',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                  hintText: '0.00',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: ['Housing', 'Transportation', 'Food', 'Utilities', 'Insurance', 'Other']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedCategory = value ?? 'Other';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0;
                
                if (name.isNotEmpty && amount > 0) {
                  setState(() {
                    _fixedCosts.add(FixedCost(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      amount: amount,
                      category: selectedCategory,
                    ));
                    _calculateTotalFixedCosts();
                    _saveSettings();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
  
  String _getStrictnessDescription() {
    if (_strictnessLevel < 0.3) {
      return 'YOLO Mode - Live dangerously!';
    } else if (_strictnessLevel < 0.5) {
      return 'Relaxed - Treat yourself often';
    } else if (_strictnessLevel < 0.7) {
      return 'Balanced - Reasonable choices';
    } else if (_strictnessLevel < 0.85) {
      return 'Strict - Save more, spend less';
    } else {
      return 'Scrooge Mode - Maximum savings!';
    }
  }
}
