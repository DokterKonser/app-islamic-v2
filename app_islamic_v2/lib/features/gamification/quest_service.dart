import 'package:uuid/uuid.dart';
import '../../core/db/db_helper.dart';

class Quest {
  final String id;
  final String title;
  final String type; // 'base' or 'extra' or 'bonus'
  final bool isCompleted;

  Quest({required this.id, required this.title, required this.type, this.isCompleted = false});
  
  Quest copyWith({bool? isCompleted}) {
    return Quest(
      id: id,
      title: title,
      type: type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class QuestService {
  final DbHelper _dbHelper = DbHelper();

  List<Quest> generateDailyQuests(Map<String, dynamic> summary, int energyScore) {
    List<Quest> quests = [
      Quest(id: 'q_salat_5', title: 'Salat 5 Waktu', type: 'base'),
      Quest(id: 'q_quran_1', title: 'Baca Quran 1 Halaman', type: 'base'),
      Quest(id: 'q_dzikir_1', title: 'Dzikir Pagi/Petang', type: 'base'),
    ];

    if (energyScore <= 30) {
      // Low tier - add 2 minimal extra
      quests.add(Quest(id: 'q_doa_1', title: 'Baca 1 Doa Harian', type: 'extra'));
      quests.add(Quest(id: 'q_istighfar_10', title: 'Istighfar 10x', type: 'extra'));
    } else if (energyScore >= 70) {
      // High tier - add 2 bonus quests
      quests.add(Quest(id: 'q_tahajud', title: 'Salat Tahajud', type: 'bonus'));
      quests.add(Quest(id: 'q_puasa', title: 'Puasa Sunnah (jika ada)', type: 'bonus'));
    } else {
      // Normal tier - add 1 normal extra
      quests.add(Quest(id: 'q_rawatib', title: 'Salat Rawatib', type: 'extra'));
    }

    return quests;
  }

  // Placeholder logic for checking
  bool checkQuestCompletion(Quest quest, dynamic state) {
    return false; 
  }

  Future<void> recordQuestComplete(String questKey, String date) async {
    final db = await _dbHelper.database;
    await db.insert('quest_log', {
      'id': const Uuid().v4(),
      'quest_id': questKey,
      'status': 'completed',
      'progress': 100,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
