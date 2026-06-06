import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/permissions.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/device_list_screen.dart';
import 'presentation/screens/transfer_screen.dart';
import 'domain/entities/device.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des permissions
  await PermissionHandlerService.initializePermissions();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local File Transfer',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/devices': (context) => const DeviceListScreen(),
        '/transfer': (context) {
          final device = ModalRoute.of(context)!.settings.arguments;
          return TransferScreen(targetDevice: device as Device?);
        },
      },
    );
  }
}
