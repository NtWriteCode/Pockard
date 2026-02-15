import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/card_provider.dart';
import 'providers/document_provider.dart';
import 'providers/tag_provider.dart';
import 'providers/display_provider.dart';
import 'providers/language_provider.dart';
import 'screens/home_screen.dart';
import 'services/connection_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background SFTP connection
  final connectionManager = ConnectionManager();
  // Don't await the connection check - let it run in background so app starts immediately
  connectionManager.initializeConnection();

  runApp(const PockardApp());
}

class PockardApp extends StatelessWidget {
  const PockardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CardProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()..loadDocuments()),
        ChangeNotifierProvider(create: (_) => TagProvider()),
        ChangeNotifierProvider(create: (_) => DisplayProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..loadLanguage()),
      ],
      child: Consumer2<DisplayProvider, LanguageProvider>(
        builder: (context, displayProvider, languageProvider, child) {
          return MaterialApp(
            title: 'Pockard',
            theme: displayProvider.themeData,
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('hu'), // Hungarian
            ],
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
