class AppConstants {
  static const String appName = 'Local File Transfer';
  static const String version = '1.0.0';

  // Network constants
  static const int discoveryPort = 5000;
  static const int transferPort = 5001;
  static const int chunkSize = 64 * 1024; // 64KB
  static const int maxConcurrentTransfers = 3;
  static const int connectionTimeout = 30; // seconds
  static const int bufferSize = 8192;

  // Storage constants
  static const String downloadFolder = 'LocalFileTransfer';
  static const int maxHistorySize = 100;
  static const int minFreeSpaceMB = 100;

  // Security constants
  static const int pinCodeLength = 6;
  static const int pinCodeExpiryMinutes = 5;
  static const int maxFailedAttempts = 3;

  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);

  // Transfer constants
  static const int maxRetries = 3;
  static const int retryDelaySeconds = 2;
  static const int heartbeatIntervalSeconds = 5;
  static const int transferTimeoutSeconds = 300; // 5 minutes

  // File types
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
  ];
  static const List<String> videoExtensions = [
    'mp4',
    'avi',
    'mkv',
    'mov',
    'wmv',
    'flv',
  ];
  static const List<String> documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'rtf',
    'odt',
  ];
  static const List<String> audioExtensions = [
    'mp3',
    'wav',
    'ogg',
    'm4a',
    'flac',
  ];
  static const List<String> archiveExtensions = [
    'zip',
    'rar',
    '7z',
    'tar',
    'gz',
  ];

  // Error messages
  static const String errorNoNetwork = 'Aucune connexion réseau détectée';
  static const String errorInsufficientSpace = 'Espace disque insuffisant';
  static const String errorPermissionDenied = 'Permissions refusées';
  static const String errorFileNotFound = 'Fichier introuvable';
  static const String errorTransferFailed = 'Échec du transfert';
  static const String errorDeviceNotFound = 'Appareil non trouvé';
  static const String errorInvalidPin = 'Code PIN invalide';
  static const String errorPinExpired = 'Code PIN expiré';

  // Success messages
  static const String successTransferComplete = 'Transfert terminé avec succès';
  static const String successConnectionEstablished = 'Connexion établie';

  // Database
  static const String databaseName = 'transfers.db';
  static const int databaseVersion = 1;

  // Shared Preferences Keys
  static const String prefDeviceId = 'device_id';
  static const String prefDeviceName = 'device_name';
  static const String prefDarkMode = 'dark_mode';
  static const String prefCompressionEnabled = 'compression_enabled';
  static const String prefEncryptionEnabled = 'encryption_enabled';
  static const String prefSavePath = 'save_path';

  // MIME types
  static const Map<String, String> mimeTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'mp4': 'video/mp4',
    'pdf': 'application/pdf',
    'mp3': 'audio/mpeg',
    'zip': 'application/zip',
  };
}
