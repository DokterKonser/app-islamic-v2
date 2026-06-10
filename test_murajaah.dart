import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_islamic_v2/features/murajaah/srs_dao.dart';
import 'package:app_islamic_v2/core/db/db_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('srs dao logReview runs successfully', () async {
      final srsDao = SrsDao();
      final today = DateTime.now().toUtc().toIso8601String();
      await srsDao.getDueCount(today);
  });
}
