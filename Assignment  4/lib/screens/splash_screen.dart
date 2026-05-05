import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _btnController;
  late Animation<double> _iconScale;
  late Animation<double> _iconFloat;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _btnFade;
  late Animation<Offset> _btnSlide;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _iconScale = CurvedAnimation(parent: _iconController, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _iconFloat = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
      ..repeat(reverse: true)
      ..drive(Tween(begin: -6.0, end: 6.0));

    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _textSlide = CurvedAnimation(parent: _textController, curve: Curves.easeOut)
        .drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero));

    _btnFade = CurvedAnimation(parent: _btnController, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _btnSlide = CurvedAnimation(parent: _btnController, curve: Curves.easeOut)
        .drive(Tween(begin: const Offset(0, 0.4), end: Offset.zero));

    Future.delayed(const Duration(milliseconds: 300), () {
      _iconController.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      _btnController.forward();
    });

    AnimationController floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _iconFloat = floatController.drive(Tween(begin: -8.0, end: 8.0));
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          children: [
            // Landscape background
            Positioned.fill(child: _buildLandscape()),
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Animated weather icon
                    ScaleTransition(
                      scale: _iconScale,
                      child: AnimatedBuilder(
                        animation: _iconFloat,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _iconFloat.value),
                            child: child,
                          );
                        },
                        child: const Text('⛅', style: TextStyle(fontSize: 90)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Title & subtitle
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textFade,
                        child: Column(
                          children: [
                            const Text(
                              'Weather App',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Get real-time weather information\nfor any city.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(flex: 3),
                    // Get Started button
                    SlideTransition(
                      position: _btnSlide,
                      child: FadeTransition(
                        opacity: _btnFade,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          margin: const EdgeInsets.only(bottom: 36),
                          decoration: BoxDecoration(
                            gradient: AppTheme.buttonGradient,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, a, b) => const HomeScreen(),
                                  transitionsBuilder: (_, a, b, child) =>
                                      FadeTransition(opacity: a, child: child),
                                  transitionDuration:
                                      const Duration(milliseconds: 600),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscape() {
    return CustomPaint(
      painter: LandscapePainter(),
    );
  }
}

class LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky glow (sunrise)
    final skyGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.6),
        radius: 0.6,
        colors: [
          const Color(0xFFFF8C42).withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyGlow);

    // Sun
    final sunPaint = Paint()
      ..color = const Color(0xFFFFC107).withOpacity(0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(Offset(w * 0.5, h * 0.68), 28, sunPaint);
    sunPaint.maskFilter = null;
    sunPaint.color = const Color(0xFFFFE082);
    canvas.drawCircle(Offset(w * 0.5, h * 0.68), 14, sunPaint);

    // Mountain back
    final mtBack = Paint()..color = const Color(0xFF1A2070).withOpacity(0.6);
    final pathBack = Path()
      ..moveTo(0, h * 0.75)
      ..lineTo(w * 0.2, h * 0.52)
      ..lineTo(w * 0.35, h * 0.65)
      ..lineTo(w * 0.5, h * 0.48)
      ..lineTo(w * 0.65, h * 0.62)
      ..lineTo(w * 0.8, h * 0.5)
      ..lineTo(w, h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(pathBack, mtBack);

    // Mountain front
    final mtFront = Paint()..color = const Color(0xFF111660).withOpacity(0.8);
    final pathFront = Path()
      ..moveTo(0, h * 0.82)
      ..lineTo(w * 0.15, h * 0.68)
      ..lineTo(w * 0.28, h * 0.76)
      ..lineTo(w * 0.42, h * 0.62)
      ..lineTo(w * 0.55, h * 0.72)
      ..lineTo(w * 0.68, h * 0.66)
      ..lineTo(w * 0.82, h * 0.75)
      ..lineTo(w, h * 0.72)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(pathFront, mtFront);

    // Trees
    _drawTree(canvas, Offset(w * 0.08, h * 0.85), 22, h * 0.1);
    _drawTree(canvas, Offset(w * 0.16, h * 0.87), 18, h * 0.085);
    _drawTree(canvas, Offset(w * 0.85, h * 0.85), 20, h * 0.095);
    _drawTree(canvas, Offset(w * 0.92, h * 0.87), 16, h * 0.08);
    _drawTree(canvas, Offset(w * 0.78, h * 0.88), 14, h * 0.07);

    // Road
    final road = Paint()..color = const Color(0xFF0D1257).withOpacity(0.7);
    final roadPath = Path()
      ..moveTo(w * 0.42, h)
      ..lineTo(w * 0.46, h * 0.78)
      ..lineTo(w * 0.54, h * 0.78)
      ..lineTo(w * 0.58, h)
      ..close();
    canvas.drawPath(roadPath, road);
  }

  void _drawTree(Canvas canvas, Offset base, double width, double height) {
    final paint = Paint()..color = const Color(0xFF0D1257).withOpacity(0.9);
    // Trunk
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(base.dx, base.dy + height * 0.1),
            width: width * 0.15,
            height: height * 0.25),
        paint);
    // Triangle foliage
    for (int i = 0; i < 3; i++) {
      final triPath = Path()
        ..moveTo(base.dx, base.dy - height * (0.4 + i * 0.2))
        ..lineTo(base.dx - width * (0.5 - i * 0.1),
            base.dy - height * (0.1 + i * 0.2))
        ..lineTo(base.dx + width * (0.5 - i * 0.1),
            base.dy - height * (0.1 + i * 0.2))
        ..close();
      canvas.drawPath(triPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
