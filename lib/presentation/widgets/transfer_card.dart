import 'package:flutter/material.dart';
import '../../presentation/providers/transfer_provider.dart';

class TransferCard extends StatelessWidget {
  final TransferSession session;
  final VoidCallback? onCancel;

  const TransferCard({super.key, required this.session, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  session.direction == TransferDirection.send
                      ? Icons.upload
                      : Icons.download,
                  color: session.direction == TransferDirection.send
                      ? Colors.blue
                      : Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.file.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${session.file.formattedSize} • ${session.targetDevice}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (session.status == TransferStatus.inProgress)
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: onCancel,
                  ),
              ],
            ),
            if (session.status == TransferStatus.inProgress) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: session.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  session.direction == TransferDirection.send
                      ? Colors.blue
                      : Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(session.progress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '${session.currentSpeed.toStringAsFixed(2)} KB/s • ${session.remainingTime}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (session.status) {
      case TransferStatus.pending:
        return 'En attente';
      case TransferStatus.completed:
        return 'Terminé';
      case TransferStatus.failed:
        return 'Échoué';
      case TransferStatus.cancelled:
        return 'Annulé';
      default:
        return '';
    }
  }

  Color _getStatusColor() {
    switch (session.status) {
      case TransferStatus.completed:
        return Colors.green;
      case TransferStatus.failed:
        return Colors.red;
      case TransferStatus.cancelled:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
