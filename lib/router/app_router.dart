import 'package:go_router/go_router.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/login/login_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/error/not_found_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const search = '/search';
  static const profile = '/profile';
}

GoRouter buildRouter(AuthProvider authProvider) => GoRouter(
      refreshListenable: authProvider,
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        final uri = state.uri;
        final loc = state.matchedLocation;

        // OAuth callback deep links are handled by AppLinks, not by the router.
        // We redirect them to the login screen so they don't hit a 404, while
        // AuthRepository processes the auth code in the background.
        if (uri.scheme == 'peer42' || loc.contains('oauth')) {
          return AppRoutes.login;
        }

        return switch (authProvider.state) {
          AuthState.unknown => loc == AppRoutes.splash ? null : AppRoutes.splash,
          AuthState.unauthenticated ||
          AuthState.error =>
            loc == AppRoutes.login ? null : AppRoutes.login,
          AuthState.loading => null,
          AuthState.authenticated =>
            (loc == AppRoutes.splash || loc == AppRoutes.login)
                ? AppRoutes.search
                : null,
        };
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, _) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.search,
          builder: (_, _) => const SearchScreen(),
        ),
        GoRoute(
          path: '${AppRoutes.profile}/:login',
          builder: (_, state) => ProfileScreen(
            login: state.pathParameters['login']!,
          ),
        ),
      ],
      errorBuilder: (context, state) => NotFoundScreen(error: state.error),
    );
