import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/token_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const Peer42App());
}

class Peer42App extends StatefulWidget {
  const Peer42App({super.key});

  @override
  State<Peer42App> createState() => _Peer42AppState();
}

class _Peer42AppState extends State<Peer42App> {
  late final TokenService _tokenService;
  late final AuthRepository _authRepository;
  late final ApiService _apiService;
  late final UserRepository _userRepository;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _tokenService = TokenService();
    _authRepository = AuthRepository();
    _apiService = ApiService(
      tokenService: _tokenService,
      authRepository: _authRepository,
    );
    _userRepository = UserRepository(apiService: _apiService);
    _authProvider = AuthProvider(
      tokenService: _tokenService,
      authRepository: _authRepository,
    );
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(userRepository: _userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(userRepository: _userRepository),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = buildRouter(
            context.read<AuthProvider>(),
          );
          return MaterialApp.router(
            title: 'Peer42',
            theme: AppTheme.dark,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
