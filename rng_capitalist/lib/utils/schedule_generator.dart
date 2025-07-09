// lib/utils/schedule_generator.dart
import 'dart:math';
import '../models/sunk_cost.dart';

class ScheduleGenerator {
  static DailySchedule generateDailySchedule({
    required List<SunkCost> sunkCosts,
    required DateTime date,
    required int periodDurationHours,
  }) {
    // Filter only active sunk costs
    final activeSunkCosts = sunkCosts.where((cost) => cost.isActive).toList();
    
    if (activeSunkCosts.isEmpty) {
      return DailySchedule(
        date: date,
        periods: [],
        totalSunkCostValue: 0.0,
      );
    }

    // Calculate total sunk cost value for probability distribution
    final totalValue = activeSunkCosts.fold(0.0, (sum, cost) => sum + cost.amount);
    
    // Calculate probability ranges for each sunk cost
    final probabilityRanges = <SunkCost, double>{};
    double cumulativeProbability = 0.0;
    
    for (var cost in activeSunkCosts) {
      final probability = cost.amount / totalValue;
      cumulativeProbability += probability;
      probabilityRanges[cost] = cumulativeProbability;
    }

    // Generate periods for the day (24 hours)
    final periods = <SchedulePeriod>[];
    final random = Random();
    
    // Start at beginning of day
    var currentTime = DateTime(date.year, date.month, date.day, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59);
    
    while (currentTime.isBefore(endOfDay)) {
      // Calculate end time for this period
      var periodEnd = currentTime.add(Duration(hours: periodDurationHours));
      
      // Don't go past end of day
      if (periodEnd.isAfter(endOfDay)) {
        periodEnd = endOfDay;
      }
      
      // Select sunk cost based on weighted probability
      final randomValue = random.nextDouble();
      SunkCost? selectedCost;
      
      for (var entry in probabilityRanges.entries) {
        if (randomValue <= entry.value) {
          selectedCost = entry.key;
          break;
        }
      }
      
      // Fallback to first cost if none selected (shouldn't happen)
      selectedCost ??= activeSunkCosts.first;
      
      // Generate activity based on sunk cost
      final activity = _generateActivity(selectedCost);
      
      periods.add(SchedulePeriod(
        startTime: currentTime,
        endTime: periodEnd,
        sunkCost: selectedCost,
        activity: activity,
      ));
      
      currentTime = periodEnd;
      
      // Break if we've reached end of day
      if (currentTime.isAtSameMomentAs(endOfDay)) {
        break;
      }
    }

    return DailySchedule(
      date: date,
      periods: periods,
      totalSunkCostValue: totalValue,
    );
  }

  static String _generateActivity(SunkCost sunkCost) {
    // Generate activity suggestions based on category and name
    final category = sunkCost.category.toLowerCase();
    
    // Category-based activity suggestions
    if (category.contains('education') || category.contains('learning')) {
      return _getEducationActivity(sunkCost);
    } else if (category.contains('game') || category.contains('gaming') || category.contains('entertainment')) {
      return _getGamingActivity(sunkCost);
    } else if (category.contains('fitness') || category.contains('health') || category.contains('gym')) {
      return _getFitnessActivity(sunkCost);
    } else if (category.contains('hobby') || category.contains('creative')) {
      return _getHobbyActivity(sunkCost);
    } else if (category.contains('subscription') || category.contains('service')) {
      return _getSubscriptionActivity(sunkCost);
    } else {
      return _getGenericActivity(sunkCost);
    }
  }

  static String _getEducationActivity(SunkCost sunkCost) {
    final activities = [
      'Study ${sunkCost.name}',
      'Review ${sunkCost.name} materials',
      'Practice exercises for ${sunkCost.name}',
      'Work on ${sunkCost.name} assignments',
      'Research ${sunkCost.name} topics',
    ];
    return activities[Random().nextInt(activities.length)];
  }

  static String _getGamingActivity(SunkCost sunkCost) {
    final activities = [
      'Play ${sunkCost.name}',
      'Complete ${sunkCost.name} missions',
      'Explore ${sunkCost.name} world',
      'Practice ${sunkCost.name} skills',
      'Watch ${sunkCost.name} tutorials',
    ];
    return activities[Random().nextInt(activities.length)];
  }

  static String _getFitnessActivity(SunkCost sunkCost) {
    final activities = [
      'Use ${sunkCost.name} for workout',
      'Practice with ${sunkCost.name}',
      'Train using ${sunkCost.name}',
      'Exercise with ${sunkCost.name}',
      'Follow ${sunkCost.name} routine',
    ];
    return activities[Random().nextInt(activities.length)];
  }

  static String _getHobbyActivity(SunkCost sunkCost) {
    final activities = [
      'Work on ${sunkCost.name} project',
      'Practice ${sunkCost.name}',
      'Create with ${sunkCost.name}',
      'Improve ${sunkCost.name} skills',
      'Explore ${sunkCost.name} possibilities',
    ];
    return activities[Random().nextInt(activities.length)];
  }

  static String _getSubscriptionActivity(SunkCost sunkCost) {
    final activities = [
      'Use ${sunkCost.name}',
      'Explore ${sunkCost.name} features',
      'Learn ${sunkCost.name} tools',
      'Work with ${sunkCost.name}',
      'Make the most of ${sunkCost.name}',
    ];
    return activities[Random().nextInt(activities.length)];
  }

  static String _getGenericActivity(SunkCost sunkCost) {
    final activities = [
      'Use ${sunkCost.name}',
      'Make the most of ${sunkCost.name}',
      'Work with ${sunkCost.name}',
      'Practice with ${sunkCost.name}',
      'Explore ${sunkCost.name}',
    ];
    return activities[Random().nextInt(activities.length)];
  }

  // Google Calendar URL generator
  static String generateGoogleCalendarUrl(DailySchedule schedule) {
    const baseUrl = 'https://calendar.google.com/calendar/render?action=TEMPLATE';
    final scheduleDate = schedule.date;
    
    // Create a single all-day event with the schedule details
    final title = 'Sunk Cost Recovery Schedule - ${_formatDate(scheduleDate)}';
    final details = _generateScheduleDetails(schedule);
    
    final params = {
      'text': Uri.encodeComponent(title),
      'dates': '${_formatDateForGoogle(scheduleDate)}/${_formatDateForGoogle(scheduleDate.add(const Duration(days: 1)))}',
      'details': Uri.encodeComponent(details),
    };
    
    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return '$baseUrl&$queryString';
  }

  static String _generateScheduleDetails(DailySchedule schedule) {
    final buffer = StringBuffer();
    buffer.writeln('Daily Sunk Cost Recovery Schedule');
    buffer.writeln('Total Value: \$${schedule.totalSunkCostValue.toStringAsFixed(2)}');
    buffer.writeln('');
    
    for (var i = 0; i < schedule.periods.length; i++) {
      final period = schedule.periods[i];
      final startTime = '${period.startTime.hour.toString().padLeft(2, '0')}:${period.startTime.minute.toString().padLeft(2, '0')}';
      final endTime = '${period.endTime.hour.toString().padLeft(2, '0')}:${period.endTime.minute.toString().padLeft(2, '0')}';
      
      buffer.writeln('$startTime - $endTime: ${period.activity}');
      buffer.writeln('  Investment: ${period.sunkCost.name} (\$${period.sunkCost.amount.toStringAsFixed(2)})');
      buffer.writeln('  Category: ${period.sunkCost.category}');
      if (i < schedule.periods.length - 1) {
        buffer.writeln('');
      }
    }
    
    return buffer.toString();
  }

  static String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  static String _formatDateForGoogle(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }
}
