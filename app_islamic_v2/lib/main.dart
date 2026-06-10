import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'core/notifications/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  await container.read(notificationSchedulerProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PlaceholderScreen(titleKey: 'appTitle'),
    ),
    GoRoute(
      path: '/salat',
      builder: (context, state) => const PlaceholderScreen(titleKey: 'salat'),
    ),
    GoRoute(
      path: '/quran',
      builder: (context, state) => const PlaceholderScreen(titleKey: 'quran'),
    ),
    GoRoute(
      path: '/mentor',
      builder: (context, state) => const PlaceholderScreen(titleKey: 'mentor'),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const PlaceholderScreen(titleKey: 'stats'),
    ),
    GoRoute(
      path: '/journey',
      builder: (context, state) => const PlaceholderScreen(titleKey: 'journey'),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'App Islamic V2',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green[800],
        colorScheme: ColorScheme.dark(
          primary: Colors.green[800]!,
          secondary: Colors.amber,
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String titleKey;
  const PlaceholderScreen({super.key, required this.titleKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.appTitle ?? 'Fallback')),
      body: Center(child: Text(AppLocalizations.of(context)?.greeting ?? 'Fallback')),
    );
  }
}
