// screens/start_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class StartScreen extends StatefulWidget {
  static const routeName = '/start';
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  GameMode _selectedMode = GameMode.timer;
  int _gridCount = 4; // 4x4 by default
  int _seconds = 60; // for timer mode
  int _moves = 30; // for moves mode

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _startGame() {
    final settings = GameSettings(
      gridCrossAxisCount: _gridCount,
      mode: _selectedMode,
      durationSeconds: _seconds,
      maxMoves: _moves,
    );
    context.read<GameProvider>().startGame(settings);
    Navigator.pushNamed(context, GameScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;

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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        const Expanded(
          flex: 1,
          child: _GamePreview(),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: _GameSettings(
                selectedMode: _selectedMode,
                gridCount: _gridCount,
                seconds: _seconds,
                moves: _moves,
                onModeChanged: (mode) => setState(() => _selectedMode = mode),
                onGridChanged: (count) => setState(() => _gridCount = count),
                onSecondsChanged: (sec) => setState(() => _seconds = sec),
                onMovesChanged: (m) => setState(() => _moves = m),
                onStartGame: _startGame,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const _GameHeader(),
          const SizedBox(height: 20),
          _GameSettings(
            selectedMode: _selectedMode,
            gridCount: _gridCount,
            seconds: _seconds,
            moves: _moves,
            onModeChanged: (mode) => setState(() => _selectedMode = mode),
            onGridChanged: (count) => setState(() => _gridCount = count),
            onSecondsChanged: (sec) => setState(() => _seconds = sec),
            onMovesChanged: (m) => setState(() => _moves = m),
            onStartGame: _startGame,
          ),
        ],
      ),
    );
  }
}

// Define the color palette from the splash screen
const _primaryColor = Color(0xFF64B5F6); // Light blue
const _secondaryColor = Color(0xFF81C784); // Soft green
const _tertiaryColor = Color(0xFF9FA8DA); // Soft indigo
const _surfaceColor = Color(0xFF1A1A2E); // Rich dark blue
const _onSurfaceColor = Color(0xFFE3F2FD); // Light blueish white
const _outlineColor = Color(0xFF9E9E9E); // Soft gray for borders

class _GameHeader extends StatelessWidget {
  const _GameHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _surfaceColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.memory,
            size: 48,
            color: _onSurfaceColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Memory Game',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _onSurfaceColor,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Test your memory with this challenging game',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _onSurfaceColor.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _GamePreview extends StatelessWidget {
  const _GamePreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _surfaceColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.3),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.memory,
            size: 80,
            color: _onSurfaceColor,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Memory Game',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _onSurfaceColor,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Challenge your memory with beautiful cards\nand engaging gameplay',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _onSurfaceColor.withOpacity(0.7),
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        const _PreviewGrid(),
      ],
    );
  }
}

class _PreviewGrid extends StatelessWidget {
  const _PreviewGrid();

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.star,
      Icons.favorite,
      Icons.diamond,
      Icons.auto_awesome,
      Icons.pets,
      Icons.local_florist,
      Icons.flash_on,
      Icons.palette,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _outlineColor.withOpacity(0.2),
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 500 + (index * 100)),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _primaryColor,
                        _secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icons[index],
                      color: _onSurfaceColor,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _GameSettings extends StatelessWidget {
  final GameMode selectedMode;
  final int gridCount;
  final int seconds;
  final int moves;
  final ValueChanged<GameMode> onModeChanged;
  final ValueChanged<int> onGridChanged;
  final ValueChanged<int> onSecondsChanged;
  final ValueChanged<int> onMovesChanged;
  final VoidCallback onStartGame;

  const _GameSettings({
    required this.selectedMode,
    required this.gridCount,
    required this.seconds,
    required this.moves,
    required this.onModeChanged,
    required this.onGridChanged,
    required this.onSecondsChanged,
    required this.onMovesChanged,
    required this.onStartGame,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsCard(
          title: 'Game Mode',
          child: _GameModeSelector(
            selectedMode: selectedMode,
            onModeChanged: onModeChanged,
          ),
        ),
        const SizedBox(height: 20),
        _SettingsCard(
          title: 'Grid Size',
          child: _GridSizeSelector(
            gridCount: gridCount,
            onGridChanged: onGridChanged,
          ),
        ),
        const SizedBox(height: 20),
        _SettingsCard(
          title: selectedMode == GameMode.timer ? 'Time Limit' : 'Move Limit',
          child: selectedMode == GameMode.timer
              ? _TimeSelector(
                  seconds: seconds,
                  onChanged: onSecondsChanged,
                )
              : _MovesSelector(
                  moves: moves,
                  onChanged: onMovesChanged,
                ),
        ),
        const SizedBox(height: 32),
        _StartGameButton(onPressed: onStartGame),
        const SizedBox(height: 20),
        const _GameTip(),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _outlineColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _onSurfaceColor,
                ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _GameModeSelector extends StatelessWidget {
  final GameMode selectedMode;
  final ValueChanged<GameMode> onModeChanged;

  const _GameModeSelector(
      {required this.selectedMode, required this.onModeChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              icon: Icons.timer_rounded,
              label: 'Timer Mode',
              subtitle: 'Race against time',
              isSelected: selectedMode == GameMode.timer,
              onTap: () => onModeChanged(GameMode.timer),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ModeButton(
              icon: Icons.touch_app_rounded,
              label: 'Moves Mode',
              subtitle: 'Limited moves',
              isSelected: selectedMode == GameMode.moves,
              onTap: () => onModeChanged(GameMode.moves),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isSelected ? _primaryColor.withOpacity(0.8) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? _onSurfaceColor
                      : _onSurfaceColor.withOpacity(0.6),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _onSurfaceColor,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _onSurfaceColor.withOpacity(0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridSizeSelector extends StatelessWidget {
  final int gridCount;
  final ValueChanged<int> onGridChanged;

  const _GridSizeSelector(
      {required this.gridCount, required this.onGridChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GridOption(
            size: '4×4',
            description: 'Easy\n8 pairs',
            isSelected: gridCount == 4,
            onTap: () => onGridChanged(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GridOption(
            size: '6×6',
            description: 'Medium\n18 pairs',
            isSelected: gridCount == 6,
            onTap: () => onGridChanged(6),
          ),
        ),
      ],
    );
  }
}

class _GridOption extends StatelessWidget {
  final String size;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _GridOption({
    required this.size,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isSelected
            ? _primaryColor.withOpacity(0.8)
            : Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  size,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: _onSurfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _onSurfaceColor.withOpacity(0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final int seconds;
  final ValueChanged<int> onChanged;
  const _TimeSelector({required this.seconds, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            '${seconds}s',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _primaryColor,
            inactiveTrackColor: _primaryColor.withOpacity(0.2),
            thumbColor: _primaryColor,
            overlayColor: _primaryColor.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: seconds.toDouble(),
            min: 30,
            max: 180,
            divisions: 15,
            onChanged: (v) => onChanged(v.round()),
            label: '${seconds}s',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('30s',
                  style: TextStyle(color: _onSurfaceColor.withOpacity(0.7))),
              Text('180s',
                  style: TextStyle(color: _onSurfaceColor.withOpacity(0.7))),
            ],
          ),
        ),
      ],
    );
  }
}

class _MovesSelector extends StatelessWidget {
  final int moves;
  final ValueChanged<int> onChanged;

  const _MovesSelector({required this.moves, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            '$moves moves',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _primaryColor,
            inactiveTrackColor: _primaryColor.withOpacity(0.2),
            thumbColor: _primaryColor,
            overlayColor: _primaryColor.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: moves.toDouble(),
            min: 10,
            max: 120,
            divisions: 11,
            onChanged: (v) => onChanged(v.round()),
            label: '$moves',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10',
                  style: TextStyle(color: _onSurfaceColor.withOpacity(0.7))),
              Text('120',
                  style: TextStyle(color: _onSurfaceColor.withOpacity(0.7))),
            ],
          ),
        ),
      ],
    );
  }
}

class _StartGameButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartGameButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _secondaryColor,
            _primaryColor,
            _tertiaryColor,
          ],
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
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  color: _onSurfaceColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Start Game',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _onSurfaceColor,
                        fontWeight: FontWeight.bold,
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

class _GameTip extends StatelessWidget {
  const _GameTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _outlineColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: _primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Focus on remembering card positions rather than just the symbols. Start from corners and edges - they\'re easier to remember!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _onSurfaceColor.withOpacity(0.8),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
