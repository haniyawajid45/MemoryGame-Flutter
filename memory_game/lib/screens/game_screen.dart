import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../models/tile.dart';
import '../widgets/result_dialog.dart';
import 'start_screen.dart'; // Import for robust navigation

// Define the color palette from the splash screen for consistency
const _primaryColor = Color(0xFF64B5F6); // Light blue
const _secondaryColor = Color(0xFF81C784); // Soft green
const _tertiaryColor = Color(0xFF9FA8DA); // Soft indigo
const _surfaceColor = Color(0xFF1A1A2E); // Rich dark blue
const _onSurfaceColor = Color(0xFFE3F2FD); // Light blueish white
const _outlineColor = Color(0xFF9E9E9E); // Soft gray for borders
const _warningColor =
    Color(0xFFCE93D8); // Soft purple for warnings (e.g., low time)
const _hintColor = Color(0xFFFFC107); // Amber for hints

class GameScreen extends StatefulWidget {
  static const routeName = '/game';
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameResult? _lastShownResult;
  bool _isDialogShowing = false;

  void _showResultDialog(GameResult result, GameSettings settings) {
    // Prevent duplicate dialogs
    if (_isDialogShowing || _lastShownResult == result) return;

    _isDialogShowing = true;
    _lastShownResult = result;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showGameResultDialog(
          context,
          result,
          onPlayAgain: () {
            context.read<GameProvider>().startGame(settings);
            Navigator.of(context).pop();
            _isDialogShowing = false;
            _lastShownResult = null;
          },
          onHome: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              StartScreen.routeName,
              (route) => false,
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gp, child) {
        final settings = gp.settings;
        final screenSize = MediaQuery.of(context).size;
        final isDesktop = screenSize.width > 800;

        // Handle automatic game end (timer or moves exhausted)
        if (gp.finalResult != null && !_isDialogShowing) {
          _showResultDialog(gp.finalResult!, settings);
        }

        return Scaffold(
          body: Container(
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
            child: SafeArea(
              child: Column(
                children: [
                  _GameHeader(isDesktop: isDesktop),
                  _GameStatusBar(isDesktop: isDesktop),
                  Expanded(
                    child: _GameBoard(
                      settings: settings,
                      isDesktop: isDesktop,
                      onShowResult: _showResultDialog,
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

class _GameHeader extends StatelessWidget {
  final bool isDesktop;
  const _GameHeader({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 20,
        vertical: 16,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.memory,
              color: _onSurfaceColor,
              size: isDesktop ? 32 : 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Memory Game',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _onSurfaceColor,
                      ),
                ),
                Text(
                  '${gp.settings.gridCrossAxisCount}×${gp.settings.gridCrossAxisCount} Grid',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _onSurfaceColor.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
          _ActionButton(
            icon: Icons.lightbulb_outline_rounded,
            onPressed: gp.hintsRemaining > 0 ? () => gp.useHint() : null,
            tooltip: 'Hint (${gp.hintsRemaining} left)',
            color: _hintColor,
            isDisabled: gp.hintsRemaining <= 0,
          ),
          const SizedBox(width: 12),
          _ActionButton(
            icon: Icons.refresh_rounded,
            onPressed: () => gp.startGame(gp.settings),
            tooltip: 'Restart Game',
          ),
          const SizedBox(width: 12),
          _ActionButton(
            icon: Icons.home_rounded,
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              StartScreen.routeName,
              (route) => false,
            ),
            tooltip: 'Home',
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;
  final bool isDisabled;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isDisabled ? _surfaceColor.withOpacity(0.5) : _surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    color?.withOpacity(0.5) ?? _outlineColor.withOpacity(0.2),
                width: color != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isDisabled
                  ? _onSurfaceColor.withOpacity(0.4)
                  : (color ?? _onSurfaceColor),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _GameStatusBar extends StatelessWidget {
  final bool isDesktop;
  const _GameStatusBar({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final isTimerMode = gp.settings.mode == GameMode.timer;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 20,
        vertical: 8,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: _surfaceColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _outlineColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Flexible(
                  child: _StatusChip(
                    icon: Icons.star_rounded,
                    label: 'Score',
                    value: '${gp.score}',
                    color: _tertiaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: _StatusChip(
                    icon: Icons.touch_app_rounded,
                    label: 'Moves',
                    value:
                        '${gp.movesUsed}${!isTimerMode ? "/${gp.settings.maxMoves}" : ""}',
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: _StatusChip(
                    icon: Icons.lightbulb_outline_rounded,
                    label: 'Hints',
                    value: '${gp.hintsRemaining}',
                    color: _hintColor,
                  ),
                ),
                const Spacer(),
                if (isTimerMode)
                  Flexible(
                    child: _StatusChip(
                      icon: Icons.timer_rounded,
                      label: 'Time Left',
                      value: '${gp.timeLeft}s',
                      color:
                          gp.timeLeft <= 10 ? _warningColor : _secondaryColor,
                      isAnimated: gp.timeLeft <= 10,
                    ),
                  )
                else
                  Flexible(
                    child: _StatusChip(
                      icon: Icons.schedule_rounded,
                      label: 'Elapsed',
                      value: '${gp.elapsed}s',
                      color: _secondaryColor,
                    ),
                  ),
              ],
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatusChip(
                        icon: Icons.star_rounded,
                        label: 'Score',
                        value: '${gp.score}',
                        color: _tertiaryColor,
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatusChip(
                        icon: Icons.touch_app_rounded,
                        label: 'Moves',
                        value:
                            '${gp.movesUsed}${!isTimerMode ? "/${gp.settings.maxMoves}" : ""}',
                        color: _primaryColor,
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatusChip(
                        icon: Icons.lightbulb_outline_rounded,
                        label: 'Hints',
                        value: '${gp.hintsRemaining}',
                        color: _hintColor,
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isTimerMode)
                  _StatusChip(
                    icon: Icons.timer_rounded,
                    label: 'Time Left',
                    value: '${gp.timeLeft}s',
                    color: gp.timeLeft <= 10 ? _warningColor : _secondaryColor,
                    isAnimated: gp.timeLeft <= 10,
                    isFullWidth: true,
                  )
                else
                  _StatusChip(
                    icon: Icons.schedule_rounded,
                    label: 'Elapsed',
                    value: '${gp.elapsed}s',
                    color: _secondaryColor,
                    isFullWidth: true,
                  ),
              ],
            ),
    );
  }
}

class _StatusChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isCompact;
  final bool isFullWidth;
  final bool isAnimated;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isCompact = false,
    this.isFullWidth = false,
    this.isAnimated = false,
  });

  @override
  State<_StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<_StatusChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isAnimated) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _StatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated != oldWidget.isAnimated) {
      if (widget.isAnimated) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCompact ? 12 : 16,
        vertical: widget.isCompact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: widget.isFullWidth
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Icon(
            widget.icon,
            size: widget.isCompact ? 18 : 20,
            color: widget.color,
          ),
          const SizedBox(width: 8),
          if (!widget.isCompact) ...[
            Text(
              widget.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _onSurfaceColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              widget.value,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );

    if (widget.isAnimated) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: content,
      );
    }

    return content;
  }
}

class _GameBoard extends StatelessWidget {
  final GameSettings settings;
  final bool isDesktop;
  final void Function(GameResult, GameSettings) onShowResult;

  const _GameBoard({
    required this.settings,
    required this.isDesktop,
    required this.onShowResult,
  });

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 20,
        vertical: 16,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cross = settings.gridCrossAxisCount;
          final spacing = isDesktop ? 12.0 : 8.0;

          final availableWidth = constraints.maxWidth - (spacing * (cross - 1));
          final availableHeight =
              constraints.maxHeight - (spacing * (cross - 1));

          final maxTileWidth = availableWidth / cross;
          final maxTileHeight = availableHeight / cross;
          final tileSize =
              maxTileWidth < maxTileHeight ? maxTileWidth : maxTileHeight;

          return Center(
            child: SizedBox(
              width: cross * tileSize + (cross - 1) * spacing,
              height: cross * tileSize + (cross - 1) * spacing,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 1,
                ),
                itemCount: gp.tiles.length,
                itemBuilder: (context, index) {
                  final tile = gp.tiles[index];
                  return _MemoryTile(
                    tile: tile,
                    size: tileSize,
                    isDesktop: isDesktop,
                    onTap: () async {
                      // Prevent taps if game is already ended
                      if (gp.finalResult != null) return;

                      await gp.onTileTap(index);

                      // Check for game end after the tap is processed
                      if (context.mounted && gp.finalResult != null) {
                        onShowResult(gp.finalResult!, settings);
                      }
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MemoryTile extends StatefulWidget {
  final Tile tile;
  final double size;
  final bool isDesktop;
  final VoidCallback onTap;

  const _MemoryTile({
    required this.tile,
    required this.size,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  State<_MemoryTile> createState() => _MemoryTileState();
}

class _MemoryTileState extends State<_MemoryTile>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _pulseController;

  late Animation<double> _flipAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Flip animation
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Pulse animation for hints
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.tile.isFlipped || widget.tile.isMatched) {
      _flipController.value = 1.0;
    }

    // Start pulse animation if tile is hinted
    if (widget.tile.isHinted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_MemoryTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle flip state changes
    if (widget.tile.isFlipped != oldWidget.tile.isFlipped ||
        widget.tile.isMatched != oldWidget.tile.isMatched) {
      if (widget.tile.isFlipped || widget.tile.isMatched) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }

    // Handle hint state changes
    if (widget.tile.isHinted != oldWidget.tile.isHinted) {
      if (widget.tile.isHinted) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(widget.isDesktop ? 20 : 16);

    return AnimatedBuilder(
      animation: Listenable.merge([_flipController, _pulseController]),
      builder: (context, child) {
        final isFlipping = _flipController.value > 0.5;
        final angle = _flipAnimation.value * 3.14159; // 0 to PI

        return Transform.scale(
          scale: widget.tile.isHinted ? _pulseAnimation.value : 1.0,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: widget.tile.isMatched
                        ? _secondaryColor.withOpacity(0.4)
                        : widget.tile.isHinted
                            ? _hintColor.withOpacity(0.6)
                            : Colors.black.withOpacity(0.3),
                    blurRadius:
                        widget.tile.isMatched || widget.tile.isHinted ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: borderRadius,
                child: InkWell(
                  onTap: widget.tile.isFlipped || widget.tile.isMatched
                      ? null
                      : widget.onTap,
                  borderRadius: borderRadius,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isFlipping
                            ? [_surfaceColor, _surfaceColor.withOpacity(0.8)]
                            : widget.tile.isHinted
                                ? [_hintColor.withOpacity(0.8), _hintColor]
                                : [_primaryColor, _tertiaryColor],
                      ),
                      border: Border.all(
                        color: widget.tile.isMatched
                            ? _secondaryColor
                            : widget.tile.isHinted
                                ? _hintColor
                                : _outlineColor.withOpacity(0.2),
                        width: widget.tile.isMatched || widget.tile.isHinted
                            ? 2.5
                            : 1,
                      ),
                    ),
                    child: isFlipping
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..rotateY(3.14159), // Flip back
                            child: _TileFace(
                              key: const ValueKey('face'),
                              assetPath: widget.tile.assetPath,
                              icon: widget.tile.fallbackIcon,
                              isMatched: widget.tile.isMatched,
                              size: widget.size,
                            ),
                          )
                        : _TileBack(
                            key: const ValueKey('back'),
                            size: widget.size,
                            isHinted: widget.tile.isHinted,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TileFace extends StatelessWidget {
  final String? assetPath;
  final IconData icon;
  final bool isMatched;
  final double size;

  const _TileFace({
    super.key,
    required this.assetPath,
    required this.icon,
    required this.isMatched,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.5;

    return Center(
      child: AnimatedScale(
        scale: isMatched ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect for matched tiles
            if (isMatched)
              Container(
                width: iconSize * 1.5,
                height: iconSize * 1.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _secondaryColor.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            // Main icon/image
            assetPath == null
                ? Icon(
                    icon,
                    size: iconSize,
                    color: isMatched ? _secondaryColor : _primaryColor,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      assetPath!,
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        icon,
                        size: iconSize,
                        color: isMatched ? _secondaryColor : _primaryColor,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _TileBack extends StatelessWidget {
  final double size;
  final bool isHinted;

  const _TileBack({
    super.key,
    required this.size,
    this.isHinted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hint glow effect
          if (isHinted)
            Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _hintColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          // Main memory icon
          Icon(
            Icons.memory,
            size: size * 0.4,
            color:
                isHinted ? _onSurfaceColor : _onSurfaceColor.withOpacity(0.8),
          ),
          // Sparkle effect for hinted tiles
          if (isHinted)
            Positioned(
              top: size * 0.15,
              right: size * 0.15,
              child: Icon(
                Icons.auto_awesome,
                size: size * 0.15,
                color: _hintColor,
              ),
            ),
        ],
      ),
    );
  }
}
