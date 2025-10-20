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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    // When the settings screen is closed, automatically sync preferences
    final displayProvider = Provider.of<DisplayProvider>(context, listen: false);
    final tagProvider = Provider.of<TagProvider>(context, listen: false);
    final cardProvider = Provider.of<CardProvider>(context, listen: false);

    cardProvider.syncPreferences(displaySettings: displayProvider.exportSettings(), tagOrder: tagProvider.exportTagOrder());

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
