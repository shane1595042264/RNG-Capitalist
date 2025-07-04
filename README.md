# 🎲 RNG Capitalist

> Let chaos manage your wallet with science-backed randomness!

RNG Capitalist is a Flutter desktop application that uses algorithmic decision-making to help you make spending choices. Built on the principle of bounded rationality, it externalizes purchase decisions to reduce mental burden and decision fatigue.

![RNG Capitalist App](https://img.shields.io/badge/Platform-Windows-blue?style=for-the-badge) ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## 🎯 Philosophy

**We're not solving for "maximize financial success" - we're solving for "reduce mental burden and regret."**

RNG Capitalist acknowledges that humans have limited willpower and mental bandwidth. Instead of agonizing over every purchase decision, let an algorithm make the choice based on your current financial situation and risk tolerance.

## ✨ Features

### 🔮 The Oracle
The core feature that makes spending decisions for you based on:
- **Current Balance** - Your available money
- **Last Month Total Spend** - Your previous month's spending baseline
- **Available Budget** - Automatically calculated (Current Balance - Last Month Spend)
- **Fixed Costs** - Your monthly recurring expenses
- **Item Price** - What you want to buy
- **Strictness Level** - Your risk tolerance (10% to 90%)

### 📊 Smart Budget Calculation
```
Available Budget = Current Balance - Last Month Total Spend
Decision Threshold = 10% + (Strictness × (Available Budget - Fixed Costs)/Available Budget)
```

If a random number (0-100%) is greater than the threshold → **BUY IT!** 🎉
Otherwise → **SKIP IT!** 💸

### 💰 Fixed Costs Management
- **Categorized Expenses**: Housing, Transportation, Food, Utilities, Insurance, Other
- **Active/Inactive Toggle**: Temporarily disable costs without deleting
- **Real-time Calculation**: Automatically updates your available spending money
- **Persistent Storage**: All data saved locally

### 📈 Purchase History
- **Complete Decision Log**: Track every Oracle consultation
- **Detailed Statistics**: See roll values vs thresholds for each decision
- **Smart Timestamps**: "Just now", "2h ago", "Yesterday", etc.
- **Buy/Skip Tracking**: Visual indicators for all decisions
- **Limited History**: Keeps last 100 decisions for performance

### ⚙️ Customizable Settings
- **Strictness Slider**: From "YOLO Mode" to "Scrooge Mode"
  - **10-30%**: YOLO Mode - Live dangerously!
  - **30-50%**: Relaxed - Treat yourself often
  - **50-70%**: Balanced - Reasonable choices
  - **70-85%**: Strict - Save more, spend less
  - **85-90%**: Scrooge Mode - Maximum savings!
- **Data Management**: Clear history when needed
- **Persistent Preferences**: All settings auto-saved

### 🎨 Modern UI/UX
- **Windows Native Design**: Follows Microsoft design principles
- **Sidebar Navigation**: Easy access to all features
- **Responsive Layout**: Handles different window sizes
- **Smooth Animations**: Satisfying visual feedback
- **Color-Coded Results**: Green for buy, red for skip
- **Haptic Feedback**: Physical response to decisions

## 🚀 Roadmap

- ✅ **Phase 1**: MVP - Basic Yes/No decisions
- ✅ **Phase 2**: Budget Helper - Track fixed costs & adjustable strictness
- ✅ **Phase 2.5**: Available Budget - Smart spending based on last month's baseline
- 🚧 **Phase 3**: AI Mode - Smart budget analysis with trends
- 🎯 **Phase 4**: Bank Integration - Real-time account data (Plaid/similar)
- 🌟 **Phase 5**: Personality Modes - Reckless, Conservative, Zen, etc.
- 📱 **Phase 6**: Mobile Apps - iOS and Android versions

## 🛠️ Technical Details

### Built With
- **Flutter 3.x** - Cross-platform UI framework
- **Dart** - Programming language
- **shared_preferences** - Local data persistence
- **Material 3** - Modern design system

### Architecture
- **Single Page App**: All features in one main.dart file
- **State Management**: Built-in Flutter setState
- **Data Models**: FixedCost and PurchaseHistory classes
- **Local Storage**: JSON serialization with SharedPreferences
- **Platform**: Windows desktop (with potential for macOS/Linux)

### File Structure
```
rng_capitalist/
├── lib/
│   └── main.dart           # Complete application code
├── pubspec.yaml            # Dependencies and app configuration
├── windows/                # Windows-specific files
├── build/                  # Compiled application
│   └── windows/x64/runner/Release/
│       ├── rng_capitalist.exe    # Standalone executable
│       ├── data/                 # Required app resources
│       └── RNG_Capitalist.bat    # Easy launch script
└── README.md              # This file
```

## 🎮 How to Use

### First Time Setup
1. **Launch the app** - Double-click `rng_capitalist.exe` or `RNG_Capitalist.bat`
2. **Set your balance** - Enter your current account balance
3. **Add last month's spending** - Input your previous month's total expenses
4. **Configure fixed costs** - Add rent, utilities, subscriptions, etc.
5. **Adjust strictness** - Set your risk tolerance level

### Making Purchase Decisions
1. **Enter item details** - Name (optional) and price
2. **Consult the Oracle** - Click the big blue button
3. **Follow the decision** - Buy it or skip it based on the result
4. **Check your history** - Review past decisions anytime

### Managing Your Budget
- **Fixed Costs Page**: Add/remove/toggle monthly expenses
- **Settings Page**: Adjust strictness and clear data
- **History Page**: Review all past Oracle consultations

## 🔧 Installation & Setup

### Option 1: Pre-built Executable (Easiest)
1. Navigate to `build/windows/x64/runner/Release/`
2. Double-click `rng_capitalist.exe` or `RNG_Capitalist.bat`
3. Create a desktop shortcut for easy access

### Option 2: Build from Source
1. **Install Flutter** - [flutter.dev](https://flutter.dev)
2. **Clone/download** this repository
3. **Navigate to project**:
   ```bash
   cd rng_capitalist
   ```
4. **Get dependencies**:
   ```bash
   flutter pub get
   ```
5. **Run in development**:
   ```bash
   flutter run -d windows
   ```
6. **Build release version**:
   ```bash
   flutter build windows --release
   ```

## 💾 Data & Privacy

- **Local Storage Only**: All data stays on your computer
- **No Internet Required**: Fully offline application
- **No Data Collection**: We don't track or store anything remotely
- **Portable**: Copy the Release folder to any Windows PC

### What's Saved
- Current balance (last entered)
- Last month spending amount
- Strictness level preference
- Fixed costs list with categories
- Purchase decision history (last 100)

## 🎲 The Science Behind the Randomness

### Decision Algorithm
The Oracle uses a weighted random number generator that considers:

1. **Base Threshold (10%)**: Minimum chance to skip any purchase
2. **Available Budget Ratio**: More available money = higher chance to buy
3. **Strictness Multiplier**: Your personal risk tolerance
4. **Fixed Costs Impact**: Accounts for essential expenses

### Example Calculation
```
Current Balance: $2000
Last Month Spend: $1500
Available Budget: $500
Fixed Costs: $300
Available After Fixed: $200
Strictness: 70%

Available Ratio = $200 / $500 = 0.4 (40%)
Threshold = 10% + (70% × 40%) = 38%

Random Roll: 45% > 38% = BUY IT! 🎉
```

### Psychological Benefits
- **Reduces Decision Fatigue**: No more mental energy spent on small purchases
- **Eliminates Buyer's Remorse**: "The algorithm decided, not me"
- **Creates Healthy Boundaries**: Automatic spending limits based on real data
- **Gamifies Budgeting**: Makes financial decisions fun and engaging

## 🤝 Contributing

This is a personal project, but feedback and suggestions are welcome! Feel free to:
- Report bugs or issues
- Suggest new features
- Share your experience using the app

## 📄 License

This project is for personal use. Feel free to modify and adapt for your own needs.

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing cross-platform framework
- **Material Design** - For the beautiful design system
- **The Concept of Bounded Rationality** - For the philosophical foundation

---

## 🎯 Quick Start Example

1. **Launch RNG Capitalist**
2. **Enter**: Balance: $1000, Last Month: $800, Item: "Coffee Maker", Price: $150
3. **Result**: Available Budget: $200, Oracle says: "SKIP IT! - Your wallet thanks you."
4. **Try Again**: Item: "Book", Price: $20, Oracle says: "BUY IT! - Life is short, money is fake!"

**Remember**: The Oracle is wise, but you're still in control. Use it as a tool to make more mindful spending decisions! 🎲💰

---

*"We don't have infinite willpower or mental bandwidth, so why not externalize decision-making into an algorithm?"*
