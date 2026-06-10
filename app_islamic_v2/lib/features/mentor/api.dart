import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mentor_service.dart';
import 'mentor_notifier.dart';

final mentorServiceProvider = Provider((ref) => MentorService());

final chatProvider = StateNotifierProvider<MentorNotifier, ChatState>((ref) {
  return MentorNotifier(ref.watch(mentorServiceProvider), ref);
});
