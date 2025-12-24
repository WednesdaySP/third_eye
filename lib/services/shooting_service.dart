import 'package:flutter/foundation.dart';
import '../models/shot_data.dart';

/// Service class for managing shooting session data
/// Uses ChangeNotifier for state management
class ShootingService extends ChangeNotifier {
  final List<ShotData> _shots = [];

  /// Get all shots in current session
  List<ShotData> get shots => List.unmodifiable(_shots);

  /// Calculate average accuracy across all shots
  double get averageAccuracy {
    if (_shots.isEmpty) return 0.0;
    double sum = _shots.fold(0, (prev, shot) => prev + shot.accuracy);
    return sum / _shots.length;
  }

  /// Get best accuracy shot
  double get bestAccuracy {
    if (_shots.isEmpty) return 0.0;
    return _shots.map((shot) => shot.accuracy).reduce((a, b) => a > b ? a : b);
  }

  /// Get worst accuracy shot
  double get worstAccuracy {
    if (_shots.isEmpty) return 0.0;
    return _shots.map((shot) => shot.accuracy).reduce((a, b) => a < b ? a : b);
  }

  /// Get total number of shots
  int get totalShots => _shots.length;

  /// Add a new shot to the session
  void addShot(ShotData shot) {
    _shots.add(shot);
    notifyListeners();
  }

  /// Clear all shots (reset session)
  void clearShots() {
    _shots.clear();
    notifyListeners();
  }

  /// Get shots within a specific accuracy range
  List<ShotData> getShotsInRange(double minAccuracy, double maxAccuracy) {
    return _shots
        .where((shot) =>
            shot.accuracy >= minAccuracy && shot.accuracy <= maxAccuracy)
        .toList();
  }

  /// Calculate consistency (standard deviation of accuracy)
  double get consistencyScore {
    if (_shots.length < 2) return 0.0;

    double mean = averageAccuracy;
    double variance = _shots.fold(
          0.0,
          (sum, shot) => sum + ((shot.accuracy - mean) * (shot.accuracy - mean)),
        ) /
        _shots.length;

    return variance; // Lower is more consistent
  }
}