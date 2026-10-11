import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'app_info.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class YumlyApp extends StatefulWidget {
  const YumlyApp({super.key});

  @override
  State<YumlyApp> createState() => _YumlyAppState();
}

class _YumlyAppState extends State<YumlyApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
      // Interface uniquement en français pour la première version.
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
