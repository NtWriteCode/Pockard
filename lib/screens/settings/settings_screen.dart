import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'display_settings_tab.dart';
import 'tags_settings_tab.dart';
import 'sync_settings_tab.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/card_provider.dart';
import '../../providers/display_provider.dart';
import '../../providers/tag_provider.dart';

class SettingsScreen extends StatefulWidget {
  final int initialTabIndex;

  const SettingsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DisplayProvider? _displayProvider;
  TagProvider? _tagProvider;
  CardProvider? _cardProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store provider references when dependencies are available
    _displayProvider = Provider.of<DisplayProvider>(context, listen: false);
    _tagProvider = Provider.of<TagProvider>(context, listen: false);
    _cardProvider = Provider.of<CardProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // When the settings screen is closed, automatically sync preferences
    // Use stored provider references to avoid accessing deactivated widget tree
    if (_displayProvider != null && _tagProvider != null && _cardProvider != null) {
      // Sync preferences asynchronously (don't await to avoid blocking dispose)
      _cardProvider!
          .syncPreferences(displaySettings: _displayProvider!.exportSettings(), tagOrder: _tagProvider!.exportTagOrder())
          .then((_) {
            debugPrint('Settings screen: Preferences sync completed on dispose');
          })
          .catchError((error) {
            debugPrint('Settings screen: Preferences sync failed on dispose: $error');
          });
    } else {
      debugPrint('Settings screen: Provider references not available, skipping preferences sync');
    }

    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: const Icon(Icons.display_settings), text: l10n.display),
            Tab(icon: const Icon(Icons.local_offer), text: l10n.tags),
            Tab(icon: const Icon(Icons.sync), text: l10n.sync),
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: const [DisplaySettingsTab(), TagsSettingsTab(), SyncSettingsTab()]),
    );
  }
}
