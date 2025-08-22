import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:memory_game/providers/game_provider.dart';
import 'package:memory_game/screens/splash_screen.dart' as splash;
import 'package:memory_game/screens/start_screen.dart' as start;
import 'package:memory_game/screens/game_screen.dart' as game;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MemoryGameApp());
}

class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      textTheme: GoogleFonts.poppinsTextTheme(),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Memory Game',
        theme: theme,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const splash.SplashScreen(),
          '/start': (_) => const start.StartScreen(),
          '/game': (_) => const game.GameScreen(),
        },
      ),
    );
  }
}
