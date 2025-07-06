class FormatUtils {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  static String getStrictnessDescription(double strictnessLevel) {
    if (strictnessLevel == 0.0) {
      return 'OFF - Always approve (0% threshold)';
    } else if (strictnessLevel < 0.5) {
      return 'Generous - Low resistance to purchases';
    } else if (strictnessLevel < 1.0) {
      return 'Moderate - Some price sensitivity';
    } else if (strictnessLevel == 1.0) {
      return 'Balanced - Pure price ratio (Default)';
    } else if (strictnessLevel < 2.0) {
      return 'Strict - High price sensitivity';
    } else if (strictnessLevel < 3.0) {
      return 'Very Strict - Maximum resistance';
    } else {
      return 'Extreme - Nearly impossible approval';
    }
  }
}
