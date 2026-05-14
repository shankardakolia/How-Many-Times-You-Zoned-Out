import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/zone_out_provider.dart';
import 'providers/stats_provider.dart';
import 'routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZoneOutApp());
}

class ZoneOutApp extends StatelessWidget {
  const ZoneOutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ZoneOutProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: MaterialApp.router(
        title: 'How Many Times You Zoned Out',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            primary: const Color(0xFF1E3A8A),
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1E3A8A),
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
    );
  }
}
