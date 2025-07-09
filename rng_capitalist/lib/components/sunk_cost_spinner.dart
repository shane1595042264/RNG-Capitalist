// lib/components/sunk_cost_spinner.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/sunk_cost.dart';

class SunkCostSpinner extends StatefulWidget {
  final List<SunkCost> sunkCosts;
  final Function(SunkCost) onSpinResult;

  const SunkCostSpinner({
    Key? key,
    required this.sunkCosts,
    required this.onSpinResult,
  }) : super(key: key);

  @override
  State<SunkCostSpinner> createState() => _SunkCostSpinnerState();
}

class _SunkCostSpinnerState extends State<SunkCostSpinner>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  Animation<double>? _rotationAnimation;
  bool _isSpinning = false;
  SunkCost? _result;
  SunkCost? _hoveredSegment;
  
  List<SpinnerSegment> _segments = [];
  double _totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    // Initialize the rotation animation to prevent LateInitializationError
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOut,
    ));
    
    _calculateSegments();
  }

  @override
  void didUpdateWidget(SunkCostSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sunkCosts != widget.sunkCosts) {
      _calculateSegments();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _calculateSegments() {
    final activeCosts = widget.sunkCosts.where((cost) => cost.isActive).toList();
    _totalValue = activeCosts.fold(0.0, (sum, cost) => sum + cost.amount);
    
    if (_totalValue == 0) {
      _segments = [];
      return;
    }

    double currentAngle = 0.0;
    _segments = [];
    
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.deepOrange,
    ];

    for (int i = 0; i < activeCosts.length; i++) {
      final cost = activeCosts[i];
      final percentage = cost.amount / _totalValue;
      final sweepAngle = percentage * 2 * math.pi;
      
      _segments.add(SpinnerSegment(
        sunkCost: cost,
        startAngle: currentAngle,
        sweepAngle: sweepAngle,
        color: colors[i % colors.length],
        percentage: percentage * 100,
      ));
      
      currentAngle += sweepAngle;
    }
    
    setState(() {});
  }

  void _spin() async {
    if (_isSpinning) return;
    
    setState(() {
      _isSpinning = true;
      _result = null;
    });

    // Generate random final rotation (3-7 full rotations plus random angle)
    final random = math.Random();
    final baseRotations = 3 + random.nextDouble() * 4; // 3-7 rotations
    final finalAngle = baseRotations * 2 * math.pi;
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: finalAngle,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOut,
    ));

    await _rotationController.forward();
    
    // Calculate result based on final position
    final normalizedAngle = (finalAngle % (2 * math.pi));
    final resultAngle = (2 * math.pi) - normalizedAngle; // Reverse because spinner rotates
    
    SunkCost? selectedCost;
    for (var segment in _segments) {
      if (resultAngle >= segment.startAngle && 
          resultAngle < segment.startAngle + segment.sweepAngle) {
        selectedCost = segment.sunkCost;
        break;
      }
    }
    
    selectedCost ??= _segments.isNotEmpty ? _segments.first.sunkCost : null;
    
    setState(() {
      _isSpinning = false;
      _result = selectedCost;
    });
    
    if (selectedCost != null) {
      widget.onSpinResult(selectedCost);
    }
    
    _rotationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (_segments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.casino,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No active sunk costs',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some sunk costs to start spinning!',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Spinner
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Spinner wheel
                SizedBox(
                  width: 300,
                  height: 300,
                  child: AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation?.value ?? 0.0,
                        child: CustomPaint(
                          size: const Size(300, 300),
                          painter: SpinnerPainter(
                            segments: _segments,
                            hoveredSegment: _hoveredSegment,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Pointer
                Positioned(
                  top: 0,
                  child: Container(
                    width: 0,
                    height: 0,
                    decoration: const BoxDecoration(),
                    child: CustomPaint(
                      painter: PointerPainter(),
                    ),
                  ),
                ),
                
                // Center button
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: _isSpinning ? null : _spin,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isSpinning ? Icons.hourglass_top : Icons.play_arrow,
                          size: 32,
                          color: _isSpinning ? Colors.grey : Colors.green[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Legend
        if (_segments.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sunk Cost Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: _segments.map((segment) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: segment.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: segment.color.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: segment.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${segment.sunkCost.name} (\$${segment.sunkCost.amount.toStringAsFixed(2)}) - ${segment.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        
        // Result display
        if (_result != null)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '🎉 Spin Result!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Focus on: ${_result!.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${_result!.category} • \$${_result!.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class SpinnerSegment {
  final SunkCost sunkCost;
  final double startAngle;
  final double sweepAngle;
  final Color color;
  final double percentage;

  SpinnerSegment({
    required this.sunkCost,
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
    required this.percentage,
  });
}

class SpinnerPainter extends CustomPainter {
  final List<SpinnerSegment> segments;
  final SunkCost? hoveredSegment;

  SpinnerPainter({
    required this.segments,
    this.hoveredSegment,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    for (var segment in segments) {
      final paint = Paint()
        ..color = segment.sunkCost == hoveredSegment 
            ? segment.color.withOpacity(0.8)
            : segment.color
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Draw segment
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        segment.startAngle,
        segment.sweepAngle,
        true,
        paint,
      );

      // Draw border
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        segment.startAngle,
        segment.sweepAngle,
        true,
        strokePaint,
      );

      // Draw text if segment is large enough
      if (segment.sweepAngle > 0.5) { // About 28 degrees
        final textAngle = segment.startAngle + segment.sweepAngle / 2;
        final textRadius = radius * 0.7;
        final textX = center.dx + math.cos(textAngle) * textRadius;
        final textY = center.dy + math.sin(textAngle) * textRadius;

        final textPainter = TextPainter(
          text: TextSpan(
            text: segment.sunkCost.name.length > 10 
                ? '${segment.sunkCost.name.substring(0, 10)}...'
                : segment.sunkCost.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        
        canvas.save();
        canvas.translate(textX, textY);
        canvas.rotate(textAngle + math.pi / 2);
        textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red[700]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, -20);
    path.lineTo(-10, -5);
    path.lineTo(10, -5);
    path.close();

    canvas.drawPath(path, paint);
    
    // Draw pointer border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
