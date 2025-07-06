import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  'Remaining Budget = Available Budget - Fixed Costs\n'
                  'Price Ratio = Item Price ÷ Remaining Budget\n'
                  'Decision Threshold = Strictness × Price Ratio\n\n'
                  'If a random number (0-100%) is greater than the threshold, the Oracle says BUY IT!\n\n'
                  'At 100% strictness (default): threshold equals the price ratio. At 0%: always approve purchases. At 300%: extremely strict - even small purchases relative to budget become hard to approve!',
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
}
