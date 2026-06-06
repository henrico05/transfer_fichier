import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_card.dart';
import '../../domain/entities/device.dart';

class TransferScreen extends ConsumerStatefulWidget {
  final Device? targetDevice;

  const TransferScreen({super.key, this.targetDevice});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final List<PlatformFile> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.targetDevice != null
              ? 'Envoyer à ${widget.targetDevice!.name}'
              : 'Transferts en cours',
        ),
        actions: [
          if (widget.targetDevice != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _selectFiles(),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedFiles.isNotEmpty && widget.targetDevice != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedFiles.length} fichier(s) sélectionné(s)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _selectedFiles.map((file) {
                      return Chip(
                        label: Text(file.name),
                        onDeleted: () {
                          setState(() {
                            _selectedFiles.remove(file);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _startTransfer(),
                    icon: const Icon(Icons.send),
                    label: const Text('Envoyer'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child:
                transferState.activeTransfers.isEmpty &&
                    transferState.completedTransfers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun transfert actif',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sélectionnez un appareil et des fichiers pour commencer',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      if (transferState.activeTransfers.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Transferts en cours',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        ...transferState.activeTransfers.map((session) {
                          return TransferCard(
                            session: session,
                            onCancel: () {
                              ref
                                  .read(transferProvider.notifier)
                                  .cancelTransfer(session.id);
                            },
                          );
                        }),
                      ],
                      if (transferState.completedTransfers.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Historique',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(transferProvider.notifier)
                                      .clearHistory();
                                },
                                child: const Text('Effacer'),
                              ),
                            ],
                          ),
                        ),
                        ...transferState.completedTransfers.map((session) {
                          return TransferCard(session: session);
                        }),
                      ],
                    ],
                  ),
          ),
        ],
        
      ),
    );
  }

  Future<void> _selectFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4', 'pdf', 'doc', 'txt', 'zip'],
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  Future<void> _startTransfer() async {
    if (widget.targetDevice == null) return;

    for (var i = 0; i < _selectedFiles.length; i++) {
      // Démarrer le transfert pour chaque fichier
      // Implémentation du transfert réel
    }

    setState(() {
      _selectedFiles.clear();
    });
  }
}
