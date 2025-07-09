# Dynamic Cooldown System for RNG Capitalist

## Overview
The dynamic cooldown system prevents users from immediately re-rolling for the same item after it gets rejected (skipped). The cooldown duration is calculated based on the item's price relative to the available budget.

## How It Works

### Cooldown Calculation
- **Formula**: `cooldownDays = (itemPrice / availableBudget) * 365 + 1`
- **Minimum**: 1 day
- **Maximum**: 1 year (365 days)

### Examples
- **$10 item with $100 budget**: ratio = 0.1 → cooldown = 37.5 days
- **$50 item with $100 budget**: ratio = 0.5 → cooldown = 183.5 days  
- **$100 item with $100 budget**: ratio = 1.0 → cooldown = 366 days (capped at 365)

### User Experience

#### In Oracle Page
1. **Before Rolling**: System checks if item name is on cooldown
2. **If On Cooldown**: Shows warning message with remaining time, prevents rolling
3. **If Not On Cooldown**: Allows normal dice roll process
4. **After Rejection**: Calculates and sets cooldown, shows cooldown duration in message

#### In History Page
- Rejected items show an orange cooldown badge if still on cooldown
- Displays remaining time in human-readable format (years, months, weeks, days, hours, minutes)
- Badge disappears once cooldown expires

### Features
- **Case-insensitive matching**: "iPhone" and "iphone" are treated as same item
- **Persistent storage**: Cooldowns survive app restarts
- **Automatic cleanup**: Expired cooldowns are automatically ignored
- **Backward compatibility**: Existing purchase history works without cooldowns

### Technical Details
- Cooldown data is stored in the `PurchaseHistory` model
- Only rejected (skipped) items receive cooldowns
- Purchased items never have cooldowns
- Cooldown calculation uses the available budget at time of purchase
- Time formatting handles edge cases (less than minute, over a year)

## Usage Notes
- The system encourages thoughtful purchasing decisions
- More expensive items (relative to budget) have longer cooldowns
- Users can still roll for different items while one is on cooldown
- Cooldown times are calculated once and don't change if budget changes later
