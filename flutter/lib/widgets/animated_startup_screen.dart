import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedStartupScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const AnimatedStartupScreen({
    super.key,
    required this.onInitializationComplete,
  });

  @override
  State<AnimatedStartupScreen> createState() => _AnimatedStartupScreenState();
}

class _AnimatedStartupScreenState extends State<AnimatedStartupScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;

  late Animation<double> _gradientAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Gradient animation controller
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create animations
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start fade in
    _fadeController.forward();

    // Start scale animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();

    // Start gradient animation
    await Future.delayed(const Duration(milliseconds: 500));
    _gradientController.repeat(reverse: true);

    // Complete initialization after animations
    await Future.delayed(const Duration(seconds: 3));
    widget.onInitializationComplete();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _gradientAnimation,
          _scaleAnimation,
          _fadeAnimation,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  const Color(0xFF1A6DFF).withOpacity(0.3),
                  const Color(0xFF6DC7FF).withOpacity(0.2),
                  const Color(0xFF0A0A0A),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Icon with glow effect
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6DC7FF).withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icons/icon.png',
                          width: 120,
                          height: 120,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Animated gradient text
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(
                                const Color(0xFF6DC7FF),
                                const Color(0xFFE6ABFF),
                                _gradientAnimation.value,
                              )!,
                              Color.lerp(
                                const Color(0xFF1A6DFF),
                                const Color(0xFFC822FF),
                                _gradientAnimation.value,
                              )!,
                              Color.lerp(
                                const Color(0xFFC822FF),
                                const Color(0xFF6DC7FF),
                                _gradientAnimation.value,
                              )!,
                            ],
                            stops: [
                              0.0,
                              0.5 +
                                  (math.sin(_gradientAnimation.value *
                                          2 *
                                          math.pi) *
                                      0.2),
                              1.0,
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'Packaroo',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subtitle with gradient
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              const Color(0xFF6DC7FF).withOpacity(0.8),
                              const Color(0xFFE6ABFF).withOpacity(0.8),
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'Java Package Builder',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Loading indicator
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.lerp(
                              const Color(0xFF6DC7FF),
                              const Color(0xFFC822FF),
                              _gradientAnimation.value,
                            )!,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Initializing...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
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
}
