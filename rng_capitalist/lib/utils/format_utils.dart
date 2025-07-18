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

  static String formatCooldownDuration(Duration duration) {
    if (duration.inDays >= 365) {
      return '~1 year';
    } else if (duration.inDays >= 30) {
      final months = (duration.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else if (duration.inDays >= 7) {
      final weeks = (duration.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''}';
    } else if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Less than a minute';
    }
  }

  static String formatCooldownStatus(Duration? remainingCooldown) {
    if (remainingCooldown == null) return '';
    return 'Cooldown: ${formatCooldownDuration(remainingCooldown)} remaining';
  }
}
