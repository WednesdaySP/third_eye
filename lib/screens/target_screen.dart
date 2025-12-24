import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/target_board.dart';
import '../widgets/range_indicator.dart';
import '../services/shooting_service.dart';
import '../models/shot_data.dart';
import 'dart:math';

/// Target Screen - Core shooting practice screen
/// Shows target board, range indicator, and shooting statistics
class TargetScreen extends StatefulWidget {
  const TargetScreen({super.key});

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  final Random _random = Random();
  bool _isShooting = false;

  /// Simulate taking a shot
  void _takeShot(BuildContext context) async {
    if (_isShooting) return;

    setState(() {
      _isShooting = true;
    });

    // Generate random shot coordinates (normalized -1 to 1)
    final double x = (_random.nextDouble() * 2 - 1) * 0.8; // -0.8 to 0.8
    final double y = (_random.nextDouble() * 2 - 1) * 0.8;

    // Calculate accuracy based on distance from center
    final double distance = sqrt(x * x + y * y);
    final double accuracy = max(0, (1 - distance) * 100);

    // Create shot data
    final shot = ShotData(
      x: x,
      y: y,
      accuracy: accuracy,
      timestamp: DateTime.now(),
    );

    // Add shot to service
    Provider.of<ShootingService>(context, listen: false).addShot(shot);

    // Play shot animation
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isShooting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Practice'),
        actions: [
          // Analytics button
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => context.push('/analytics'),
            tooltip: 'View Analytics',
          ),
        ],
      ),
      body: Consumer<ShootingService>(
        builder: (context, shootingService, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Shots',
                          value: shootingService.shots.length.toString(),
                          icon: Icons.sports_score,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Avg Accuracy',
                          value: '${shootingService.averageAccuracy.toStringAsFixed(1)}%',
                          icon: Icons.emoji_events,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Range Indicator
                  const RangeIndicator(
                    currentRange: 25.0,
                    maxRange: 50.0,
                  ),
                  const SizedBox(height: 24),

                  // Target Board
                  TargetBoard(
                    shots: shootingService.shots,
                    isAnimating: _isShooting,
                  ),
                  const SizedBox(height: 32),

                  // Shoot Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isShooting
                          ? null
                          : () => _takeShot(context),
                      icon: Icon(_isShooting ? Icons.hourglass_empty : Icons.gps_fixed),
                      label: Text(_isShooting ? 'Shooting...' : 'Take Shot'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isShooting
                            ? Colors.grey[700]
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reset Button
                  if (shootingService.shots.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Reset Session'),
                            content: const Text(
                              'Are you sure you want to clear all shot data?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  shootingService.clearShots();
                                  Navigator.pop(context);
                                },
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Session'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Stat Card Widget - Displays shooting statistics
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}