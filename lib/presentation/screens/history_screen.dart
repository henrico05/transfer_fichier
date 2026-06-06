import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferState = ref.watch(transferProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des transferts'),
        actions: [
          if (transferState.completedTransfers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Effacer l\'historique'),
                    content: const Text(
                      'Voulez-vous vraiment effacer tout l\'historique des transferts ?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(transferProvider.notifier).clearHistory();
                          Navigator.pop(context);
                        },
                        child: const Text('Effacer'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: transferState.completedTransfers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun historique',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les transferts terminés apparaîtront ici',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: transferState.completedTransfers.length,
              itemBuilder: (context, index) {
                final session = transferState.completedTransfers[index];
                return TransferCard(session: session);
              },
            ),
    );
  }
}
