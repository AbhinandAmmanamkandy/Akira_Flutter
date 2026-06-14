import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'ui/anime_list_page.dart';
import 'services/theme_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

            if (lightDynamic != null && themeService.useSystemAccent && themeService.isMaterialUI) {
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
            } else {
              lightColorScheme = ColorScheme.fromSeed(
                seedColor: Colors.red,
                brightness: Brightness.light,
              );
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: Colors.red,
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
                fontFamily: themeService.isMaterialUI ? null : GoogleFonts.poppins().fontFamily,
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme,
                useMaterial3: themeService.isMaterialUI,
                fontFamily: themeService.isMaterialUI ? null : GoogleFonts.poppins().fontFamily,
                textTheme: themeService.isMaterialUI
                    ? null
                    : GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
              ),
              home: const AnimeListPage(),
            );
          },
        );
      },
    );
  }
}
