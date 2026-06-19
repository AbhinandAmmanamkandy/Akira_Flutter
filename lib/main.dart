import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'services/theme_service.dart';
import 'services/history_service.dart';
import 'services/favorite_service.dart';
import 'package:media_kit/media_kit.dart';
import 'theme/akira_colors.dart';
import 'ui/pages/anime_list_page/anime_list_page.dart';
import 'ui/pages/profile_setup_page/profile_setup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await ThemeService().init();
  await HistoryService().init();
  await FavoriteService().init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
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
              // Use selected color from AkiraColors palette
              final paletteColors = AkiraColors.palette.values.toList();
              final selectedColor = paletteColors[themeService.customColorIndex % paletteColors.length];
              
              lightColorScheme = ColorScheme.fromSeed(
                seedColor: selectedColor,
                brightness: Brightness.light,
              );
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: selectedColor,
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
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.transparent,
                  foregroundColor: lightColorScheme.onSurface,
                  elevation: 0,
                  centerTitle: true,
                  iconTheme: IconThemeData(color: lightColorScheme.onSurface),
                  titleTextStyle: TextStyle(
                    color: lightColorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: themeService.isMaterialUI ? null : GoogleFonts.poppins().fontFamily,
                  ),
                ),
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
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.transparent,
                  foregroundColor: darkColorScheme.onSurface,
                  elevation: 0,
                  centerTitle: true,
                  iconTheme: IconThemeData(color: darkColorScheme.onSurface),
                  titleTextStyle: TextStyle(
                    color: darkColorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: themeService.isMaterialUI ? null : GoogleFonts.poppins().fontFamily,
                  ),
                ),
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
              home: themeService.isFirstOpen 
                  ? const ProfileSetupPage() 
                  : const AnimeListPage(),
            );
          },
        );
      },
    );
  }
}
