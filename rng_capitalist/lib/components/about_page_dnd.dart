// lib/components/about_page_dnd.dart
import 'package:flutter/material.dart';

class AboutPageDnD extends StatelessWidget {
  const AboutPageDnD({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About RNG Capitalist - D&D Edition',
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎲 Philosophy',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'RNG Capitalist D&D Edition brings the thrill of tabletop gaming to your financial decisions. '
                  'Instead of agonizing over purchases, let the dice decide your fate!\n\n'
                  'Just like in D&D, every purchase becomes an exciting roll against a Difficulty Class. '
                  'Add modifiers to represent your circumstances, and watch as the dice determine your financial adventures.',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                SizedBox(height: 32),
                Text(
                  '🎯 The Dice Mechanics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '• Roll: 1d20 + modifiers\n'
                  '• Difficulty Class (DC) = (Price ÷ Budget) × 20\n'
                  '• Success: Roll ≥ DC\n'
                  '• Critical Success: Natural 20 (always succeeds!)\n'
                  '• Critical Failure: Natural 1 (always fails!)\n\n'
                  'Example: \$50 item with \$200 budget = DC 5\n'
                  'Example: \$180 item with \$200 budget = DC 18',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                SizedBox(height: 32),
                Text(
                  '⚔️ Modifiers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Just like D&D characters have bonuses and penalties, your financial rolls can be modified:\n\n'
                  '• Positive modifiers: Lucky day, payday, sales\n'
                  '• Negative modifiers: Stress, bills due, bad mood\n'
                  '• Stack multiple modifiers for complex situations\n'
                  '• Create custom modifiers for your unique circumstances',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                SizedBox(height: 32),
                Text(
                  '🚀 Roadmap',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '✅ Phase 1: Basic D20 System\n'
                  '✅ Phase 2: Modifiers & Custom Rules\n'
                  '🚧 Phase 3: Character Classes (Saver, Spender, Balanced)\n'
                  '🎯 Phase 4: Campaign Mode & Achievements',
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}