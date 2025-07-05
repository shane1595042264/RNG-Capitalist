# RNG Capitalist - Release Build

## What's New in This Release

### 🎯 Core Features
- **Smart Budget Oracle**: Let randomness decide your purchases based on your financial situation
- **Remaining Budget Logic**: Decisions now based on Available Budget - Fixed Costs
- **No Base Threshold**: Pure price ratio system for more intuitive control

### 💰 Budget Management
- **Fixed Monthly Costs**: Track rent, utilities, insurance, etc. by category
- **Real-time Calculations**: Automatic budget updates as you input data
- **Edit Functionality**: Modify existing fixed costs with name, amount, and category changes

### ⚙️ Advanced Controls
- **Strictness Slider**: 0% to 300% control over spending decisions
  - **0%**: Always approve purchases
  - **100%**: Pure price ratio (default) 
  - **300%**: Extremely strict approval
- **Purchase History**: Track all your Oracle decisions with detailed stats

### 🎲 How It Works
1. **Remaining Budget** = Available Budget - Fixed Costs
2. **Price Ratio** = Item Price ÷ Remaining Budget  
3. **Decision Threshold** = Strictness × Price Ratio
4. Roll random number (0-100%)
5. If random > threshold → **BUY IT!**

## Installation & Usage

1. **Extract** all files to a folder of your choice
2. **Run** `rng_capitalist.exe` to start the application
3. **No installation required** - it's a portable app!

### System Requirements
- Windows 10 or later
- 64-bit system
- ~50MB disk space

## Getting Started

1. **Set Your Budget**: Enter your current balance and last month's spending
2. **Add Fixed Costs**: Input your monthly recurring expenses
3. **Adjust Strictness**: Set how strict you want the Oracle to be
4. **Consult the Oracle**: Enter an item and price, then let chaos decide!

## Tips for Best Results

- **Be Honest**: Enter accurate financial information
- **Update Regularly**: Keep your balance and spending current
- **Trust the Process**: The Oracle's randomness reduces decision fatigue
- **Review History**: Learn from past decisions to adjust your strictness

## Philosophy

RNG Capitalist is built on **bounded rationality** - we don't have infinite willpower, so why not externalize decision-making? We're not optimizing for maximum savings, but for **reduced mental burden and regret**.

Let chaos manage your wallet! 🎰

---

**Version**: Phase 2 Release  
**Build Date**: July 4, 2025  
**Platform**: Windows x64
