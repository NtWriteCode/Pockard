import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../constants/app_colors.dart';

enum AppTheme { light, dark, amoled, materialYou }
enum LayoutMode { rows, grid, minimal }

class DisplayProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _layoutKey = 'layout_mode';
  static const String _gridColumnsKey = 'grid_columns';
  static const String _autoCameraKey = 'auto_open_camera';
  static const String _showGridNamesKey = 'show_grid_names';
  static const String _maxBrightnessKey = 'max_brightness_enabled';

  AppTheme _currentTheme = AppTheme.light;
  LayoutMode _layoutMode = LayoutMode.rows;
  int _gridColumns = 2;
  bool _autoOpenCamera = true; // Auto-open camera when + button is pressed
  bool _showGridNames = true; // Show card names in grid view
  bool _maxBrightnessEnabled = true; // Enable max brightness on barcode view
  ThemeData? _cachedMaterialYouTheme; // Cached Material You theme with system colors

  AppTheme get currentTheme => _currentTheme;
  LayoutMode get layoutMode => _layoutMode;
  int get gridColumns => _gridColumns;
  bool get autoOpenCamera => _autoOpenCamera;
  bool get showGridNames => _showGridNames;
  bool get maxBrightnessEnabled => _maxBrightnessEnabled;

  /// Get the current theme data
  ThemeData get themeData {
    switch (_currentTheme) {
      case AppTheme.light:
        return _lightTheme;
      case AppTheme.dark:
        return _darkTheme;
      case AppTheme.amoled:
        return _amoledTheme;
      case AppTheme.materialYou:
        // Use cached Material You theme, fallback to light if not yet loaded
        return _cachedMaterialYouTheme ?? _lightTheme;
    }
  }

  /// Light theme
  ThemeData get _lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primarySeed,
      brightness: Brightness.light,
    );
    
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// Dark theme
  ThemeData get _darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primarySeed,
      brightness: Brightness.dark,
    );
    
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// Pure black (AMOLED) theme
  ThemeData get _amoledTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primarySeed,
      brightness: Brightness.dark,
    ).copyWith(
      // Override specific colors for AMOLED (pure black)
      surface: AppColors.black,
      onSurface: AppColors.white,
    );
    
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.black,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.amoledAppBar,
        foregroundColor: AppColors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 4, // Higher elevation for better depth
        color: AppColors.amoledCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// Build Material You theme with system dynamic colors (Android 12+)
  /// Falls back to blue theme on older devices
  /// Automatically adapts to system light/dark mode
  Future<ThemeData> _buildMaterialYouTheme() async {
    try {
      // Detect system brightness (light/dark mode)
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      
      // Try to get system color palette from wallpaper
      final corePalette = await DynamicColorPlugin.getCorePalette();
      
      ColorScheme colorScheme;
      if (corePalette != null) {
        // Use system colors extracted from wallpaper! 🎨
        // Automatically matches system light/dark mode
        colorScheme = corePalette.toColorScheme(brightness: brightness);
      } else {
        // Fallback for Android < 12 or if dynamic colors unavailable
        colorScheme = ColorScheme.fromSeed(
          seedColor: AppColors.materialYouPrimary, // Blue fallback
          brightness: brightness,
        );
      }
      
      return ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: colorScheme.surface, // Base layer
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 4, // Subtle lift for better visual hierarchy
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          // Use surfaceContainer for subtle, consistent elevation (not vibrant primary)
          backgroundColor: colorScheme.surfaceContainer,
          foregroundColor: colorScheme.onSurface,
        ),
        cardTheme: CardThemeData(
          elevation: 4, // Match other themes for better depth perception
          // Use secondaryContainer for balanced, visible contrast
          color: colorScheme.secondaryContainer,
          surfaceTintColor: Colors.transparent, // Disable Material 3 tint overlay
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    } catch (e) {
      // On error, fallback to light theme
      return _lightTheme;
    }
  }

  /// Load settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _currentTheme = AppTheme.values[themeIndex];
    
    // Load layout mode
    final layoutIndex = prefs.getInt(_layoutKey) ?? 0;
    _layoutMode = LayoutMode.values[layoutIndex];
    
    // Load grid columns
    _gridColumns = prefs.getInt(_gridColumnsKey) ?? 2;
    
    // Load auto camera setting
    _autoOpenCamera = prefs.getBool(_autoCameraKey) ?? true;
    
    // Load show grid names setting
    _showGridNames = prefs.getBool(_showGridNamesKey) ?? true;
    
    // Load max brightness setting
    _maxBrightnessEnabled = prefs.getBool(_maxBrightnessKey) ?? true;
    
    // Pre-build Material You theme if it's the selected theme
    if (_currentTheme == AppTheme.materialYou) {
      _cachedMaterialYouTheme = await _buildMaterialYouTheme();
    }
    
    notifyListeners();
  }

  /// Set theme
  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    
    // Pre-build Material You theme if selected
    if (theme == AppTheme.materialYou) {
      _cachedMaterialYouTheme = await _buildMaterialYouTheme();
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
    notifyListeners();
  }

  /// Set layout mode
  Future<void> setLayoutMode(LayoutMode mode) async {
    _layoutMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_layoutKey, mode.index);
    notifyListeners();
  }

  /// Set grid columns
  Future<void> setGridColumns(int columns) async {
    if (columns < 1 || columns > 4) return;
    _gridColumns = columns;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gridColumnsKey, columns);
    notifyListeners();
  }

  /// Set auto open camera
  Future<void> setAutoOpenCamera(bool autoOpen) async {
    _autoOpenCamera = autoOpen;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoCameraKey, autoOpen);
    notifyListeners();
  }

  /// Set show grid names
  Future<void> setShowGridNames(bool showNames) async {
    _showGridNames = showNames;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showGridNamesKey, showNames);
    notifyListeners();
  }

  Future<void> setMaxBrightnessEnabled(bool enabled) async {
    _maxBrightnessEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_maxBrightnessKey, enabled);
    notifyListeners();
  }

  /// Get theme name key for localization lookup
  /// Returns the key to use with AppLocalizations
  String getThemeNameKey(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'themeLight';
      case AppTheme.dark:
        return 'themeDark';
      case AppTheme.amoled:
        return 'themeAmoled';
      case AppTheme.materialYou:
        return 'themeMaterialYou';
    }
  }

  /// Get layout mode name key for localization lookup
  /// Returns the key to use with AppLocalizations
  String getLayoutNameKey(LayoutMode mode) {
    switch (mode) {
      case LayoutMode.rows:
        return 'layoutRows';
      case LayoutMode.grid:
        return 'layoutGrid';
      case LayoutMode.minimal:
        return 'layoutMinimal';
    }
  }
  
  /// Export display settings to a map for syncing
  Map<String, dynamic> exportSettings() {
    return {
      'theme': _currentTheme.index,
      'layout_mode': _layoutMode.index,
      'grid_columns': _gridColumns,
      'auto_open_camera': _autoOpenCamera,
      'show_grid_names': _showGridNames,
      'max_brightness_enabled': _maxBrightnessEnabled,
    };
  }
  
  /// Import display settings from a map (from sync)
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      _currentTheme = AppTheme.values[settings['theme'] ?? 0];
      _layoutMode = LayoutMode.values[settings['layout_mode'] ?? 0];
      _gridColumns = settings['grid_columns'] ?? 2;
      _autoOpenCamera = settings['auto_open_camera'] ?? true;
      _showGridNames = settings['show_grid_names'] ?? true;
      _maxBrightnessEnabled = settings['max_brightness_enabled'] ?? true;
      
      // Pre-build Material You theme if selected
      if (_currentTheme == AppTheme.materialYou) {
        _cachedMaterialYouTheme = await _buildMaterialYouTheme();
      }
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _currentTheme.index);
      await prefs.setInt(_layoutKey, _layoutMode.index);
      await prefs.setInt(_gridColumnsKey, _gridColumns);
      await prefs.setBool(_autoCameraKey, _autoOpenCamera);
      await prefs.setBool(_showGridNamesKey, _showGridNames);
      await prefs.setBool(_maxBrightnessKey, _maxBrightnessEnabled);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error importing display settings: $e');
    }
  }
}
