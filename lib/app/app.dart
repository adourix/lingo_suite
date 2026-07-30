import 'package:flutter/material.dart';

import '../core/widgets/app_shell.dart';
import 'theme/app_theme.dart';

class LingoSuiteApp extends StatelessWidget {
  const LingoSuiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Lingo Store',
  theme: AppTheme.light,
  home: const AppShell(),
);
  }
}