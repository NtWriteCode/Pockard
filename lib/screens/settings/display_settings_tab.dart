import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/display_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/card_provider.dart';

class DisplaySettingsTab extends StatelessWidget {
  const DisplaySettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThemeSection(context),
          const SizedBox(height: 24),
          _buildLanguageSection(context),
          const SizedBox(height: 24),
          _buildLayoutSection(context),
          const SizedBox(height: 24),
          _buildCameraSection(context),
          const SizedBox(height: 24),
          _buildStatisticsSection(context),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<DisplayProvider>(
      builder: (context, displayProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.theme,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.themeDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ...AppTheme.values.map((theme) {
                    final isSelected = displayProvider.currentTheme == theme;
                    return ListTile(
                      leading: Icon(
                        _getThemeIcon(theme),
                        color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      title: Text(
                        _getLocalizedThemeName(context, theme),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        _getLocalizedThemeDescription(context, theme),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => displayProvider.setTheme(theme),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.languageLabel,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.languageDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: RadioGroup<String>(
                groupValue: languageProvider.languageCode,
                onChanged: (value) {
                  if (value == 'system') {
                    languageProvider.setSystemDefault();
                  } else if (value == 'en') {
                    languageProvider.setEnglish();
                  } else if (value == 'hu') {
                    languageProvider.setHungarian();
                  }
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(l10n.languageSystem),
                      value: 'system',
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: Text(l10n.languageEnglish),
                      value: 'en',
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: Text(l10n.languageHungarian),
                      value: 'hu',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLayoutSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<DisplayProvider>(
      builder: (context, displayProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.layout,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.layoutDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  // Layout mode selection
                  ...LayoutMode.values.map((mode) {
                    final isSelected = displayProvider.layoutMode == mode;
                    return ListTile(
                      leading: Icon(
                        _getLayoutIcon(mode),
                        color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      title: Text(
                        _getLocalizedLayoutName(context, mode),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        _getLocalizedLayoutDescription(context, mode),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => displayProvider.setLayoutMode(mode),
                    );
                  }),
                  
                  // Grid columns setting (only show when grid mode is selected)
                  if (displayProvider.layoutMode == LayoutMode.grid) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.gridColumns,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.gridColumnsDescription,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: displayProvider.gridColumns.toDouble(),
                                  min: 1,
                                  max: 4,
                                  divisions: 3,
                                  label: displayProvider.gridColumns.toString(),
                                  onChanged: (value) {
                                    displayProvider.setGridColumns(value.round());
                                  },
                                ),
                              ),
                              Container(
                                width: 40,
                                alignment: Alignment.center,
                                child: Text(
                                  displayProvider.gridColumns.toString(),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.oneColumn,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              Text(
                                l10n.fourColumns,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text(
                        l10n.showGridNames,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        l10n.showGridNamesDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      value: displayProvider.showGridNames,
                      onChanged: (value) => displayProvider.setShowGridNames(value),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Icons.light_mode;
      case AppTheme.dark:
        return Icons.dark_mode;
      case AppTheme.amoled:
        return Icons.brightness_low;
      case AppTheme.materialYou:
        return Icons.palette;
    }
  }

  String _getLocalizedThemeName(BuildContext context, AppTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    switch (theme) {
      case AppTheme.light:
        return l10n.themeLight;
      case AppTheme.dark:
        return l10n.themeDark;
      case AppTheme.amoled:
        return l10n.themeAmoled;
      case AppTheme.materialYou:
        return l10n.themeMaterialYou;
    }
  }

  String _getLocalizedThemeDescription(BuildContext context, AppTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    switch (theme) {
      case AppTheme.light:
        return l10n.themeLightDesc;
      case AppTheme.dark:
        return l10n.themeDarkDesc;
      case AppTheme.amoled:
        return l10n.themeAmoledDesc;
      case AppTheme.materialYou:
        return l10n.themeMaterialYouDesc;
    }
  }

  IconData _getLayoutIcon(LayoutMode mode) {
    switch (mode) {
      case LayoutMode.rows:
        return Icons.view_list;
      case LayoutMode.grid:
        return Icons.grid_view;
      case LayoutMode.minimal:
        return Icons.view_headline;
    }
  }

  String _getLocalizedLayoutName(BuildContext context, LayoutMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case LayoutMode.rows:
        return l10n.layoutRows;
      case LayoutMode.grid:
        return l10n.layoutGrid;
      case LayoutMode.minimal:
        return l10n.layoutMinimal;
    }
  }

  String _getLocalizedLayoutDescription(BuildContext context, LayoutMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case LayoutMode.rows:
        return l10n.layoutRowsDesc;
      case LayoutMode.grid:
        return l10n.layoutGridDesc;
      case LayoutMode.minimal:
        return l10n.layoutMinimalDesc;
    }
  }

  Widget _buildCameraSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<DisplayProvider>(
      builder: (context, displayProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.camera,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cameraDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                title: Text(
                  l10n.autoOpenCamera,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  l10n.autoOpenCameraDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                trailing: Switch(
                  value: displayProvider.autoOpenCamera,
                  onChanged: (value) => displayProvider.setAutoOpenCamera(value),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statisticsSection,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.statisticsSectionDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: Icon(
              Icons.delete_sweep,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.resetStatistics,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              l10n.resetStatisticsDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            onTap: () => _showResetStatisticsDialog(context),
          ),
        ),
      ],
    );
  }

  void _showResetStatisticsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetStatistics),
        content: Text(l10n.resetStatisticsConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Reset all card statistics
              final cardProvider = Provider.of<CardProvider>(context, listen: false);
              await cardProvider.resetAllStatistics();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.statisticsResetSuccess)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }
}
