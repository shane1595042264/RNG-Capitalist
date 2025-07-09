// lib/components/spinner_page.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:local_notifier/local_notifier.dart';
import '../models/sunk_cost.dart';
import '../components/sunk_cost_spinner.dart';

class SpinnerPage extends StatefulWidget {
  final List<SunkCost> sunkCosts;

  const SpinnerPage({
    Key? key,
    required this.sunkCosts,
  }) : super(key: key);

  @override
  State<SpinnerPage> createState() => _SpinnerPageState();
}

class _SpinnerPageState extends State<SpinnerPage> {
  SunkCost? _lastResult;
  final List<SunkCost> _spinHistory = [];
  
  // Timer-related state
  Timer? _countdownTimer;
  Duration _timerDuration = const Duration(hours: 2); // Default 2 hours
  Duration _remainingTime = Duration.zero;
  bool _isTimerActive = false;
  bool _showTimerSettings = false;
  late AudioPlayer _audioPlayer;

  List<SunkCost> get _activeSunkCosts {
    return widget.sunkCosts.where((cost) => cost.isActive).toList();
  }

  double get _totalSunkCostValue {
    return _activeSunkCosts.fold(0.0, (sum, cost) => sum + cost.amount);
  }

  void _onSpinResult(SunkCost result) {
    setState(() {
      _lastResult = result;
      _spinHistory.insert(0, result);
      // Keep only last 10 results
      if (_spinHistory.length > 10) {
        _spinHistory.removeLast();
      }
    });
    
    // Auto-start the timer when result lands
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _remainingTime = _timerDuration;
      _isTimerActive = true;
    });
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        } else {
          _isTimerActive = false;
          timer.cancel();
          _onTimerComplete();
        }
      });
    });
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerActive = false;
      _remainingTime = Duration.zero;
    });
  }

  void _resetTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _remainingTime = _timerDuration;
      _isTimerActive = false;
    });
  }

  void _onTimerComplete() async {
    // Show desktop notification
    LocalNotification notification = LocalNotification(
      title: "RNG Capitalist Timer",
      body: "Your ${_lastResult?.name ?? 'focus session'} time is up! Time for a break or switch tasks.",
    );
    notification.show();

    // Try to play notification sound
    try {
      // Try to play custom sound first
      await _audioPlayer.play(AssetSource('sounds/timer_complete.mp3'));
    } catch (e) {
      // If custom sound fails, just log it (you could add a system beep here)
      print('Custom sound not available: $e');
      // You can add a system beep or other notification sound here
    }
    
    // Show in-app notification as well
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Timer completed! Your ${_lastResult?.name ?? 'focus session'} time is up.'),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Start Again',
            textColor: Colors.white,
            onPressed: _startTimer,
          ),
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String _generateActivitySuggestion(SunkCost sunkCost) {
    final category = sunkCost.category.toLowerCase();
    
    if (category.contains('education') || category.contains('learning')) {
      return 'Study or work on ${sunkCost.name} for 1-2 hours';
    } else if (category.contains('game') || category.contains('gaming')) {
      return 'Play ${sunkCost.name} for 30-60 minutes';
    } else if (category.contains('fitness') || category.contains('health')) {
      return 'Use ${sunkCost.name} for a workout session';
    } else if (category.contains('hobby') || category.contains('creative')) {
      return 'Work on your ${sunkCost.name} project';
    } else {
      return 'Spend some time with ${sunkCost.name}';
    }
  }



  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[600]!, Colors.purple[800]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.casino,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sunk Cost Spinner',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'What should you focus on next?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Stats - Make them wrap on smaller screens
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildStatCard(
                      'Active Investments',
                      '${_activeSunkCosts.length}',
                      Icons.trending_up,
                      Colors.white,
                    ),
                    _buildStatCard(
                      'Total Value',
                      '\$${_totalSunkCostValue.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.white,
                    ),
                    _buildStatCard(
                      'Spins Today',
                      '${_spinHistory.length}',
                      Icons.refresh,
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main Content - Make it scrollable
          Expanded(
            child: _activeSunkCosts.isEmpty
                ? Center(
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
                            fontSize: 20,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Go to Sunk Costs page to add your investments',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: isWideScreen
                          ? _buildWideLayout()
                          : _buildNarrowLayout(),
                    ),
                  ),
          ),
          
          // Timer Widget at the bottom
          if (_isTimerActive || _lastResult != null) _buildTimerWidget(),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spinner Section
        Expanded(
          flex: 2,
          child: _buildSpinnerSection(),
        ),
        const SizedBox(width: 16),
        // Sidebar
        SizedBox(
          width: 350,
          child: _buildSidebar(),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        // Spinner Section
        _buildSpinnerSection(),
        const SizedBox(height: 16),
        // Sidebar content below spinner
        _buildSidebar(),
      ],
    );
  }

  Widget _buildSpinnerSection() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 500,
        maxHeight: 700,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.casino,
                  color: Colors.purple[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Spin to Decide',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  'Click the center to spin!',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SunkCostSpinner(
              sunkCosts: widget.sunkCosts,
              onSpinResult: _onSpinResult,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        // Current Result
        if (_lastResult != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Current Focus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _lastResult!.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${_lastResult!.category}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Investment: \$${_lastResult!.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Suggestion:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _generateActivitySuggestion(_lastResult!),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Spin History
        if (_spinHistory.isNotEmpty)
          Container(
            constraints: const BoxConstraints(
              maxHeight: 400,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Colors.grey[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Recent Spins',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _spinHistory.length,
                    itemBuilder: (context, index) {
                      final item = _spinHistory[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${index + 1}.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '\$${item.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color textColor) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 140,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _isTimerActive ? Icons.timer : Icons.timer_off,
                color: _isTimerActive ? Colors.green[600] : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _isTimerActive ? 'Focus Timer Active' : 'Focus Timer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isTimerActive ? Colors.green[600] : Colors.grey[600],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showTimerSettings = !_showTimerSettings;
                  });
                },
                icon: Icon(
                  _showTimerSettings ? Icons.keyboard_arrow_down : Icons.settings,
                  color: Colors.grey[600],
                ),
                tooltip: 'Timer Settings',
              ),
            ],
          ),
          
          if (_showTimerSettings) ...[
            const SizedBox(height: 12),
            _buildTimerSettings(),
            const SizedBox(height: 12),
          ],
          
          if (_isTimerActive) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _remainingTime.inMinutes <= 5 
                      ? [Colors.red[400]!, Colors.red[600]!]
                      : [Colors.blue[400]!, Colors.blue[600]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatDuration(_remainingTime),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _stopTimer,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[500],
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[500],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ] else if (_lastResult != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _startTimer,
              icon: const Icon(Icons.play_arrow),
              label: Text('Start ${_formatDuration(_timerDuration)} Timer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[500],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimerSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timer Duration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDurationChip('15 min', const Duration(minutes: 15)),
              _buildDurationChip('30 min', const Duration(minutes: 30)),
              _buildDurationChip('1 hour', const Duration(hours: 1)),
              _buildDurationChip('2 hours', const Duration(hours: 2)),
              _buildDurationChip('3 hours', const Duration(hours: 3)),
              _buildDurationChip('Custom', null),
            ],
          ),
          if (_timerDuration.inMinutes % 15 != 0 ||
              (_timerDuration.inHours == 0 && _timerDuration.inMinutes != 15 && _timerDuration.inMinutes != 30) ||
              (_timerDuration.inHours > 3)) ...[
            const SizedBox(height: 12),
            Text(
              'Custom: ${_formatDuration(_timerDuration)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDurationChip(String label, Duration? duration) {
    final isSelected = duration == _timerDuration;
    final isCustom = duration == null;
    
    return GestureDetector(
      onTap: () async {
        if (isCustom) {
          await _showCustomDurationDialog();
        } else {
          setState(() {
            _timerDuration = duration;
            if (!_isTimerActive) {
              _remainingTime = _timerDuration;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple[600] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.purple[600]! : Colors.grey[300]!
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _showCustomDurationDialog() async {
    int hours = _timerDuration.inHours;
    int minutes = _timerDuration.inMinutes.remainder(60);
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Custom Timer Duration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Hours: '),
                  Expanded(
                    child: Slider(
                      value: hours.toDouble(),
                      min: 0,
                      max: 12,
                      divisions: 12,
                      label: hours.toString(),
                      onChanged: (value) {
                        setDialogState(() {
                          hours = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text('$hours'),
                ],
              ),
              Row(
                children: [
                  const Text('Minutes: '),
                  Expanded(
                    child: Slider(
                      value: minutes.toDouble(),
                      min: 0,
                      max: 59,
                      divisions: 59,
                      label: minutes.toString(),
                      onChanged: (value) {
                        setDialogState(() {
                          minutes = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text('$minutes'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Total: ${_formatDuration(Duration(hours: hours, minutes: minutes))}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _timerDuration = Duration(hours: hours, minutes: minutes);
                  if (!_isTimerActive) {
                    _remainingTime = _timerDuration;
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
  }
}
