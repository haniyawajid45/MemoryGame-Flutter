//widgets/result_dialog.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../providers/game_provider.dart';

// Define the color palette from the splash screen for consistency
const _primaryColor = Color(0xFF64B5F6); // Light blue
const _secondaryColor = Color(0xFF81C784); // Soft green
const _tertiaryColor = Color(0xFF9FA8DA); // Soft indigo
const _surfaceColor = Color(0xFF1A1A2E); // Rich dark blue
const _onSurfaceColor = Color(0xFFE3F2FD); // Light blueish white
const _warningColor = Color(0xFFCE93D8); // Soft purple for loss/warning

Future<void> showGameResultDialog(
  BuildContext context,
  GameResult result, {
  required VoidCallback onPlayAgain,
  required VoidCallback onHome,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ResultDialog(
      result: result,
      onPlayAgain: onPlayAgain,
      onHome: onHome,
    ),
  );
}

class _ResultDialog extends StatefulWidget {
  final GameResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const _ResultDialog({
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  State<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _contentController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    // Staggered animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;
    final isTablet = screenSize.width > 600 && screenSize.width <= 800;
    final isLandscape = screenSize.width > screenSize.height;

    // Calculate responsive dimensions
    double dialogWidth;
    double dialogMaxHeight;
    EdgeInsets margin;

    if (isDesktop) {
      dialogWidth = 500;
      dialogMaxHeight = screenSize.height * 0.8;
      margin = const EdgeInsets.all(40);
    } else if (isTablet) {
      dialogWidth = screenSize.width * 0.7;
      dialogMaxHeight = screenSize.height * 0.85;
      margin = const EdgeInsets.all(30);
    } else {
      dialogWidth = screenSize.width;
      dialogMaxHeight = screenSize.height * (isLandscape ? 0.9 : 0.85);
      margin = EdgeInsets.symmetric(
        horizontal: isLandscape ? 40 : 20,
        vertical: isLandscape ? 10 : 20,
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
                maxHeight: dialogMaxHeight,
              ),
              child: Container(
                margin: margin,
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ResultHeader(
                        result: widget.result,
                        contentAnimation: _contentAnimation,
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ResultContent(
                                result: widget.result,
                                contentAnimation: _contentAnimation,
                                isCompact: !isDesktop && isLandscape,
                              ),
                              _ResultActions(
                                onPlayAgain: widget.onPlayAgain,
                                onHome: widget.onHome,
                                contentAnimation: _contentAnimation,
                                isCompact: !isDesktop && isLandscape,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final GameResult result;
  final Animation<double> contentAnimation;

  const _ResultHeader({
    required this.result,
    required this.contentAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isWin = result.isWin;

    return AnimatedBuilder(
      animation: contentAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: contentAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - contentAnimation.value) * -20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isWin
                      ? [_secondaryColor, _secondaryColor.withOpacity(0.7)]
                      : [_warningColor, _warningColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Transform.rotate(
                          angle: value * (math.pi * 2),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _onSurfaceColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _onSurfaceColor.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isWin
                                  ? Icons.emoji_events_rounded
                                  : Icons.flag_rounded,
                              size: 48,
                              color: _onSurfaceColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isWin ? 'Congratulations!' : 'Game Over',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _onSurfaceColor,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isWin
                        ? 'You completed the memory game!'
                        : 'Better luck next time!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _onSurfaceColor.withOpacity(0.9),
                        ),
                    textAlign: TextAlign.center,
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

class _ResultContent extends StatelessWidget {
  final GameResult result;
  final Animation<double> contentAnimation;
  final bool isCompact;

  const _ResultContent({
    required this.result,
    required this.contentAnimation,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
        : const EdgeInsets.all(32);

    return AnimatedBuilder(
      animation: contentAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: contentAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - contentAnimation.value) * 30),
            child: Padding(
              padding: padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Game Statistics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _onSurfaceColor,
                        ),
                  ),
                  SizedBox(height: isCompact ? 16 : 24),
                  if (isCompact) ...[
                    // Compact layout for landscape mobile
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.star_rounded,
                            label: 'Score',
                            value: '${result.score}',
                            color: _tertiaryColor,
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.touch_app_rounded,
                            label: 'Moves',
                            value: '${result.movesUsed}',
                            color: _primaryColor,
                            isCompact: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.schedule_rounded,
                      label: 'Time Elapsed',
                      value: '${result.secondsElapsed}s',
                      color: _secondaryColor,
                      isCompact: true,
                    ),
                  ] else ...[
                    // Standard vertical layout
                    _StatCard(
                      icon: Icons.star_rounded,
                      label: 'Final Score',
                      value: '${result.score}',
                      color: _tertiaryColor,
                    ),
                    const SizedBox(height: 16),
                    _StatCard(
                      icon: Icons.touch_app_rounded,
                      label: 'Moves Used',
                      value: '${result.movesUsed}',
                      color: _primaryColor,
                    ),
                    const SizedBox(height: 16),
                    _StatCard(
                      icon: Icons.schedule_rounded,
                      label: 'Time Elapsed',
                      value: '${result.secondsElapsed}s',
                      color: _secondaryColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isCompact;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, (1 - animValue) * 20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: isCompact
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          value,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          label,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _onSurfaceColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            label,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceColor,
                                ),
                          ),
                        ),
                        Text(
                          value,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
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

class _ResultActions extends StatelessWidget {
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;
  final Animation<double> contentAnimation;
  final bool isCompact;

  const _ResultActions({
    required this.onPlayAgain,
    required this.onHome,
    required this.contentAnimation,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = isCompact
        ? const EdgeInsets.fromLTRB(24, 8, 24, 24)
        : const EdgeInsets.all(24);

    return AnimatedBuilder(
      animation: contentAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: contentAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - contentAnimation.value) * 40),
            child: Padding(
              padding: padding,
              child: isCompact
                  ? Row(
                      children: [
                        Expanded(
                          child: _PlayAgainButton(onPressed: onPlayAgain),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HomeButton(onPressed: onHome),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PlayAgainButton(
                          onPressed: onPlayAgain,
                          fullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        _HomeButton(
                          onPressed: onHome,
                          fullWidth: true,
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

class _PlayAgainButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool fullWidth;

  const _PlayAgainButton({
    required this.onPressed,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_secondaryColor, _primaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, color: _onSurfaceColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Play Again',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _onSurfaceColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool fullWidth;

  const _HomeButton({
    required this.onPressed,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.home_rounded),
        label: Text(
          'Back to Home',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _primaryColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
