import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memory_game/models/tile.dart';

enum GameMode { timer, moves }

class GameSettings {
  final int gridCrossAxisCount; // e.g., 4 => 4x4 = 8 pairs
  final GameMode mode;
  final int durationSeconds; // for timer mode
  final int maxMoves; // for moves mode

  const GameSettings({
    required this.gridCrossAxisCount,
    required this.mode,
    required this.durationSeconds,
    required this.maxMoves,
  });

  int get totalTiles => gridCrossAxisCount * gridCrossAxisCount;
  int get pairsCount => totalTiles ~/ 2;
}

class GameResult {
  final bool isWin;
  final int score;
  final int movesUsed;
  final int secondsElapsed;
  final int hintsUsed;

  const GameResult({
    required this.isWin,
    required this.score,
    required this.movesUsed,
    required this.secondsElapsed,
    required this.hintsUsed,
  });
}

// Define a default theme
const _primaryColor = Color(0xFF64B5F6); // Light blue
const _secondaryColor = Color(0xFF81C784); // Soft green
const _tertiaryColor = Color(0xFF9FA8DA); // Soft indigo
const _surfaceColor = Color(0xFF1A1A2E); // Rich dark blue
const _onSurfaceColor = Color(0xFFE3F2FD); // Light blueish white
const _outlineColor = Color(0xFF9E9E9E); // Soft gray for borders

// Define a default theme
final _defaultTheme = ThemeData(
  primaryColor: _primaryColor,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: _secondaryColor),
  scaffoldBackgroundColor: _surfaceColor,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: _onSurfaceColor),
    titleLarge: TextStyle(color: _onSurfaceColor),
  ),
);

// Define an alternative theme
final _alternativeTheme = ThemeData(
  primaryColor: Colors.orange,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.amber),
  scaffoldBackgroundColor: Colors.grey[800],
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
  ),
);

class GameProvider extends ChangeNotifier {
  late GameSettings _settings;
  List<Tile> _tiles = [];
  int? _firstIndex;
  int? _secondIndex;
  bool _lock = false;

  int _matchesFound = 0;
  int _movesUsed = 0;
  int _score = 0;
  int _hintsUsed = 0;
  int _hintsRemaining = 3; // Default 3 hints per game

  Timer? _timer;
  Timer? _hintTimer;
  int _timeLeft = 0;
  int _elapsed = 0;

  GameResult? _finalResult;
  List<int> _currentHintedTiles = [];

  ThemeData _currentTheme = _defaultTheme;

  // Getters
  List<Tile> get tiles => _tiles;
  int get movesUsed => _movesUsed;
  int get score => _score;
  int get timeLeft => _timeLeft;
  int get elapsed => _elapsed;
  int get hintsRemaining => _hintsRemaining;
  int get hintsUsed => _hintsUsed;
  GameSettings get settings => _settings;
  GameResult? get finalResult => _finalResult;
  ThemeData get currentTheme => _currentTheme;

  // Initialize / Start game
  void startGame(GameSettings settings) {
    _settings = settings;
    _tiles = _generateShuffledTiles(settings.pairsCount);
    _firstIndex = null;
    _secondIndex = null;
    _lock = false;
    _matchesFound = 0;
    _movesUsed = 0;
    _score = 0;
    _hintsUsed = 0;
    _hintsRemaining = _calculateInitialHints();
    _finalResult = null;
    _currentHintedTiles.clear();

    _timer?.cancel();
    _hintTimer?.cancel();
    _elapsed = 0;

    if (_settings.mode == GameMode.timer) {
      _timeLeft = _settings.durationSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        _elapsed++;
        _timeLeft--;
        if (_timeLeft <= 0) {
          _timeLeft = 0;
          t.cancel();
          _finishGame(win: _matchesFound == _settings.pairsCount);
        }
        notifyListeners();
      });
    } else {
      // moves mode
      _timeLeft = 0;
      _elapsed = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        _elapsed++;
        notifyListeners();
      });
    }

    notifyListeners();
  }

  // Update theme
  void updateTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  // Calculate initial hints based on difficulty
  int _calculateInitialHints() {
    switch (_settings.gridCrossAxisCount) {
      case 4: // 4x4 = 8 pairs (Easy)
        return 3;
      case 6: // 6x6 = 18 pairs (Medium)
        return 5;
      case 8: // 8x8 = 32 pairs (Hard)
        return 7;
      default:
        return 3;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hintTimer?.cancel();
    super.dispose();
  }

  // Hint system
  void useHint() {
    if (_hintsRemaining <= 0 || _lock) return;

    // Find unmatched tiles
    final unmatchedTiles = <int>[];
    for (int i = 0; i < _tiles.length; i++) {
      if (!_tiles[i].isMatched && !_tiles[i].isFlipped) {
        unmatchedTiles.add(i);
      }
    }

    if (unmatchedTiles.isEmpty) return;

    // Find a matching pair from unmatched tiles
    final List<int> hintPair = _findMatchingPair(unmatchedTiles);

    if (hintPair.isNotEmpty) {
      _hintsRemaining--;
      _hintsUsed++;
      _score = (_score - 5)
          .clamp(0, double.infinity)
          .toInt(); // Penalty for using hint

      // Clear previous hints
      _clearCurrentHints();

      // Apply hint effect to the pair
      _currentHintedTiles = hintPair;
      for (int index in hintPair) {
        _tiles[index] = _tiles[index].copyWith(isHinted: true);
      }

      notifyListeners();

      // Clear hint after 3 seconds
      _hintTimer?.cancel();
      _hintTimer = Timer(const Duration(seconds: 3), () {
        _clearCurrentHints();
        notifyListeners();
      });
    }
  }

  // Find a matching pair from unmatched tiles
  List<int> _findMatchingPair(List<int> unmatchedTiles) {
    final Map<int, List<int>> tileGroups = {};

    // Group tiles by their ID
    for (int index in unmatchedTiles) {
      final tileId = _tiles[index].id;
      tileGroups[tileId] ??= [];
      tileGroups[tileId]!.add(index);
    }

    // Find first pair with 2 unmatched tiles
    for (final group in tileGroups.values) {
      if (group.length >= 2) {
        return [group[0], group[1]];
      }
    }

    return [];
  }

  // Clear current hint effects
  void _clearCurrentHints() {
    for (int index in _currentHintedTiles) {
      if (index < _tiles.length) {
        _tiles[index] = _tiles[index].copyWith(isHinted: false);
      }
    }
    _currentHintedTiles.clear();
  }

  // Tap handling
  Future<void> onTileTap(int index) async {
    if (_lock) return;
    if (index < 0 || index >= _tiles.length) return;
    if (_tiles[index].isMatched || _tiles[index].isFlipped) return;

    // Clear any active hints when player makes a move
    _clearCurrentHints();
    _hintTimer?.cancel();

    _tiles[index] = _tiles[index].copyWith(isFlipped: true);
    notifyListeners();

    if (_firstIndex == null) {
      _firstIndex = index;
      return;
    }

    if (_secondIndex == null) {
      _secondIndex = index;
      _movesUsed++;
      notifyListeners();

      final a = _tiles[_firstIndex!];
      final b = _tiles[_secondIndex!];

      if (a.id == b.id) {
        // Match!
        _tiles[_firstIndex!] = _tiles[_firstIndex!].copyWith(isMatched: true);
        _tiles[_secondIndex!] = _tiles[_secondIndex!].copyWith(isMatched: true);
        _matchesFound++;
        _score += _calculateMatchScore(); // Dynamic scoring
        _resetSelection();
        notifyListeners();

        // Check win
        if (_matchesFound == _settings.pairsCount) {
          _finishGame(win: true);
        }
      } else {
        // Mismatch: flip back after delay
        _lock = true;
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 700));

        _tiles[_firstIndex!] = _tiles[_firstIndex!].copyWith(isFlipped: false);
        _tiles[_secondIndex!] =
            _tiles[_secondIndex!].copyWith(isFlipped: false);
        _resetSelection();
        _lock = false;
        notifyListeners();

        // In moves mode, check if moves exceeded
        if (_settings.mode == GameMode.moves &&
            _movesUsed >= _settings.maxMoves) {
          _finishGame(win: false);
        }
      }
    }
  }

  // Calculate match score based on performance
  int _calculateMatchScore() {
    int baseScore = 10;

    // Bonus for quick matches (in timer mode)
    if (_settings.mode == GameMode.timer) {
      final timeUsed = _settings.durationSeconds - _timeLeft;
      final avgTimePerMatch = timeUsed / (_matchesFound + 1);
      if (avgTimePerMatch < 10) {
        // Quick match bonus
        baseScore += 5;
      }
    }

    // Bonus for efficient moves (in moves mode)
    if (_settings.mode == GameMode.moves) {
      final efficiency = (_matchesFound + 1) / _movesUsed;
      if (efficiency > 0.8) {
        // High efficiency bonus
        baseScore += 5;
      }
    }

    // Consecutive match bonus
    baseScore += (_matchesFound % 3 == 2) ? 3 : 0;

    return baseScore;
  }

  void _resetSelection() {
    _firstIndex = null;
    _secondIndex = null;
  }

  void _finishGame({required bool win}) {
    _timer?.cancel();
    _hintTimer?.cancel();
    _clearCurrentHints();

    // Final score calculation
    int finalScore = _score;

    if (win) {
      // Win bonuses
      if (_settings.mode == GameMode.timer) {
        finalScore += _timeLeft * 2; // Time remaining bonus
      } else {
        final movesLeft = _settings.maxMoves - _movesUsed;
        finalScore += movesLeft * 3; // Moves remaining bonus
      }

      // Hint efficiency bonus
      final maxHints = _calculateInitialHints();
      final hintsLeftBonus = (_hintsRemaining) * 10;
      finalScore += hintsLeftBonus;
    }

    _score = finalScore.clamp(0, double.infinity).toInt();

    _finalResult = GameResult(
      isWin: win,
      score: _score,
      movesUsed: _movesUsed,
      secondsElapsed: _elapsed,
      hintsUsed: _hintsUsed,
    );
    notifyListeners();
  }

  // Helper: build pair tiles and shuffle
  List<Tile> _generateShuffledTiles(int pairs) {
    final rnd = Random();
    // Provide a list of fallback icons to vary visuals if assets are missing
    final iconBag = <IconData>[
      Icons.catching_pokemon,
      Icons.emoji_emotions,
      Icons.pets,
      Icons.ac_unit,
      Icons.anchor,
      Icons.android,
      Icons.apple,
      Icons.auto_awesome,
      Icons.bolt,
      Icons.coffee,
      Icons.earbuds,
      Icons.face,
      Icons.favorite,
      Icons.flight,
      Icons.icecream,
      Icons.palette,
      Icons.sailing,
      Icons.star,
      Icons.sports_soccer,
      Icons.camera_alt,
      Icons.beach_access,
      Icons.cake,
      Icons.directions_bike,
      Icons.eco,
      Icons.local_fire_department,
      Icons.music_note,
      Icons.park,
      Icons.school,
      Icons.wb_sunny,
      Icons.local_pizza,
    ];

    final tiles = <Tile>[];
    for (int i = 1; i <= pairs; i++) {
      final icon = iconBag[i % iconBag.length];
      final assetPath =
          'assets/images/$i.png'; // add your images with these names

      tiles.add(Tile(
        id: i,
        assetPath: assetPath,
        fallbackIcon: icon,
      ));
      tiles.add(Tile(
        id: i,
        assetPath: assetPath,
        fallbackIcon: icon,
      ));
    }
    tiles.shuffle(rnd);
    return tiles;
  }
}
