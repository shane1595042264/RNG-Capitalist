// lib/components/dice_roll_overlay.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/dice_modifier.dart';

// Custom painter for D20 face lines
class D20FacePainter extends CustomPainter {
  final double rotationX;
  final double rotationY;

  D20FacePainter({
    required this.rotationX,
    required this.rotationY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Create pentagon faces for D20 look
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + (rotationY * 0.1);
      final x1 = center.dx + cos(angle) * radius * 0.8;
      final y1 = center.dy + sin(angle) * radius * 0.8;
      final x2 = center.dx + cos(angle + pi / 4) * radius * 0.6;
      final y2 = center.dy + sin(angle + pi / 4) * radius * 0.6;
      
      // Add 3D depth based on rotation
      final depth = sin(rotationX * 0.1 + angle) * 10;
      
      canvas.drawLine(
        Offset(x1, y1 + depth),
        Offset(x2, y2 + depth),
        paint,
      );
    }

    // Draw triangular faces
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3) + (rotationX * 0.05);
      final trianglePaint = Paint()
        ..color = Colors.white.withOpacity(0.1 + (sin(angle + rotationY * 0.1) * 0.1).abs())
        ..style = PaintingStyle.fill;

      final path = Path();
      for (int j = 0; j < 3; j++) {
        final vertexAngle = angle + (j * 2 * pi / 3);
        final x = center.dx + cos(vertexAngle) * radius * 0.5;
        final y = center.dy + sin(vertexAngle) * radius * 0.5;
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, trianglePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DiceRollOverlay extends StatefulWidget {
  final String itemName;
  final double itemPrice;
  final double availableBudget;
  final List<DiceModifier> activeModifiers;
  final Function(bool success, int roll, int threshold, int total) onRollComplete;

  const DiceRollOverlay({
    Key? key,
    required this.itemName,
    required this.itemPrice,
    required this.availableBudget,
    required this.activeModifiers,
    required this.onRollComplete,
  }) : super(key: key);

  @override
  State<DiceRollOverlay> createState() => _DiceRollOverlayState();
}

class _DiceRollOverlayState extends State<DiceRollOverlay> with TickerProviderStateMixin {
  late AnimationController _diceController;
  late AnimationController _resultController;
  late AnimationController _shakeController;
  late Animation<double> _diceRotationX;
  late Animation<double> _diceRotationY;
  late Animation<double> _diceRotationZ;
  late Animation<double> _diceScale;
  late Animation<double> _dicePosition;
  late Animation<Offset> _shakeOffset;
  late Animation<double> _resultScale;
  
  bool _isRolling = false;
  bool _showResult = false;
  int? _rollResult;
  int? _totalWithModifiers;
  late int _threshold;
  int _currentDisplayNumber = 1;
  late List<int> _d20Faces;

  @override
  void initState() {
    super.initState();
    
    // Initialize d20 faces in a realistic order
    _d20Faces = [1, 20, 19, 2, 18, 3, 17, 4, 16, 5, 15, 6, 14, 7, 13, 8, 12, 9, 11, 10];
    
    // Calculate threshold (DC - Difficulty Class)
    double ratio = widget.itemPrice / widget.availableBudget;
    ratio = ratio.clamp(0.0, 1.0);
    _threshold = (ratio * 20).ceil();
    
    // Setup enhanced animations for realistic D20 rolling
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 3000), // Longer for more dramatic effect
      vsync: this,
    );
    
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Enhanced multi-axis rotation for realistic D20 tumbling
    _diceRotationX = Tween<double>(
      begin: 0,
      end: 4 * pi, // Reduced rotations to prevent upside-down dice
    ).animate(CurvedAnimation(
      parent: _diceController,
      curve: Curves.easeOutCubic,
    ));
    
    _diceRotationY = Tween<double>(
      begin: 0,
      end: 3 * pi, // Different speed for each axis
    ).animate(CurvedAnimation(
      parent: _diceController,
      curve: const Interval(0.0, 0.85, curve: Curves.easeOutQuint),
    ));
    
    _diceRotationZ = Tween<double>(
      begin: 0,
      end: 2 * pi, // Z-axis for additional tumbling effect
    ).animate(CurvedAnimation(
      parent: _diceController,
      curve: const Interval(0.1, 0.9, curve: Curves.easeInOutCubic),
    ));
    
    _diceScale = Tween<double>(
      begin: 1.0,
      end: 1.4, // Larger scale for more impact
    ).animate(CurvedAnimation(
      parent: _diceController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    // Enhanced bouncing with gravity effect
    _dicePosition = Tween<double>(
      begin: 0.0,
      end: -50.0, // Higher bounce for more dramatic effect
    ).animate(CurvedAnimation(
      parent: _diceController,
      curve: const Interval(0.0, 0.7, curve: Curves.bounceOut),
    ));
    
    // Enhanced screen shake effect
    _shakeOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(8.0, 8.0), // Stronger shake for impact
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));
    
    _resultScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _diceController.dispose();
    _resultController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _rollDice() async {
    if (_isRolling) return;
    
    setState(() {
      _isRolling = true;
      _showResult = false;
    });
    
    // Reset animations
    _diceController.reset();
    _resultController.reset();
    _shakeController.reset();
    
    // Calculate result first so we can land on it
    final random = Random();
    final baseRoll = random.nextInt(20) + 1; // 1-20
    
    // Add modifiers
    int totalModifier = 0;
    for (var mod in widget.activeModifiers) {
      totalModifier += mod.value;
    }
    
    setState(() {
      _rollResult = baseRoll;
      _totalWithModifiers = baseRoll + totalModifier;
    });
    
    // Enhanced face changing during roll - more random and chaotic
    final faceChangeTimer = Stream.periodic(const Duration(milliseconds: 50)).listen((_) {
      if (_diceController.isAnimating && _isRolling) {
        final randomFace = _d20Faces[random.nextInt(_d20Faces.length)];
        if (mounted) {
          setState(() {
            _currentDisplayNumber = randomFace;
          });
        }
      }
    });
    
    // Start dice animation with enhanced physics
    await _diceController.forward();
    
    // Stop face changing
    faceChangeTimer.cancel();
    
    // Multiple screen shakes for extra impact
    _shakeController.forward().then((_) {
      _shakeController.reverse().then((_) {
        // Second smaller shake
        _shakeController.forward().then((_) {
          _shakeController.reverse();
        });
      });
    });
    
    // Brief pause before showing final number
    await Future.delayed(const Duration(milliseconds: 400));
    
    setState(() {
      _currentDisplayNumber = baseRoll; // Show the actual rolled number
      _showResult = true;
      _isRolling = false;
    });
    
    // Show result animation with delay for dramatic effect
    await Future.delayed(const Duration(milliseconds: 200));
    await _resultController.forward();
    
    // Wait a moment before returning result
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final success = _totalWithModifiers! >= _threshold;
    widget.onRollComplete(success, baseRoll, _threshold, _totalWithModifiers!);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: InkWell(
        onTap: () {}, // Prevent closing on background tap
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            return Transform.translate(
              offset: _shakeOffset.value,
              child: Center(
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2A2A3A),
                        Color(0xFF1A1A2E),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          'Purchase Check',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.amber.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      
                      // Item info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white24,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.itemName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${widget.itemPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.green[400],
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Difficulty Class
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red[900]!,
                              Colors.red[700]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'DIFFICULTY CLASS',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              _threshold.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Enhanced 3D D20 Dice with realistic rolling
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Enhanced 3D D20 Dice with realistic rolling animation
                          AnimatedBuilder(
                            animation: _diceController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  _isRolling ? (sin(_diceController.value * 12) * 8) : 0,
                                  _dicePosition.value + (_isRolling ? (cos(_diceController.value * 8) * 5) : 0),
                                ),
                                child: Transform.scale(
                                  scale: _diceScale.value,
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001) // Enhanced perspective for 3D effect
                                      // Only apply rotations while rolling
                                      ..rotateX(_isRolling ? _diceRotationX.value : 0)
                                      ..rotateY(_isRolling ? _diceRotationY.value : 0)
                                      ..rotateZ(_isRolling ? _diceRotationZ.value : 0),
                                    child: GestureDetector(
                                      onTap: !_isRolling ? _rollDice : null,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            center: const Alignment(-0.3, -0.3),
                                            colors: [
                                              Colors.purple[200]!,
                                              Colors.purple[600]!,
                                              Colors.purple[800]!,
                                              Colors.purple[900]!,
                                            ],
                                            stops: const [0.0, 0.4, 0.8, 1.0],
                                          ),
                                          shape: BoxShape.circle, // More D20-like rounded shape
                                          border: Border.all(
                                            color: Colors.purple[100]!,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.purple.withOpacity(0.6),
                                              blurRadius: 25,
                                              spreadRadius: 8,
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(-3, -3),
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(3, 3),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // D20 faceted background pattern
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white.withOpacity(0.15),
                                                    Colors.transparent,
                                                    Colors.black.withOpacity(0.25),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // D20 face lines for realistic look (only when rolling)
                                            if (_isRolling)
                                              CustomPaint(
                                                size: const Size(120, 120),
                                                painter: D20FacePainter(
                                                  rotationX: _diceRotationX.value,
                                                  rotationY: _diceRotationY.value,
                                                ),
                                              ),
                                            // Number display with enhanced styling
                                            if (!_showResult || _isRolling)
                                              Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black.withOpacity(0.3),
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.5),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    _currentDisplayNumber.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 36,
                                                      fontWeight: FontWeight.bold,
                                                      shadows: [
                                                        Shadow(
                                                          color: Colors.black.withOpacity(0.9),
                                                          blurRadius: 6,
                                                          offset: const Offset(2, 2),
                                                        ),
                                                        Shadow(
                                                          color: Colors.purple.withOpacity(0.5),
                                                          blurRadius: 12,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (_showResult && !_isRolling && _rollResult != null)
                                              Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _rollResult == 20 
                                                      ? Colors.amber.withOpacity(0.3)
                                                      : _rollResult == 1
                                                          ? Colors.red.withOpacity(0.3)
                                                          : Colors.black.withOpacity(0.3),
                                                  border: Border.all(
                                                    color: _rollResult == 20 
                                                        ? Colors.amber
                                                        : _rollResult == 1
                                                            ? Colors.red
                                                            : Colors.white.withOpacity(0.5),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    _rollResult.toString(),
                                                    style: TextStyle(
                                                      color: _rollResult == 20 
                                                          ? Colors.amber[100]
                                                          : _rollResult == 1
                                                              ? Colors.red[100]
                                                              : Colors.white,
                                                      fontSize: 36,
                                                      fontWeight: FontWeight.bold,
                                                      shadows: [
                                                        Shadow(
                                                          color: Colors.black.withOpacity(0.9),
                                                          blurRadius: 6,
                                                          offset: const Offset(2, 2),
                                                        ),
                                                        if (_rollResult == 20)
                                                          Shadow(
                                                            color: Colors.amber.withOpacity(0.8),
                                                            blurRadius: 15,
                                                          ),
                                                        if (_rollResult == 1)
                                                          Shadow(
                                                            color: Colors.red.withOpacity(0.8),
                                                            blurRadius: 15,
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            // D20 icon when not rolling
                                            if (!_isRolling && !_showResult)
                                              Icon(
                                                Icons.casino,
                                                color: Colors.white.withOpacity(0.4),
                                                size: 35,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Result overlay with enhanced effects
                          if (_showResult && _totalWithModifiers != null)
                            AnimatedBuilder(
                              animation: _resultController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _resultScale.value,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 140),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _totalWithModifiers! >= _threshold
                                            ? [Colors.green[600]!, Colors.green[800]!]
                                            : [Colors.red[600]!, Colors.red[800]!],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _totalWithModifiers! >= _threshold
                                            ? Colors.green[300]!
                                            : Colors.red[300]!,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_totalWithModifiers! >= _threshold
                                                  ? Colors.green
                                                  : Colors.red)
                                              .withOpacity(0.6),
                                          blurRadius: 25,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          _totalWithModifiers! >= _threshold
                                              ? 'SUCCESS!'
                                              : 'FAILED!',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black54,
                                                blurRadius: 4,
                                                offset: Offset(1, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (widget.activeModifiers.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            '$_rollResult + ${widget.activeModifiers.fold(0, (sum, mod) => sum + mod.value)} = $_totalWithModifiers',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.95),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      
                      if (!_isRolling && !_showResult)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Click dice to roll',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Enhanced Modifiers display
                      if (widget.activeModifiers.isNotEmpty) ...[
                        Text(
                          'Active Modifiers',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            for (var modifier in widget.activeModifiers)
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber[600]!,
                                      Colors.amber[800]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber[300]!,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.4),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      modifier.icon,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      modifier.value >= 0
                                          ? '+${modifier.value}'
                                          : modifier.value.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      modifier.name,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
