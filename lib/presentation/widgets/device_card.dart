import 'package:flutter/material.dart';
import '../../domain/entities/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;

  const DeviceCard({
    super.key,
    required this.device,
    this.onTap,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: device.isConnected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDeviceIcon(),
                  color: device.isConnected ? Colors.green : Colors.grey,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.ipAddress,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: device.isConnected
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          device.isConnected ? 'Connecté' : 'Hors ligne',
                          style: TextStyle(
                            fontSize: 12,
                            color: device.isConnected
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onConnect != null)
                IconButton(
                  icon: Icon(
                    device.isConnected ? Icons.link_off : Icons.link,
                    color: device.isConnected ? Colors.red : Colors.green,
                  ),
                  onPressed: onConnect,
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDeviceIcon() {
    if (device.name.toLowerCase().contains('phone')) {
      return Icons.phone_android;
    }
    if (device.name.toLowerCase().contains('computer') ||
        device.name.toLowerCase().contains('pc')) {
      return Icons.computer;
    }
    if (device.name.toLowerCase().contains('tablet')) {
      return Icons.tablet;
    }
    return Icons.devices;
  }
}
