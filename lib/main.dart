import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'features/server_sync/data/config_repository.dart';
import 'features/server_sync/presentation/cubit/server_cubit.dart';
import 'features/speed_test/data/speed_test_service.dart';
import 'features/speed_test/presentation/cubit/speed_test_cubit.dart';
import 'features/vpn/data/wireguard_repository.dart';
import 'features/vpn/presentation/cubit/vpn_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF13151B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const VpnGuardApp());
}

class VpnGuardApp extends StatelessWidget {
  const VpnGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => ConfigRepository()),
        RepositoryProvider(create: (_) => WireGuardRepository()),
        RepositoryProvider(create: (_) => SpeedTestService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(
            create: (context) => ServerCubit(
              configRepository: context.read<ConfigRepository>(),
            )..loadServers(),
          ),
          BlocProvider(
            create: (context) => VpnCubit(
              vpnRepository: context.read<WireGuardRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => SpeedTestCubit(
              speedTestService: context.read<SpeedTestService>(),
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'VPN Guard',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const MainNavigationScreen(),
            );
          },
        ),
      ),
    );
  }
}
