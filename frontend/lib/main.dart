import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'providers/dashboard_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const IDSApp());
}

class IDSApp extends StatelessWidget {
  const IDSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(),
      child: MaterialApp(
        title: 'Intrusion Detection System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.cardBg,
            error: AppColors.danger,
          ),
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
