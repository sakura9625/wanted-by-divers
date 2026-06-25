import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/main_scaffold.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wanted by Divers',
      theme: AppTheme.darkTheme,
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}
