import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/history/history_screen.dart';
import '../../features/leads/leads_screen.dart';
import '../../features/leads/lead_details_screen.dart';
import '../../features/analytics/call_analytics_screen.dart';
import '../../features/campaigns/campaigns_screen.dart';
import '../../features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/lead/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LeadDetailsScreen(leadId: id);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/leads',
            builder: (context, state) => const LeadsScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const CallAnalyticsScreen(),
          ),
          GoRoute(
            path: '/campaigns',
            builder: (context, state) => const CampaignsScreen(),
          ),
          GoRoute(
            path: '/more',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final loggingIn = state.matchedLocation == '/login';
      final splashing = state.matchedLocation == '/splash';

      print('Router: Redirecting... Current path: ${state.matchedLocation}, Status: ${authState.status}');

      if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) {
        return splashing ? null : '/splash';
      }

      final loggedIn = authState.status == AuthStatus.authenticated;

      if (!loggedIn) {
        print('Router: Not logged in, redirecting to /login (if not already there)');
        return loggingIn ? null : '/login';
      }

      if (loggedIn) {
        print('Router: Logged in, redirecting to /history (if on splash or login)');
        return (loggingIn || splashing) ? '/history' : null;
      }

      return null;
    },
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      print('RouterNotifier: Auth state changed from ${previous?.status} to ${next.status}');
      notifyListeners();
    });
  }
}

final routerNotifierProvider = ChangeNotifierProvider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});
