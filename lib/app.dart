import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'core/utils/dialog_utils.dart';

class ClassClashApp extends StatelessWidget {
  const ClassClashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'Class Clash',
        theme: appTheme,
        routerConfig: router,
      ),
    );
  }
}
