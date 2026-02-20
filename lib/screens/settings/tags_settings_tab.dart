import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tag_provider.dart';
import '../../models/card_model.dart';
import '../../l10n/app_localizations.dart';

class TagsSettingsTab extends StatefulWidget {
  const TagsSettingsTab({super.key});

  @override
  State<TagsSettingsTab> createState() => _TagsSettingsTabState();
}

class _TagsSettingsTabState extends State<TagsSettingsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TagProvider>(context, listen: false).loadTags();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<TagProvider>(
      builder: (context, tagProvider, child) {
        if (tagProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if there are any tags at all
        final hasAnyTags = tagProvider.getOrderedTags(CardCategory.loyalty).isNotEmpty ||
                          tagProvider.getOrderedTags(CardCategory.identity).isNotEmpty ||
                          tagProvider.getOrderedTags(CardCategory.document).isNotEmpty;

        if (!hasAnyTags) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.label_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noTagsYet,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Loyalty Tags Section
            _buildCategorySection(
              context,
              l10n,
              tagProvider,
              CardCategory.loyalty,
              l10n.loyaltyTags,
              Icons.card_giftcard,
            ),
            const SizedBox(height: 24),
            
            // Identity Tags Section
            _buildCategorySection(
              context,
              l10n,
              tagProvider,
              CardCategory.identity,
              l10n.identityTags,
              Icons.badge,
            ),
            const SizedBox(height: 24),
            
            // Document Tags Section
            _buildCategorySection(
              context,
              l10n,
              tagProvider,
              CardCategory.document,
              l10n.documentTags,
              Icons.description,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    AppLocalizations l10n,
    TagProvider tagProvider,
    CardCategory category,
    String categoryName,
    IconData categoryIcon,
  ) {
    final tags = tagProvider.getOrderedTags(category);
    
    if (tags.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(categoryIcon, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    categoryName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noTagsYet,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(categoryIcon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.categoryTagsDescription(categoryName.toLowerCase()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tags.length,
              onReorder: (oldIndex, newIndex) {
                tagProvider.reorderTags(oldIndex, newIndex, category: category);
              },
              itemBuilder: (context, index) {
                final tag = tags[index];
                return Card(
                  key: ValueKey('${category.name}_$tag'),
                  margin: const EdgeInsets.only(bottom: 8.0),
                  elevation: 1,
                  child: ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)),
                      ),
                      child: Icon(Icons.label, size: 16, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(tag, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      '${l10n.position} ${index + 1}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    trailing: Icon(
                      Icons.drag_handle,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
