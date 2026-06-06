import 'package:equatable/equatable.dart';

class FileModel extends Equatable {
  final String id;
  final String name;
  final String path;
  final int size;
  final String type;
  final String? checksum;
  final DateTime createdAt;
  final DateTime? modifiedAt;

  const FileModel({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.type,
    this.checksum,
    required this.createdAt,
    this.modifiedAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      size: json['size'],
      type: json['type'],
      checksum: json['checksum'],
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'])
          : null,
    );
  }

  factory FileModel.fromJsonDb(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      size: json['size'],
      type: json['type'],
      checksum: json['checksum'],
      createdAt: DateTime.parse(json['created_at']),
      modifiedAt: json['modified_at'] != null
          ? DateTime.parse(json['modified_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'size': size,
      'type': type,
      'checksum': checksum,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonDb() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'size': size,
      'type': type,
      'checksum': checksum,
      'created_at': createdAt.toIso8601String(),
      'modified_at': modifiedAt?.toIso8601String(),
    };
  }

  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    }
    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    }
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get fileExtension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

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
    checksum,
    createdAt,
    modifiedAt,
  ];
}
