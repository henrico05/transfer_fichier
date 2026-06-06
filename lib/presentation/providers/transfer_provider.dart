import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transfer_file.dart';
import '../../core/network/network_service.dart';

class TransferState {
  final List<TransferSession> activeTransfers;
  final List<TransferSession> completedTransfers;
  final bool isReceiving;
  final double globalProgress;

  TransferState({
    this.activeTransfers = const [],
    this.completedTransfers = const [],
    this.isReceiving = false,
    this.globalProgress = 0.0,
  });

  TransferState copyWith({
    List<TransferSession>? activeTransfers,
    List<TransferSession>? completedTransfers,
    bool? isReceiving,
    double? globalProgress,
  }) {
    return TransferState(
      activeTransfers: activeTransfers ?? this.activeTransfers,
      completedTransfers: completedTransfers ?? this.completedTransfers,
      isReceiving: isReceiving ?? this.isReceiving,
      globalProgress: globalProgress ?? this.globalProgress,
    );
  }
}

class TransferSession {
  final String id;
  final TransferFile file;
  final String targetDevice;
  final TransferDirection direction;
  final DateTime startTime;
  int transferredBytes;
  int totalBytes;
  TransferStatus status;
  double currentSpeed;

  TransferSession({
    required this.id,
    required this.file,
    required this.targetDevice,
    required this.direction,
    required this.startTime,
    this.transferredBytes = 0,
    required this.totalBytes,
    this.status = TransferStatus.pending,
    this.currentSpeed = 0.0,
  });

  double get progress => transferredBytes / totalBytes;
  String get remainingTime {
    if (currentSpeed <= 0) return 'Calcul...';
    final remainingBytes = totalBytes - transferredBytes;
    final seconds = remainingBytes / (currentSpeed * 1024);
    if (seconds < 60) return '${seconds.toStringAsFixed(0)}s';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(0)}min';
    return '${(seconds / 3600).toStringAsFixed(1)}h';
  }
}

enum TransferDirection { send, receive }

enum TransferStatus { pending, inProgress, completed, failed, cancelled }

class TransferNotifier extends StateNotifier<TransferState> {
  final NetworkService _networkService;

  TransferNotifier(this._networkService) : super(TransferState());

  Future<void> sendFile(TransferFile file, String targetIp) async {
    final session = TransferSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      file: file,
      targetDevice: targetIp,
      direction: TransferDirection.send,
      startTime: DateTime.now(),
      totalBytes: file.size,
    );

    state = state.copyWith(
      activeTransfers: [...state.activeTransfers, session],
    );

    try {
      await _networkService.sendFile(
        targetIp,
        file,
        (sent, total) {
          final index = state.activeTransfers.indexWhere(
            (s) => s.id == session.id,
          );
          if (index != -1) {
            state.activeTransfers[index].transferredBytes = sent;
            state.activeTransfers[index].status = TransferStatus.inProgress;
            state = state.copyWith(activeTransfers: [...state.activeTransfers]);
          }
        },
        (speed) {
          final index = state.activeTransfers.indexWhere(
            (s) => s.id == session.id,
          );
          if (index != -1) {
            state.activeTransfers[index].currentSpeed = speed;
            state = state.copyWith(activeTransfers: [...state.activeTransfers]);
          }
        },
      );

      // Transfert terminé
      final completedSession = state.activeTransfers.firstWhere(
        (s) => s.id == session.id,
      );
      completedSession.status = TransferStatus.completed;

      state = state.copyWith(
        activeTransfers: state.activeTransfers
            .where((s) => s.id != session.id)
            .toList(),
        completedTransfers: [...state.completedTransfers, completedSession],
      );
    } catch (e) {
      final failedSession = state.activeTransfers.firstWhere(
        (s) => s.id == session.id,
      );
      failedSession.status = TransferStatus.failed;
      state = state.copyWith(
        activeTransfers: state.activeTransfers
            .where((s) => s.id != session.id)
            .toList(),
        completedTransfers: [...state.completedTransfers, failedSession],
      );
    }
  }

  void cancelTransfer(String sessionId) {
    final index = state.activeTransfers.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      state.activeTransfers[index].status = TransferStatus.cancelled;
      state = state.copyWith(
        activeTransfers: state.activeTransfers
            .where((s) => s.id != sessionId)
            .toList(),
        completedTransfers: [
          ...state.completedTransfers,
          state.activeTransfers[index],
        ],
      );
    }
  }

  void clearHistory() {
    state = state.copyWith(completedTransfers: []);
  }
}

final transferProvider = StateNotifierProvider<TransferNotifier, TransferState>(
  (ref) {
    return TransferNotifier(NetworkService());
  },
);
