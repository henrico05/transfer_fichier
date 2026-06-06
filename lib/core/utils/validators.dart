class Validators {
  static bool isValidIpAddress(String ip) {
    final RegExp ipRegex = RegExp(
      r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
      r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
      r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
      r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return ipRegex.hasMatch(ip);
  }

  static bool isValidPort(int port) {
    return port > 0 && port <= 65535;
  }

  static bool isValidPinCode(String pin) {
    final RegExp pinRegex = RegExp(r'^\d{6}$');
    return pinRegex.hasMatch(pin);
  }

  static bool isValidFileName(String fileName) {
    if (fileName.isEmpty || fileName.length > 255) return false;

    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    return !invalidChars.hasMatch(fileName);
  }

  static bool isValidFileSize(int size, int maxSizeMB) {
    final maxBytes = maxSizeMB * 1024 * 1024;
    return size <= maxBytes;
  }

  static bool isSupportedFileType(String extension) {
    const supportedExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'mp4',
      'avi',
      'mkv',
      'mov',
      'wmv',
      'flv',
      'mp3',
      'wav',
      'ogg',
      'm4a',
      'flac',
      'pdf',
      'doc',
      'docx',
      'txt',
      'rtf',
      'odt',
      'zip',
      'rar',
      '7z',
      'tar',
      'gz',
    ];
    return supportedExtensions.contains(extension.toLowerCase());
  }

  static String? validateDeviceName(String name) {
    if (name.isEmpty) return 'Le nom de l\'appareil est requis';
    if (name.length < 3) return 'Minimum 3 caractères';
    if (name.length > 50) return 'Maximum 50 caractères';
    return null;
  }

  static String? validateFilePath(String path) {
    if (path.isEmpty) return 'Le chemin du fichier est requis';
    if (path.length > 1024) return 'Chemin trop long';
    return null;
  }
}
