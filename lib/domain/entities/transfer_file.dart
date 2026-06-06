import 'package:equatable/equatable.dart';
import 'dart:io';

class TransferFile extends Equatable {
  final String id;
  final String name;
  final String path;
  final int size;
  final String type;
  final DateTime createdAt;
  final String? thumbnailPath;

  const TransferFile({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.type,
    required this.createdAt,
    this.thumbnailPath,
  });

  factory TransferFile.fromPath(String path) {
    final file = File(path);
    final name = file.path.split('/').last;
    final extension = name.split('.').last;

    return TransferFile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      path: path,
      size: file.lengthSync(),
      type: extension,
      createdAt: DateTime.now(),
    );
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} KB';
    if (size < 1024 * 1024 * 1024)
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get fileExtension => name.split('.').last.toLowerCase();

  bool get isImage {
    const images = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return images.contains(fileExtension);
  }

  bool get isVideo {
    const videos = ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv'];
    return videos.contains(fileExtension);
  }

  bool get isDocument {
    const docs = ['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'];
    return docs.contains(fileExtension);
  }

  bool get isAudio {
    const audios = ['mp3', 'wav', 'ogg', 'm4a', 'flac'];
    return audios.contains(fileExtension);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    path,
    size,
    type,
    createdAt,
    thumbnailPath,
  ];
}
