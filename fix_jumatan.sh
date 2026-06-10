cat << 'INNER_EOF' > app_islamic_v2/lib/features/jumatan/ui/jumatan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api.dart';

class JumatanScreen extends ConsumerStatefulWidget {
  const JumatanScreen({super.key});

  @override
  ConsumerState<JumatanScreen> createState() => _JumatanScreenState();
}

class _JumatanScreenState extends ConsumerState<JumatanScreen> {
  final Map<String, bool> _checklist = {
    'Mandi Sunnah': false,
    'Potong Kuku': false,
    'Memakai Wangi-wangian': false,
    'Membaca Al-Kahfi': false,
    'Datang Awal ke Masjid': false,
    'Doa Keluar Rumah': false,
    'Doa Masuk Masjid': false,
  };

  bool get _allChecked => _checklist.values.every((v) => v);

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(jumatanStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jumatan'),
        actions: [
          statusAsync.when(
            data: (status) => IconButton(
              icon: Icon(status.remindersEnabled ? Icons.notifications_active : Icons.notifications_off),
              onPressed: () {
                ref.read(jumatanStatusProvider.notifier).toggleReminders(!status.remindersEnabled);
              },
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          )
        ],
      ),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: \$err')),
        data: (status) {
          final isFriday = DateTime.now().weekday == DateTime.friday;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: _checklist.keys.map((key) {
                    return CheckboxListTile(
                      title: Text(key),
                      value: _checklist[key],
                      onChanged: (val) {
                        setState(() {
                          _checklist[key] = val ?? false;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: (!isFriday || status.isCompletedThisWeek || !_allChecked)
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await ref.read(jumatanStatusProvider.notifier).confirmJumatan();
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Jumatan Selesai!')),
                            );
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                  child: const Text('Jumat Hadir ✓'),
                ),
              ),
              if (!isFriday)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text('Hanya dapat dikonfirmasi pada hari Jumat', style: TextStyle(color: Colors.grey)),
                )
            ],
          );
        },
      ),
    );
  }
}
INNER_EOF
