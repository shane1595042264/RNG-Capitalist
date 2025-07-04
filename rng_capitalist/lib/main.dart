import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _balanceController = TextEditingController();
  final _fixedCostsController = TextEditingController();
  final _priceController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _showResult = false;
  bool _shouldBuy = false;
  String _decisionText = '';
  String _explanationText = '';
  String _statsText = '';
  
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
  }
  
  @override
  void dispose() {
    _balanceController.dispose();
    _fixedCostsController.dispose();
    _priceController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _consultOracle() {
    final balance = double.tryParse(_balanceController.text) ?? 0;
    final fixedCosts = double.tryParse(_fixedCostsController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    
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
    
    // RNG Logic
    final available = balance - fixedCosts;
    final availableRatio = (available / balance).clamp(0.0, 1.0);
    final threshold = 0.10 + (0.70 * availableRatio);
    final randomValue = Random().nextDouble();
    final shouldBuy = randomValue > threshold;
    
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
                _buildNavItem(Icons.home, 'Oracle', true),
                _buildNavItem(Icons.history, 'History', false),
                _buildNavItem(Icons.analytics, 'Analytics', false),
                _buildNavItem(Icons.settings, 'Settings', false),
                const Spacer(),
                _buildNavItem(Icons.info_outline, 'About', false),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
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
                        _buildInputField(
                          'Monthly Fixed Costs (\$)',
                          _fixedCostsController,
                          '800',
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
                          'Decision Threshold = 10% + (70% × Available/Balance)\n'
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
        onTap: () {
          // Navigation logic for future phases
          if (!isActive) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label - Coming in Phase ${label == 'History' || label == 'Analytics' ? '2' : '3'}!'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildInputField(String label, TextEditingController controller, String hint) {
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          ),
        ),
      ],
    );
  }
}