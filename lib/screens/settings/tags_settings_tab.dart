import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tag_provider.dart';
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

        if (tagProvider.orderedTags.isEmpty) {
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dragToReorderTags,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dragToReorderTagsDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: tagProvider.orderedTags.length,
                onReorder: (oldIndex, newIndex) {
                  tagProvider.reorderTags(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final tag = tagProvider.orderedTags[index];
                  return Card(
                    key: ValueKey(tag),
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Icon(
                          Icons.label,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        tag,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${l10n.position} ${index + 1}',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      trailing: Icon(
                        Icons.drag_handle,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
