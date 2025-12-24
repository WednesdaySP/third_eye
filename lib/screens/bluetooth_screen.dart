import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bluetooth Connection Screen
/// Allows user to simulate connecting to a Bluetooth device
class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen>
    with SingleTickerProviderStateMixin {
  bool _isConnecting = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Bluetooth icon pulse animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Simulate Bluetooth connection process
  Future<void> _connectBluetooth() async {
    setState(() {
      _isConnecting = true;
    });

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Device connected successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to target screen
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.go('/target');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Connection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Bluetooth Icon
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_animationController.value * 0.2),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.bluetooth,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),

            // Title
            Text(
              'Connect Your Device',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Connect your shooting device via Bluetooth\nto start tracking your performance',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[400],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Connection Status
            if (_isConnecting)
              Column(
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Connecting...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            else
              // Connect Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _connectBluetooth,
                  icon: const Icon(Icons.bluetooth_connected),
                  label: const Text('Connect via Bluetooth'),
                ),
              ),
            const SizedBox(height: 24),

            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Make sure your device is powered on and in pairing mode',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}