import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/tracker_screen.dart';
import '../screens/stats_screen.dart';
import '../widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/tracker',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/tracker',
          name: 'tracker',
          builder: (context, state) => const TrackerScreen(),
        ),
        GoRoute(
          path: '/stats',
          name: 'stats',
          builder: (context, state) => const StatsScreen(),
        ),
      ],
    ),
  ],
);
