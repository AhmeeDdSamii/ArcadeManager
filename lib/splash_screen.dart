import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const SplashScreen({super.key, this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _progressAnimation.addListener(() {
      setState(() {
        _progress = _progressAnimation.value;
      });
    });

    _progressController.forward().then((_) {
      if (mounted && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E), // Charcoal
              Color(0xFF16213E), // Dark purple
              Color(0xFF0F0F23), // Darker purple
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isSmallScreen = screenHeight < 600;
            final isVerySmallScreen = screenHeight < 400;
            
            // Responsive sizes
            final logoSize = isVerySmallScreen ? 60.0 : (isSmallScreen ? 80.0 : 120.0);
            final titleFontSize = isVerySmallScreen ? 20.0 : (isSmallScreen ? 26.0 : 32.0);
            final subtitleFontSize = isVerySmallScreen ? 12.0 : (isSmallScreen ? 15.0 : 18.0);
            final verticalSpacing = isVerySmallScreen ? 15.0 : (isSmallScreen ? 25.0 : 40.0);
            final bottomSpacing = isVerySmallScreen ? 30.0 : 50.0;
            
            return Stack(
              children: [
                // Background circuit board lines
                ..._buildCircuitLines(constraints),

                // Background neon icons
                ..._buildBackgroundIcons(constraints),

                // Main content
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        _buildLogo(logoSize),

                        SizedBox(height: verticalSpacing * 0.75),

                        // Title
                        _buildTitle(titleFontSize),

                        SizedBox(height: verticalSpacing),

                        // Subtitle
                        _buildSubtitle(subtitleFontSize),
                      ],
                    ),
                  ),
                ),

                // Progress indicator at bottom
                Positioned(
                  bottom: bottomSpacing,
                  left: 20,
                  right: 20,
                  child: _buildProgressIndicator(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6C63FF), // Neon purple
            Color(0xFF00D4FF), // Neon cyan
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(Icons.videogame_asset, size: size * 0.5, color: Colors.white),
    );
  }

  Widget _buildTitle(double fontSize) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF6C63FF), // Neon purple
          Color(0xFF00D4FF), // Neon cyan
          Color(0xFFFFD700), // Gold
        ],
      ).createShader(bounds),
      child: Text(
        'PlayControl',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Color(0xFF6C63FF),
              blurRadius: 20,
              offset: Offset(0, 0),
            ),
            Shadow(
              color: Color(0xFF00D4FF),
              blurRadius: 15,
              offset: Offset(0, 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildArrowIcon(Icons.arrow_back_ios, fontSize * 0.9),
        const SizedBox(width: 10),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFFD700), // Gold
              Color(0xFFFFA500), // Orange gold
            ],
          ).createShader(bounds),
          child: Text(
            'ArcadeManager',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Color(0xFFFFD700),
                  blurRadius: 15,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildArrowIcon(Icons.arrow_forward_ios, fontSize * 0.9),
      ],
    );
  }

  Widget _buildArrowIcon(IconData icon, double size) {
    return Icon(
      icon,
      color: const Color(0xFFFFD700),
      size: size,
      shadows: [
        Shadow(
          color: const Color(0xFFFFD700),
          blurRadius: 10,
          offset: const Offset(0, 0),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        const Text(
          'Initializing...',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.white.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6C63FF),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(_progress * 100).toInt()}%',
          style: const TextStyle(
            color: Color(0xFF6C63FF),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCircuitLines(BoxConstraints constraints) {
    final random = math.Random(42);
    final lines = <Widget>[];

    for (int i = 0; i < 8; i++) {
      final x1 = random.nextDouble() * constraints.maxWidth;
      final y1 = random.nextDouble() * constraints.maxHeight;
      final x2 = x1 + (random.nextDouble() - 0.5) * 200;
      final y2 = y1 + (random.nextDouble() - 0.5) * 200;

      lines.add(
        Positioned(
          left: x1,
          top: y1,
          child: CustomPaint(
            size: Size((x2 - x1).abs(), (y2 - y1).abs()),
            painter: CircuitLinePainter(),
          ),
        ),
      );
    }

    return lines;
  }

  List<Widget> _buildBackgroundIcons(BoxConstraints constraints) {
    final icons = [
      Icons.videogame_asset_outlined,
      Icons.diamond_outlined,
      Icons.key_outlined,
      Icons.headphones_outlined,
      Icons.casino_outlined,
    ];

    final random = math.Random(123);
    final bgIcons = <Widget>[];

    for (int i = 0; i < 12; i++) {
      final icon = icons[random.nextInt(icons.length)];
      final x = random.nextDouble() * constraints.maxWidth;
      final y = random.nextDouble() * constraints.maxHeight;
      final size = 20.0 + random.nextDouble() * 20;
      final opacity = 0.1 + random.nextDouble() * 0.2;

      bgIcons.add(
        Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: opacity,
            child: Icon(icon, size: size, color: const Color(0xFF6C63FF)),
          ),
        ),
      );
    }

    return bgIcons;
  }
}

class CircuitLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6C63FF).withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
