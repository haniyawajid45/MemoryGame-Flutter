//screens/splash_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'start_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late AnimationController _breathController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _breathController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
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
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _floatAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _breathAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    ));

    // Start animations with staggered timing
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _rotateController.repeat();
      _glowController.repeat(reverse: true);
      _floatController.repeat(reverse: true);
      _shimmerController.repeat();
      _breathController.repeat(reverse: true);
    });

    // Navigate to start screen
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, StartScreen.routeName);
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _rotateController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.2, 0.4, 0.7, 1.0],
            colors: [
              Color(0xFF0F0F23), // Deep midnight blue
              Color(0xFF1A1A2E), // Rich dark blue
              Color(0xFF16213E), // Navy blue
              Color(0xFF0F3460), // Deep ocean blue
              Color(0xFF533483), // Subtle purple accent
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background overlay with subtle patterns
            _buildBackgroundOverlay(),

            // Subtle floating particles background
            ...List.generate(25, (index) => _FloatingParticle(index: index)),

            // Aurora-like background effect
            _buildAuroraEffect(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo with subtle glow effect
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _scaleAnimation,
                      _rotateAnimation,
                      _glowAnimation,
                      _floatAnimation,
                      _breathAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: Transform.scale(
                          scale: _scaleAnimation.value * _breathAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF64B5F6)
                                      .withOpacity(0.4), // Light blue
                                  const Color(0xFF42A5F5)
                                      .withOpacity(0.3), // Blue
                                  const Color(0xFF1E88E5)
                                      .withOpacity(0.2), // Deeper blue
                                  const Color(0xFF7986CB)
                                      .withOpacity(0.1), // Soft indigo
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF64B5F6).withOpacity(
                                    0.3 * _glowAnimation.value,
                                  ),
                                  blurRadius: 60 * _glowAnimation.value,
                                  spreadRadius: 10 * _glowAnimation.value,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF7986CB).withOpacity(
                                    0.2 * _glowAnimation.value,
                                  ),
                                  blurRadius: 100 * _glowAnimation.value,
                                  spreadRadius: 5 * _glowAnimation.value,
                                ),
                              ],
                            ),
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: const [
                                  Color(0xFF81C784), // Soft green
                                  Color(0xFF64B5F6), // Light blue
                                  Color(0xFF9FA8DA), // Soft indigo
                                  Color(0xFFCE93D8), // Soft purple
                                ],
                                transform: GradientRotation(
                                    _rotateAnimation.value * 2 * math.pi),
                              ).createShader(bounds),
                              child: Icon(
                                Icons.memory,
                                size: screenSize.width > 800 ? 120 : 96,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // Animated Title with shimmer effect
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.4),
                                  Colors.white.withOpacity(0.8),
                                  const Color(0xFF81C784).withOpacity(0.9),
                                  const Color(0xFF64B5F6).withOpacity(0.8),
                                  Colors.white.withOpacity(0.4),
                                ],
                                stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                                transform: GradientRotation(
                                    _shimmerAnimation.value * math.pi),
                              ).createShader(bounds),
                              child: Text(
                                'Memory Game',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 3.0,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF64B5F6)
                                          .withOpacity(0.4),
                                      offset: const Offset(0, 2),
                                      blurRadius: 8,
                                    ),
                                    Shadow(
                                      color: const Color(0xFF81C784)
                                          .withOpacity(0.3),
                                      offset: const Offset(0, 4),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Text(
                              'Challenge Your Mind',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Color.lerp(
                                      const Color(0xFF9E9E9E),
                                      const Color(0xFFE3F2FD),
                                      _glowAnimation.value * 0.8,
                                    ),
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 2.0,
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),

                  // Elegant loading indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _rotateAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFF81C784)
                                    .withOpacity(0.6), // Soft green
                                const Color(0xFF64B5F6)
                                    .withOpacity(0.8), // Light blue
                                const Color(0xFF9FA8DA)
                                    .withOpacity(0.6), // Soft indigo
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                              transform: GradientRotation(
                                _rotateAnimation.value * 2 * math.pi,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Elegant loading text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Text(
                          'Loading...',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Color.lerp(
                                      const Color(0xFF757575),
                                      const Color(0xFFBBDEFB),
                                      _glowAnimation.value * 0.6,
                                    ),
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 3.0,
                                  ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOverlay() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.3, -0.5),
              radius: 1.2,
              colors: [
                const Color(0xFF1E88E5).withOpacity(0.1 * _glowAnimation.value),
                const Color(0xFF7986CB)
                    .withOpacity(0.05 * _glowAnimation.value),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuroraEffect() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Positioned(
          top: -100 + _floatAnimation.value * 2,
          left: -50,
          right: -50,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF81C784).withOpacity(0.1),
                  const Color(0xFF64B5F6).withOpacity(0.08),
                  const Color(0xFF9FA8DA).withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingParticle extends StatefulWidget {
  final int index;

  const _FloatingParticle({required this.index});

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _opacityAnimation;
  late double _size;
  late Color _color;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 4000 + (widget.index * 150)),
      vsync: this,
    );

    _size = 1.5 + (widget.index % 4) * 0.8;

    final colors = [
      const Color(0xFF81C784).withOpacity(0.3), // Soft green
      const Color(0xFF64B5F6).withOpacity(0.25), // Light blue
      const Color(0xFF9FA8DA).withOpacity(0.2), // Soft indigo
      const Color(0xFFCE93D8).withOpacity(0.15), // Soft purple
      const Color(0xFFFFB74D).withOpacity(0.1), // Soft orange
    ];
    _color = colors[widget.index % colors.length];

    _animation = Tween<Offset>(
      begin: Offset(
        (widget.index % 7) * 0.15 - 0.5,
        1.3,
      ),
      end: Offset(
        (widget.index % 7) * 0.15 - 0.5 + (widget.index.isEven ? 0.1 : -0.1),
        -0.3,
      ),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));

    Future.delayed(Duration(milliseconds: widget.index * 200), () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: screenSize.width * _animation.value.dx + screenSize.width / 2,
          top: screenSize.height * _animation.value.dy,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _color,
                boxShadow: [
                  BoxShadow(
                    color: _color.withOpacity(0.5),
                    blurRadius: 3,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
