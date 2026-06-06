import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/device_provider.dart';
import '../widgets/device_card.dart';

class DeviceListScreen extends ConsumerStatefulWidget {
  const DeviceListScreen({super.key});

  @override
  ConsumerState<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends ConsumerState<DeviceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceProvider.notifier).discoverDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appareils disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(deviceProvider.notifier).discoverDevices();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(deviceProvider.notifier).discoverDevices();
        },
        child: deviceState.isDiscovering
            ? const Center(child: CircularProgressIndicator())
            : deviceState.devices.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.portable_wifi_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun appareil trouvé',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Assurez-vous que d\'autres appareils sont connectés au même réseau',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(deviceProvider.notifier).discoverDevices();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Rechercher'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: deviceState.devices.length,
                itemBuilder: (context, index) {
                  final device = deviceState.devices[index];
                  return DeviceCard(
                    device: device,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/transfer',
                        arguments: device,
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: deviceState.currentDevice != null
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Mon appareil'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom: ${deviceState.currentDevice!.name}'),
                        const SizedBox(height: 8),
                        Text('IP: ${deviceState.currentDevice!.ipAddress}'),
                        const SizedBox(height: 8),
                        Text('Port: ${deviceState.currentDevice!.port}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.info),
              label: Text(deviceState.currentDevice!.name),
            )
          : null,
    );
  }
}
