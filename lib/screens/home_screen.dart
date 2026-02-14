import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/display_provider.dart';
import '../providers/card_provider.dart';
import '../providers/tag_provider.dart';
import '../models/card_model.dart';
import 'main_screen.dart';
import 'documents_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayProvider = Provider.of<DisplayProvider>(context);
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    // Dynamically build enabled tabs
    final List<Widget> tabs = [];
    final List<NavigationDestination> destinations = [];
    final List<CardCategory?> categories = [];

    if (displayProvider.showLoyalty) {
      tabs.add(const MainScreen(category: CardCategory.loyalty));
      destinations.add(NavigationDestination(
        icon: const Icon(Icons.credit_card),
        label: l10n.loyaltyCards,
      ));
      categories.add(CardCategory.loyalty);
    }

    if (displayProvider.showIdentity) {
      tabs.add(const MainScreen(category: CardCategory.identity));
      destinations.add(NavigationDestination(
        icon: const Icon(Icons.badge_outlined),
        label: l10n.identityCards,
      ));
      categories.add(CardCategory.identity);
    }

    if (displayProvider.showDocuments) {
      tabs.add(const DocumentsScreen());
      destinations.add(NavigationDestination(
        icon: const Icon(Icons.description_outlined),
        label: l10n.documents,
      ));
      categories.add(null); // Documents don't have a category in the same way
    }

    // Ensure _currentIndex is within bounds if settings changed
    if (_currentIndex >= tabs.length) {
      _currentIndex = 0;
    }

    // Fallback if somehow nothing is enabled (shouldn't happen with provider guards)
    if (tabs.isEmpty) {
      return const MainScreen();
    }

    // If only one tab is enabled, don't show the navigation bar
    if (tabs.length == 1) {
      return tabs[0];
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Update filter category in provider when swiping
          final category = categories[index];
          if (category != null) {
            cardProvider.setFilterCategory(category);
            Provider.of<TagProvider>(context, listen: false).loadTags(category: category);
          }
        },
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        destinations: destinations,
      ),
    );
  }
}
