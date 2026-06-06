import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transfer_model.dart';
import '../models/file_model.dart';
import '../../core/constants/app_constants.dart';

class TransferRepository {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, AppConstants.databaseName);

    return await openDatabase(
      databasePath,
      version: AppConstants.databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transfers(
            id TEXT PRIMARY KEY,
            file_id TEXT,
            target_device_id TEXT,
            target_device_name TEXT,
            target_ip TEXT,
            direction TEXT,
            status TEXT,
            transferred_bytes INTEGER,
            total_bytes INTEGER,
            current_speed REAL,
            start_time TEXT,
            end_time TEXT,
            retry_count INTEGER,
            error_message TEXT,
            FOREIGN KEY(file_id) REFERENCES files(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE files(
            id TEXT PRIMARY KEY,
            name TEXT,
            path TEXT,
            size INTEGER,
            type TEXT,
            checksum TEXT,
            created_at TEXT,
            modified_at TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveTransfer(TransferModel transfer) async {
    final db = await database;
    await db.insert(
      'transfers',
      transfer.toJsonDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransferModel>> getAllTransfers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transfers');

    return Future.wait(
      maps.map((map) async {
        final file = await getFile(map['file_id']);
        return TransferModel.fromJsonDb(map, file);
      }).toList(),
    );
  }

  Future<List<TransferModel>> getTransfersByStatus(
    TransferStatusModel status,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transfers',
      where: 'status = ?',
      whereArgs: [status.name],
    );

    return Future.wait(
      maps.map((map) async {
        final file = await getFile(map['file_id']);
        return TransferModel.fromJsonDb(map, file);
      }).toList(),
    );
  }

  Future<void> updateTransfer(TransferModel transfer) async {
    final db = await database;
    await db.update(
      'transfers',
      transfer.toJsonDb(),
      where: 'id = ?',
      whereArgs: [transfer.id],
    );
  }

  Future<void> deleteTransfer(String id) async {
    final db = await database;
    await db.delete('transfers', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('transfers');
    await db.delete('files');
  }

  Future<void> saveFile(FileModel file) async {
    final db = await database;
    await db.insert(
      'files',
      file.toJsonDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<FileModel> getFile(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'files',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return FileModel.fromJsonDb(maps.first);
    }
    throw Exception('Fichier non trouvé');
  }

  Future<int> getTotalTransferredSize() async {
    final transfers = await getAllTransfers();
    return transfers
        .where((t) => t.status == TransferStatusModel.completed)
        .fold<int>(0, (sum, t) => sum + t.totalBytes);
  }

  Future<Map<String, int>> getStatistics() async {
    final transfers = await getAllTransfers();

    return {
      'total': transfers.length,
      'completed': transfers
          .where((t) => t.status == TransferStatusModel.completed)
          .length,
      'failed': transfers
          .where((t) => t.status == TransferStatusModel.failed)
          .length,
      'cancelled': transfers
          .where((t) => t.status == TransferStatusModel.cancelled)
          .length,
    };
  }
}
