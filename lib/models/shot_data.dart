/// Model class representing a single shot data point
/// Contains position coordinates, accuracy, and timestamp
class ShotData {
  final double x; // Normalized x coordinate (-1 to 1)
  final double y; // Normalized y coordinate (-1 to 1)
  final double accuracy; // Accuracy percentage (0-100)
  final DateTime timestamp;

  ShotData({
    required this.x,
    required this.y,
    required this.accuracy,
    required this.timestamp,
  });

  /// Calculate distance from center (0,0)
  double get distanceFromCenter {
    return (x * x + y * y).abs();
  }

  /// Convert to JSON for potential storage
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ShotData.fromJson(Map<String, dynamic> json) {
    return ShotData(
      x: json['x'] as double,
      y: json['y'] as double,
      accuracy: json['accuracy'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}