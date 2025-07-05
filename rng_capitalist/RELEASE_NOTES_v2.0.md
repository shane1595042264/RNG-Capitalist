# RNG Capitalist - Version 2.0 Release Notes

## 🚀 Major Features Added

### Enhanced Budget Logic
- **Remaining Budget System**: Decisions now based on `Available Budget - Fixed Costs`
- **Pure Price Ratio**: Removed 15% base threshold for more intuitive control
- **Smart Validation**: Prevents purchases exceeding remaining budget

### Fixed Costs Management
- **Category Organization**: Housing, Transportation, Food, Utilities, Insurance, Other
- **Edit Functionality**: Modify existing costs with pen icon
- **Real-time Updates**: Automatic recalculation of budgets
- **Active/Inactive Toggle**: Temporarily disable costs without deleting

### Advanced Strictness Control
- **0% to 300% Range**: Much wider control spectrum
- **Default 100%**: Pure price ratio as baseline
- **0% Mode**: Always approve purchases
- **300% Mode**: Extremely strict approval

## 🎯 How the New Oracle Works

### Decision Formula
```
Remaining Budget = Available Budget - Fixed Costs
Price Ratio = Item Price ÷ Remaining Budget
Decision Threshold = Strictness × Price Ratio
Random Roll vs Threshold → BUY IT or SKIP IT
```

### Example Scenarios
- **Item costs 25% of remaining budget at 100% strictness**: 25% threshold
- **Same item at 200% strictness**: 50% threshold (much harder to approve)
- **Same item at 0% strictness**: 0% threshold (always approved)

## 🔧 Technical Improvements

### User Interface
- **Green highlighting** for remaining budget field
- **Tooltips** on edit and delete buttons
- **Improved spacing** and visual hierarchy
- **Better error handling** and validation

### Data Persistence
- **SharedPreferences storage** for all settings
- **Purchase history** tracking up to 100 decisions
- **Fixed costs** automatically saved and loaded

## 📊 Statistics & History

### Enhanced Tracking
- **Detailed decision logs** with threshold vs roll values
- **Price ratio calculations** shown in results
- **Timestamp formatting** (just now, 5m ago, yesterday, etc.)
- **Category-based organization** of fixed costs

## 🎨 Philosophy & Design

RNG Capitalist embraces **bounded rationality** - we have limited mental bandwidth for decisions. By externalizing purchase choices to a smart algorithm, we:

- **Reduce decision fatigue**
- **Minimize buyer's remorse**
- **Make spending more intentional**
- **Add an element of fun to budgeting**

---

**Build**: Windows x64 Release  
**Size**: ~10.5 MB  
**Requirements**: Windows 10+ (64-bit)  
**Installation**: Portable - no installer needed!

## 🎯 Coming Next (Phase 3)
- AI-powered budget analysis
- Smart spending recommendations  
- Personality modes (Conservative, Balanced, YOLO)
- Monthly budget reset automation
