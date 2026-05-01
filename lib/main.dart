import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/settings_provider.dart';
import 'firebase_options.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait on mobile; allow all orientations on web/desktop
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: WordMarkApp()));
}

class WordMarkApp extends ConsumerWidget {
  const WordMarkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'WordMark',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      // Web: constrain the app to a reasonable max width with a dark background
      builder: kIsWeb
          ? (context, child) => _WebShell(child: child!)
          : null,
    );
  }
}

/// On web, centers the app in a dark surround and caps at phone width.
class _WebShell extends StatelessWidget {
  final Widget child;

  const _WebShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // On desktop web: show the app in a phone-sized column with side chrome
    if (screenWidth > 600) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0B),
        body: Row(
          children: [
            // Left sidebar hint on wide screens
            const Expanded(child: _WebSidebar(side: 'left')),
            // App frame
            Container(
              width: 430,
              decoration: const BoxDecoration(
                color: AppColors.darkBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: child,
            ),
            // Right sidebar
            const Expanded(child: _WebSidebar(side: 'right')),
          ],
        ),
      );
    }
    // Mobile web: full screen
    return child;
  }
}

class _WebSidebar extends StatelessWidget {
  final String side;

  const _WebSidebar({required this.side});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: side == 'left'
          ? Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WORD',
                    style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SidebarTile('M', AppColors.correct),
                      _SidebarTile('A', AppColors.present),
                      _SidebarTile('R', AppColors.absent),
                      _SidebarTile('K', AppColors.correct),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Daily challenges.\nThemed puzzles.\nLive duels.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final String letter;
  final Color color;

  const _SidebarTile(this.letter, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      margin: const EdgeInsets.only(right: 4),
      color: color,
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
