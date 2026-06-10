sed -i "s/import '..\/..\/core\/config\/app_config.dart';/import 'package:app_islamic_v2\/core\/config\/app_config.dart';/g" app_islamic_v2/lib/features/quran/ui/quran_screen.dart
sed -i "s/Sqflite.firstIntValue/Sqflite.firstIntValue/g" app_islamic_v2/lib/features/murajaah/srs_dao.dart
sed -i "s/state = state.copyWith(playing: false);/state = PlayerState(state.playing, state.processingState); \/\/ copyWith not defined/g" app_islamic_v2/lib/features/quran/quran_notifier.dart
sed -i "s/import 'package:sqflite\/sqflite.dart';/import 'package:sqflite\/sqflite.dart';/g" app_islamic_v2/lib/features/murajaah/srs_dao.dart
