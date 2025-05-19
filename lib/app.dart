import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';

class ClassClashApp extends StatelessWidget {
  const ClassClashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Class Clash',
      theme: appTheme,
      routerConfig: router,
    );
  }
}
