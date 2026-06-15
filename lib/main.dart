import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'services/theme_service.dart';
import 'services/history_service.dart';
import 'package:media_kit/media_kit.dart';
import 'ui/anime_list_page/anime_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await ThemeService().init();
  await HistoryService().init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AkiraApp());
}

class AkiraApp extends StatelessWidget {
  const AkiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, child) {
        final themeService = ThemeService();

        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            ColorScheme lightColorScheme;
            ColorScheme darkColorScheme;

            bool shouldUseDynamic = themeService.useSystemAccent && themeService.isMaterialUI;
            
            if (shouldUseDynamic && lightDynamic != null) {
              // Save the color for next launch to avoid flicker
              themeService.saveSystemAccentColor(lightDynamic.primary);
              
              Color seedColor;
              switch (themeService.accentShade) {
                case 1:
                  seedColor = lightDynamic.secondary;
                  break;
                case 2:
                  seedColor = lightDynamic.tertiary;
                  break;
                default:
                  seedColor = lightDynamic.primary;
              }

              lightColorScheme = ColorScheme.fromSeed(
                seedColor: seedColor,
                brightness: Brightness.light,
              );
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: seedColor,
                brightness: Brightness.dark,
              );
            } else if (shouldUseDynamic && themeService.lastSystemAccentColor != null) {
              // Use cached color while waiting for DynamicColorBuilder
              final cachedColor = Color(themeService.lastSystemAccentColor!);
              lightColorScheme = ColorScheme.fromSeed(
                seedColor: cachedColor,
                brightness: Brightness.light,
              );
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: cachedColor,
                brightness: Brightness.dark,
              );
            } else {
              // Default fallback
              lightColorScheme = ColorScheme.fromSeed(
                seedColor: const Color(0xFFE53935), // Akira Red
                brightness: Brightness.light,
              );
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: const Color(0xFFE53935), // Akira Red
                brightness: Brightness.dark,
              );
            }

            return MaterialApp(
              title: 'Akira',
              debugShowCheckedModeBanner: false,
              themeMode: themeService.themeMode,
              theme: ThemeData(
                colorScheme: lightColorScheme,
                useMaterial3: themeService.isMaterialUI,
                fontFamily: themeService.isMaterialUI
                    ? null
                    : GoogleFonts.poppins().fontFamily,
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: themeService.useOverscrollToClose
                        ? const ZoomPageTransitionsBuilder()
                        : const CupertinoPageTransitionsBuilder(),
                    TargetPlatform.iOS: themeService.useOverscrollToClose
                        ? const ZoomPageTransitionsBuilder()
                        : const CupertinoPageTransitionsBuilder(),
                  },
                ),
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme,
                useMaterial3: themeService.isMaterialUI,
                fontFamily: themeService.isMaterialUI
                    ? null
                    : GoogleFonts.poppins().fontFamily,
                textTheme: themeService.isMaterialUI
                    ? null
                    : GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: themeService.useOverscrollToClose
                        ? const ZoomPageTransitionsBuilder()
                        : const CupertinoPageTransitionsBuilder(),
                    TargetPlatform.iOS: themeService.useOverscrollToClose
                        ? const ZoomPageTransitionsBuilder()
                        : const CupertinoPageTransitionsBuilder(),
                  },
                ),
              ),
              home: const AnimeListPage(),
            );
          },
        );
      },
    );
  }
}
