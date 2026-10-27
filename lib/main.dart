import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  await AppConfig.initialize();

  runApp(
    const ProviderScope(
      child: VisitorManagementApp(),
    ),
  );
}
