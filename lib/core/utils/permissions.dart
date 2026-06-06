import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  // Initialisation générale
  static Future<void> initializePermissions() async {
    if (kIsWeb) return;

    debugPrint('Initialisation des permissions...');

    if (Platform.isAndroid || Platform.isIOS) {
      final granted = await requestStoragePermissions();

      if (!granted) {
        debugPrint('Attention: permissions stockage refusées');
      }
    }

    await requestNetworkPermissions();
  }

  // Permissions stockage
  static Future<bool> requestStoragePermissions() async {
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        // Android 11+
        if (await Permission.manageExternalStorage.isGranted) {
          debugPrint('manageExternalStorage déjà accordée');

          return true;
        }

        PermissionStatus status = await Permission.manageExternalStorage
            .request();

        // Fallback Android ancien
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        if (status.isGranted) {
          debugPrint('Permissions stockage accordées');

          return true;
        }

        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }

        return false;
      }

      // iOS
      if (Platform.isIOS) {
        final status = await Permission.photos.request();

        return status.isGranted;
      }

      return true;
    } catch (e) {
      debugPrint('Erreur permission stockage: $e');

      return false;
    }
  }

  // Permissions réseau
  static Future<bool> requestNetworkPermissions() async {
    // INTERNET/WIFI gérés dans AndroidManifest.xml
    return true;
  }

  // Vérifier espace disponible
  static Future<bool> checkStorageSpace() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      return await directory.exists();
    } catch (e) {
      debugPrint('Erreur vérification stockage: $e');

      return false;
    }
  }

  // Obtenir chemin stockage
  static Future<String> getAvailablePath() async {
    if (kIsWeb) {
      return 'downloads';
    }

    try {
      final directory = await getExternalStorageDirectory();

      if (directory != null) {
        debugPrint('Stockage externe: ${directory.path}');

        return directory.path;
      }
    } catch (e) {
      debugPrint('Erreur stockage externe: $e');
    }

    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  // Vérification réseau
  static Future<bool> isNetworkAvailable() async {
    return true;
  }

  // Android 13+
  static Future<bool> requestAndroid13Permissions() async {
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        final sdkInt = await _getAndroidSdkVersion();

        if (sdkInt >= 33) {
          final photos = await Permission.photos.request();

          final videos = await Permission.videos.request();

          final audio = await Permission.audio.request();

          return photos.isGranted || videos.isGranted || audio.isGranted;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Erreur Android13 permissions: $e');

      return false;
    }
  }

  // SDK Android
  static Future<int> _getAndroidSdkVersion() async {
    return 30;
  }

  // Demander toutes permissions
  static Future<Map<Permission, PermissionStatus>>
  requestAllPermissions() async {
    final permissions = <Permission>[];

    if (!kIsWeb && Platform.isAndroid) {
      permissions.add(Permission.storage);
      permissions.add(Permission.manageExternalStorage);

      permissions.add(Permission.photos);
      permissions.add(Permission.videos);
      permissions.add(Permission.audio);
    }

    if (!kIsWeb && Platform.isIOS) {
      permissions.add(Permission.photos);
    }

    if (permissions.isEmpty) {
      return {};
    }

    final results = await permissions.request();

    results.forEach((perm, status) {
      debugPrint('Permission $perm : $status');
    });

    return results;
  }

  // Vérifier permissions
  static Future<bool> checkAllPermissions() async {
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        final storage = await Permission.storage.status;

        final manageStorage = await Permission.manageExternalStorage.status;

        return storage.isGranted || manageStorage.isGranted;
      }

      if (Platform.isIOS) {
        final photos = await Permission.photos.status;

        return photos.isGranted;
      }

      return true;
    } catch (e) {
      debugPrint('Erreur check permissions: $e');

      return false;
    }
  }

  // Afficher état permissions
  static Future<void> logPermissionsStatus() async {
    if (kIsWeb) {
      debugPrint('Web: pas de permissions système');

      return;
    }

    debugPrint('=== Permissions ===');

    if (Platform.isAndroid) {
      debugPrint('Storage: ${await Permission.storage.status}');

      debugPrint(
        'ManageStorage: ${await Permission.manageExternalStorage.status}',
      );

      debugPrint('Photos: ${await Permission.photos.status}');

      debugPrint('Videos: ${await Permission.videos.status}');

      debugPrint('Audio: ${await Permission.audio.status}');
    }

    if (Platform.isIOS) {
      debugPrint('Photos: ${await Permission.photos.status}');
    }

    debugPrint('===================');
  }
}
