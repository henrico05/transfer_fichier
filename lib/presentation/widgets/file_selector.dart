import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileSelector extends ConsumerStatefulWidget {
  final Function(List<PlatformFile>) onFilesSelected;
  final bool allowMultiple;
  final List<String>? allowedExtensions;

  const FileSelector({
    super.key,
    required this.onFilesSelected,
    this.allowMultiple = true,
    this.allowedExtensions,
  });

  @override
  ConsumerState<FileSelector> createState() => _FileSelectorState();
}

class _FileSelectorState extends ConsumerState<FileSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.attach_file),
          label: const Text('Sélectionner des fichiers'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _pickFolder(),
          icon: const Icon(Icons.folder_open),
          label: const Text('Sélectionner un dossier'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: widget.allowMultiple,
      type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: widget.allowedExtensions,
    );

    if (result != null && result.files.isNotEmpty) {
      widget.onFilesSelected(result.files);
    }
  }

  Future<void> _pickFolder() async {
    final result = await FilePicker.getDirectoryPath();

    if (result != null) {
      // Implémentation pour sélectionner un dossier
      // et récupérer tous les fichiers
    }
  }
}
