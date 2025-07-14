import 'package:flutter/material.dart';
import 'package:peer42/src/core/utils/app_navigator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/oauth2_service.dart';

class OAuth2LoginPage extends StatefulWidget {
  const OAuth2LoginPage({super.key});

  @override
  State<OAuth2LoginPage> createState() => _OAuth2LoginPageState();
}

class _OAuth2LoginPageState extends State<OAuth2LoginPage>
    with TickerProviderStateMixin {
  final OAuth2Service _oauth2Service = OAuth2Service();
  bool _isLoading = false;
  late AnimationController _backgroundController;
  late AnimationController _buttonController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _listenForCallback();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  void _onLoginSuccess() {
    // Login başarılı olduğunda ana navigation sayfasına git
    Navigator.pushReplacementNamed(context, '/home'); // MainNavigationPage açılır
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _listenForCallback() {
    _oauth2Service.callbackStream.listen((uri) async {
      if (uri.scheme == 'peer42' &&
          uri.host == 'oauth' &&
          uri.path == '/callback') {
        await _handleCallback(uri);
      }
    });
  }

  Future<void> _handleCallback(Uri uri) async {
    setState(() => _isLoading = true);

    try {
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        throw Exception('OAuth2 Error: $error');
      }

      if (code == null || state == null) {
        throw Exception('Invalid callback parameters');
      }

      await _oauth2Service.exchangeCodeForToken(
        code: code,
      );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Login failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _startOAuth2Flow() async {
    if (!_oauth2Service.hasCredentials()) {
      _showErrorDialog('OAuth2 credentials not configured');
      return;
    }

    setState(() => _isLoading = true);
    _buttonController.forward().then((_) => _buttonController.reverse());

    try {
      final authUrl = _oauth2Service.buildAuthorizationUrl();
      final uri = Uri.parse(authUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch OAuth2 URL');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to start login: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.safeNavigateBack(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF00d4ff)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFF0a0a0a), const Color(0xFF1a0a2e),
                      _backgroundAnimation.value)!,
                  Color.lerp(const Color(0xFF16213e), const Color(0xFF0f3460),
                      _backgroundAnimation.value)!,
                  Color.lerp(const Color(0xFF0f3460), const Color(0xFF16213e),
                      _backgroundAnimation.value)!,
                  Color.lerp(const Color(0xFF1a0a2e), const Color(0xFF0a0a0a),
                      _backgroundAnimation.value)!,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and Title Section
                      _buildLogoSection(),
                      const SizedBox(height: 60),
                      
                      // Login Card
                      _buildLoginCard(),
                      
                      const SizedBox(height: 40),
                      
                      // Footer
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00d4ff),
                Color(0xFF7209b7),
                Color(0xFFff006e),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00d4ff).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00d4ff), Color(0xFF7209b7)],
          ).createShader(bounds),
          child: const Text(
            'Peer42',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connect to your 42 journey',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in with your 42 account to continue',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Login Button
          AnimatedBuilder(
            animation: _buttonAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _buttonAnimation.value,
                child: _isLoading
                    ? _buildLoadingButton()
                    : _buildLoginButton(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController.reverse(),
      onTap: _startOAuth2Flow,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00d4ff),
              Color(0xFF7209b7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00d4ff).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Sign in with 42',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00d4ff).withOpacity(0.6),
            const Color(0xFF7209b7).withOpacity(0.6),
          ],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          height: 1,
          width: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Secure OAuth2 Authentication',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}